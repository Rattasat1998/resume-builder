import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiService {
  /// Rewrite text using AI via Supabase Edge Function
  Future<String> rewriteText(String text) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'rewrite-text',
        body: {'text': text},
      );

      final data = response.data;
      debugPrint('AI Service Response: $data'); // Add this line

      if (data != null && data is Map && data['rewritten'] != null) {
        return data['rewritten'].toString();
      }

      if (data != null && data is Map && data['error'] != null) {
        throw Exception(data['error']);
      }

      throw Exception('Invalid response from AI');
    } catch (e) {
      // Fallback or rethrow
      throw Exception('Failed to rewrite text: $e');
    }
  }

  /// Generate Cover Letter using AI via Supabase Edge Function
  Future<String> generateCoverLetter({
    required Map<String, dynamic> resumeData,
    required String jobDescription,
    String language = 'English',
  }) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'generate-cover-letter',
        body: {
          'resumeData': resumeData,
          'jobDescription': jobDescription,
          'language': language,
        },
      );

      final data = response.data;
      if (data != null && data is Map && data['coverLetter'] != null) {
        return data['coverLetter'].toString();
      }

      if (data != null && data is Map && data['error'] != null) {
        throw Exception(data['error']);
      }

      throw Exception('Invalid response from AI');
    } catch (e) {
      throw Exception('Failed to generate cover letter: $e');
    }
  }
}
