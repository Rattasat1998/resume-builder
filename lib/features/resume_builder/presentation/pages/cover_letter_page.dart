import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/ai_service.dart';

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
  String _language = 'English'; // Default to English

  Future<void> _generate() async {
    if (_jobDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Job Description')),
      );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
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
      Clipboard.setData(ClipboardData(text: _generatedCoverLetter!));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Cover Letter'),
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
                        const Icon(Icons.auto_awesome, color: Colors.purple),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Paste the Job Description below. AI will tailor your cover letter to match your resume strengths with their requirements.',
                            style: TextStyle(color: Colors.purple.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Job Description Input
                const Text(
                  'Job Description:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _jobDescriptionController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Paste Job Description here...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Language Selector
                Row(
                  children: [
                    const Text(
                      'Language:',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                      label: const Text('Thai'),
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
                      _isLoading ? 'Generating...' : 'Generate Cover Letter',
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
                      const Text(
                        'Your Cover Letter:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy to Clipboard',
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
                    label: const Text('Copy Text'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
