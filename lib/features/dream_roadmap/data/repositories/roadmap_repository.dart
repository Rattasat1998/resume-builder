import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/roadmap_model.dart';

class RoadmapRepository {
  final SupabaseClient _supabase;

  RoadmapRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  Future<RoadmapModel?> getUserRoadmap() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_roadmaps')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return RoadmapModel.fromJson(response);
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching roadmap: $e');
      rethrow;
    }
  }

  Future<RoadmapModel> generateAndSaveRoadmap({
    required String jobTitle,
    String? company,
    required String currentLevel,
    required String languageCode, // 'en' or 'th'
  }) async {
    try {
      // 1. Call Edge Function to generate roadmap
      final functionResponse = await _supabase.functions.invoke(
        'interview-coach',
        body: {
          'action': 'roadmap',
          'jobPosition': jobTitle,
          'targetCompany': company,
          'currentLevel': currentLevel,
          'practiceLanguage': languageCode,
        },
      );

      if (functionResponse.status != 200) {
        throw Exception(
          'Failed to generate roadmap: ${functionResponse.status}',
        );
      }

      final data = functionResponse.data['roadmap'];
      final steps = data['steps'] as List;
      final motivation = data['motivation'] as String?;

      // 2. Prepare data for insertion
      final userId = _supabase.auth.currentUser!.id;
      final roadmapData = {
        'user_id': userId,
        'target_job_title': jobTitle,
        'target_company': company,
        'current_level': currentLevel,
        'steps': steps, // JSONB will handle List<Map>
        'motivation_message': motivation,
      };

      // 3. Save to Database (Upsert: replace if exists for this user?
      //    For now, let's assume one roadmap per user, so we check first or just insert)
      //    Actually, let's allow creating a new one which effectively replaces the "active" one if we query by latest.
      //    But to keep it clean, let's delete old ones or update if exists.
      //    Simple approach: Insert new row. Query fetches the latest one.

      final dbResponse = await _supabase
          .from('user_roadmaps')
          .insert(roadmapData)
          .select()
          .single();

      return RoadmapModel.fromJson(dbResponse);
    } catch (e) {
      // ignore: avoid_print
      print('Error generating/saving roadmap: $e');
      rethrow;
    }
  }

  Future<void> updateStepProgress(
    String roadmapId,
    List<RoadmapStep> updatedSteps,
  ) async {
    try {
      await _supabase
          .from('user_roadmaps')
          .update({'steps': updatedSteps.map((s) => s.toJson()).toList()})
          .eq('id', roadmapId);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating steps: $e');
      rethrow;
    }
  }

  Future<void> deleteRoadmap(String roadmapId) async {
    try {
      await _supabase.from('user_roadmaps').delete().eq('id', roadmapId);
    } catch (e) {
      rethrow;
    }
  }
}
