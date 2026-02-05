import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../../../subscription/domain/entities/user_plan.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';
import '../../domain/entities/chat_message.dart';
import 'salary_estimator_page.dart';

class InterviewCoachPage extends StatefulWidget {
  const InterviewCoachPage({super.key});

  @override
  State<InterviewCoachPage> createState() => _InterviewCoachPageState();
}

class _InterviewCoachPageState extends State<InterviewCoachPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _jobPositionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _sessionStarted = false;
  String? _jobPosition;
  String _practiceLanguage = 'en'; // 'en' or 'th'

  @override
  void dispose() {
    _messageController.dispose();
    _jobPositionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startSession(AppStrings strings) async {
    final position = _jobPositionController.text.trim();
    if (position.isEmpty) return;

    setState(() {
      _jobPosition = position;
      _sessionStarted = true;
      _isLoading = true;
    });

    await _callInterviewCoachFunction(strings, isFirstMessage: true);
  }

  Future<void> _callInterviewCoachFunction(
    AppStrings strings, {
    bool isFirstMessage = false,
  }) async {
    try {
      // Build conversation history for context
      String? conversationHistory;
      if (!isFirstMessage && _messages.isNotEmpty) {
        conversationHistory = _messages
            .map(
              (m) => '${m.isUser ? "Candidate" : "Interviewer"}: ${m.content}',
            )
            .join('\n');
      }

      final response = await Supabase.instance.client.functions.invoke(
        'interview-coach',
        body: {
          'jobPosition': _jobPosition,
          'conversationHistory': conversationHistory,
          'practiceLanguage': _practiceLanguage,
        },
      );

      debugPrint('Interview Coach Response Status: ${response.status}');
      debugPrint('Interview Coach Response Data: ${response.data}');

      if (response.status != 200) {
        final errorData = response.data;
        debugPrint('Interview Coach Error: $errorData');
        throw Exception(errorData?['error'] ?? 'Failed to get response');
      }

      final data = response.data as Map<String, dynamic>;

      // Check for error in response
      if (data['error'] != null) {
        throw Exception(data['error']);
      }

      // Handle welcome message for first call
      if (isFirstMessage && data['welcome'] != null) {
        setState(() {
          _messages.add(
            ChatMessage.ai(data['welcome'], type: MessageType.systemMessage),
          );
        });
      }

      // Handle feedback
      if (data['feedback'] != null) {
        setState(() {
          _messages.add(
            ChatMessage.ai(data['feedback'], type: MessageType.feedback),
          );
        });
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Handle question
      if (data['question'] != null) {
        setState(() {
          _messages.add(
            ChatMessage.ai(data['question'], type: MessageType.question),
          );
        });
      }

      setState(() => _isLoading = false);
      _scrollToBottom();
    } catch (e) {
      debugPrint('Interview Coach Exception: $e');

      String errorMessage = '${strings.errorOccurred}: $e';
      if (e.toString().contains('400') ||
          e.toString().toLowerCase().contains('quota') ||
          e.toString().toLowerCase().contains('resource exhausted')) {
        errorMessage =
            'AI Service is busy (Quota Exceeded). Please try again later.';
      } else if (e.toString().toLowerCase().contains('gemini error')) {
        errorMessage =
            'AI Error: ${e.toString().split('Gemini Error:').last.trim()}';
      }

      setState(() {
        _messages.add(
          ChatMessage.ai(errorMessage, type: MessageType.systemMessage),
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(AppStrings strings) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage.user(text));
      _messageController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    await _callInterviewCoachFunction(strings);
  }

  Future<void> _checkSubscriptionAndSendMessage(AppStrings strings) async {
    final subscriptionState = context.read<SubscriptionBloc>().state;
    if (subscriptionState.userPlan == UserPlan.free) {
      Navigator.of(context).pushNamed('/paywall');
      return;
    }
    await _sendMessage(strings);
  }

  bool _isLoadingHint = false;

  Future<void> _getHint(AppStrings strings) async {
    // Find the last question from AI
    final lastQuestionMessage = _messages.lastWhere(
      (m) => !m.isUser && m.type == MessageType.question,
      orElse: () => ChatMessage.ai(''),
    );

    if (lastQuestionMessage.content.isEmpty) return;

    setState(() => _isLoadingHint = true);

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'interview-coach',
        body: {
          'jobPosition': _jobPosition,
          'conversationHistory': lastQuestionMessage.content,
          'practiceLanguage': _practiceLanguage,
          'action': 'hint',
        },
      );

      if (response.status == 200 && response.data != null) {
        final hint = response.data['hint'] as String?;
        if (hint != null && hint.isNotEmpty) {
          _showHintBottomSheet(hint, strings);
        }
      }
    } catch (e) {
      debugPrint('Get hint error: $e');
      if (mounted) {
        String errorMessage = '${strings.errorOccurred}: $e';
        if (e.toString().contains('400') ||
            e.toString().toLowerCase().contains('quota') ||
            e.toString().toLowerCase().contains('resource exhausted')) {
          errorMessage =
              'AI Service is busy (Quota Exceeded). Please try again later.';
        } else if (e.toString().toLowerCase().contains('gemini error')) {
          errorMessage =
              'AI Error: ${e.toString().split('Gemini Error:').last.trim()}';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      setState(() => _isLoadingHint = false);
    }
  }

  void _showHintBottomSheet(String hint, AppStrings strings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        bottom: true,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Text(
                    strings.answerHint,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(strings.gotIt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageCubit, AppLanguage>(
      builder: (context, appLanguage) {
        final strings = AppStrings(appLanguage);

        return Scaffold(
          appBar: AppBar(
            title: Text(strings.menuAtsCheck),
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
              if (_sessionStarted) ...[
                if (_messages.length > 2)
                  TextButton.icon(
                    onPressed: () => _getScore(strings),
                    icon: const Icon(
                      Icons.analytics_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Score',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                IconButton(
                  onPressed: () => _showEndSessionDialog(strings),
                  icon: const Icon(Icons.refresh),
                  tooltip: strings.newSession,
                ),
              ],
            ],
          ),
          body: _sessionStarted
              ? _buildChatView(strings)
              : _buildStartView(strings),
        );
      },
    );
  }

  Widget _buildStartView(AppStrings strings) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              strings.interviewCoachTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              strings.interviewCoachDesc,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _jobPositionController,
              decoration: InputDecoration(
                labelText: strings.jobPosition,
                hintText: strings.jobPositionHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.work_outline),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),
            // Language selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.practiceLanguage,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLanguageOption('en', '🇺🇸', 'English'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLanguageOption('th', '🇹🇭', 'ภาษาไทย'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startSession(strings),
                icon: const Icon(Icons.play_arrow),
                label: Text(strings.startInterview),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SalaryEstimatorPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.calculate_outlined),
                label: Text(strings.salaryEstimator), // Localized
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String flag, String label) {
    final isSelected = _practiceLanguage == code;
    return GestureDetector(
      onTap: () => setState(() => _practiceLanguage = code),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView(AppStrings strings) {
    final langLabel = _practiceLanguage == 'th' ? '🇹🇭 TH' : '🇺🇸 EN';
    return Column(
      children: [
        // Job position header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.work_outline, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$_jobPosition',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  langLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return _buildTypingIndicator();
              }
              return _buildMessageBubble(_messages[index], strings);
            },
          ),
        ),
        // Input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hint button row
                if (_messages.any((m) => m.type == MessageType.question))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: _isLoadingHint || _isLoading
                          ? null
                          : () => _getHint(strings),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isLoadingHint)
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.amber.shade700,
                                ),
                              )
                            else
                              Icon(
                                Icons.lightbulb_outline,
                                size: 16,
                                color: Colors.amber.shade700,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              strings.getHintButton,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Input row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: strings.typeYourAnswer,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(strings),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => _checkSubscriptionAndSendMessage(strings),
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, AppStrings strings) {
    final isUser = message.isUser;

    Color bubbleColor;
    Color textColor;
    IconData? prefixIcon;
    String? prefixLabel;

    if (isUser) {
      bubbleColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
    } else {
      switch (message.type) {
        case MessageType.question:
          bubbleColor = Colors.blue.shade50;
          textColor = Colors.blue.shade900;
          prefixIcon = Icons.help_outline;
          prefixLabel = strings.questionLabel;
          break;
        case MessageType.feedback:
          bubbleColor = Colors.green.shade50;
          textColor = Colors.green.shade900;
          prefixIcon = Icons.lightbulb_outline;
          prefixLabel = strings.feedbackLabel;
          break;
        case MessageType.systemMessage:
          bubbleColor = Colors.grey.shade200;
          textColor = Colors.grey.shade700;
          prefixIcon = Icons.info_outline;
          break;
        default:
          bubbleColor = Colors.grey.shade100;
          textColor = Colors.black87;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.psychology,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prefixIcon != null && prefixLabel != null && !isUser) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          prefixIcon,
                          size: 14,
                          color: textColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          prefixLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    message.content,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.psychology, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  void _showEndSessionDialog(AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.newSession),
        content: Text(strings.newSessionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _sessionStarted = false;
                _jobPosition = null;
                _jobPositionController.clear();
                _practiceLanguage = 'en';
              });
            },
            child: Text(strings.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _getScore(AppStrings strings) async {
    setState(() => _isLoading = true);

    // Build conversation history for score
    final conversationHistory = _messages
        .map((m) => '${m.isUser ? "Candidate" : "Interviewer"}: ${m.content}')
        .join('\n');

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'interview-coach',
        body: {
          'jobPosition': _jobPosition,
          'conversationHistory': conversationHistory,
          'practiceLanguage': _practiceLanguage,
          'action': 'score',
        },
      );

      setState(() => _isLoading = false);

      if (response.status == 200 && response.data != null) {
        final scoreData = response.data['score'];
        if (scoreData != null) {
          _showScoreDialog(scoreData, strings);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Get score error: $e');
    }
  }

  void _showScoreDialog(Map<String, dynamic> scoreData, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Interview Score',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: (scoreData['overall'] as int) / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      color: _getScoreColor(scoreData['overall'] as int),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${scoreData['overall']}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Overall', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildScoreBar(
                'Communication',
                scoreData['breakdown']['communication'],
              ),
              _buildScoreBar('Relevance', scoreData['breakdown']['relevance']),
              _buildScoreBar(
                'Confidence',
                scoreData['breakdown']['confidence'],
              ),
              _buildScoreBar('Structure', scoreData['breakdown']['structure']),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Assessment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                scoreData['assessment'] ?? '',
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, int score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '$score/100',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey.shade200,
            color: _getScoreColor(score),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.amber;
    return Colors.red;
  }
}
