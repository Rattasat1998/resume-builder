import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../../../../core/services/ai_service.dart';
import '../../../subscription/domain/entities/user_plan.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';

class CoverLetterPage extends StatefulWidget {
  final Map<String, dynamic> resumeData;

  const CoverLetterPage({super.key, required this.resumeData});

  @override
  State<CoverLetterPage> createState() => _CoverLetterPageState();
}

class _CoverLetterPageState extends State<CoverLetterPage> {
  final _jobDescriptionController = TextEditingController();
  final _aiService = AiService();

  String? _generatedCoverLetter;
  bool _isLoading = false;
  String _language = 'English'; // Default

  @override
  void initState() {
    super.initState();
    final appLanguage = context.read<AppLanguageCubit>().state;
    _language = appLanguage == AppLanguage.thai ? 'Thai' : 'English';
  }

  Future<void> _generate() async {
    final appLanguage = context.read<AppLanguageCubit>().state;
    final strings = AppStrings(appLanguage);

    if (_jobDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.enterJobDescription)));
      return;
    }

    // Check Subscription
    final subscriptionState = context.read<SubscriptionBloc>().state;
    if (subscriptionState.userPlan == UserPlan.free) {
      Navigator.of(context).pushNamed('/paywall');
      return;
    }

    setState(() {
      _isLoading = true;
      _generatedCoverLetter = null;
    });

    try {
      final result = await _aiService.generateCoverLetter(
        resumeData: widget.resumeData,
        jobDescription: _jobDescriptionController.text,
        language: _language,
      );

      if (mounted) {
        setState(() {
          _generatedCoverLetter = result;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard() {
    if (_generatedCoverLetter != null) {
      final appLanguage = context.read<AppLanguageCubit>().state;
      final strings = AppStrings(appLanguage);

      Clipboard.setData(ClipboardData(text: _generatedCoverLetter!));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.copiedToClipboard)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageCubit, AppLanguage>(
      builder: (context, appLanguage) {
        final strings = AppStrings(appLanguage);

        return Scaffold(
          appBar: AppBar(
            title: Text(strings.smartCoverLetter),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          body: SafeArea(
            bottom: true,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tips Card
                    Card(
                      color: Colors.purple.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                strings.coverLetterTips,
                                style: TextStyle(color: Colors.purple.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Job Description Input
                    Text(
                      strings.jobDescriptionLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _jobDescriptionController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: strings.jobDescriptionHint,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Language Selector
                    Row(
                      children: [
                        Text(
                          strings.languageLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        ChoiceChip(
                          label: const Text('English'),
                          selected: _language == 'English',
                          onSelected: (selected) {
                            if (selected) setState(() => _language = 'English');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('ไทย'),
                          selected: _language == 'Thai',
                          onSelected: (selected) {
                            if (selected) setState(() => _language = 'Thai');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Generate Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _generate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.edit_document),
                        label: Text(
                          _isLoading
                              ? strings.generating
                              : strings.generateCoverLetter,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Result Section
                    if (_generatedCoverLetter != null) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            strings.yourCoverLetter,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy),
                            tooltip: strings.copyToClipboard,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _generatedCoverLetter!,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy),
                        label: Text(strings.copyText),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
