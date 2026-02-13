import 'package:flutter/material.dart';

class CoverLetterPage extends StatelessWidget {
  final Map<String, dynamic> resumeData;

  const CoverLetterPage({super.key, required this.resumeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cover Letter')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'AI Cover Letter Generation is unavailable in offline mode.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
