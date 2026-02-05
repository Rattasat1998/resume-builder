import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../subscription/domain/entities/user_plan.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';
import '../../../../core/services/ai_service.dart';

class AiRewriteButton extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onRewritten;

  const AiRewriteButton({
    super.key,
    required this.controller,
    required this.onRewritten,
  });

  @override
  State<AiRewriteButton> createState() => _AiRewriteButtonState();
}

class _AiRewriteButtonState extends State<AiRewriteButton> {
  bool _isLoading = false;
  final _aiService = AiService();

  Future<void> _rewrite() async {
    final text = widget.controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text first')),
      );
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
    });

    try {
      final rewrittenText = await _aiService.rewriteText(text);
      if (mounted) {
        // Show confirmation dialog before replacing
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'AI Rewrite Suggestion',
                  style: TextStyle(color: Colors.purple, fontSize: 16),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Original:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(text, maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                const Text(
                  'Suggestion:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                Text(rewrittenText),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check),
                label: const Text('Apply'),
                style: FilledButton.styleFrom(backgroundColor: Colors.purple),
              ),
            ],
          ),
        );

        if (confirm == true) {
          widget.controller.text = rewrittenText;
          widget.onRewritten();
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to rewrite: $e';
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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : TextButton.icon(
            onPressed: _rewrite,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Rewrite with AI'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.purple,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
  }
}
