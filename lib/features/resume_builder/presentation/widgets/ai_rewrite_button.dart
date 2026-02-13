import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    // AI Features disabled for offline mode
    return const SizedBox.shrink();
  }
}
