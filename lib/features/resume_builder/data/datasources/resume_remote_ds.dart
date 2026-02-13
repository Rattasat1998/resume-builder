import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/resume_draft_dto.dart';

/// Remote data source for Resume using Supabase
abstract class ResumeRemoteDataSource {
  /// Get all resume drafts from Supabase
  Future<List<ResumeDraftDto>> getAllDrafts();

  /// Get a single resume draft by ID
  Future<ResumeDraftDto?> getDraft(String id);

  /// Save a resume draft (create or update)
  Future<void> saveDraft(ResumeDraftDto draft);

  /// Delete a resume draft
  Future<void> deleteDraft(String id);

  /// Check if connected to Supabase
  /// Check if connected to Supabase
  bool get isConnected;

  /// Check if user is authenticated
  bool get isAuthenticated;
}

class ResumeRemoteDataSourceImpl implements ResumeRemoteDataSource {
  final SupabaseClient _client;

  ResumeRemoteDataSourceImpl(this._client);

  @override
  bool get isConnected => SupabaseConfig.isConfigured;

  @override
  bool get isAuthenticated => _client.auth.currentUser != null;

  @override
  Future<List<ResumeDraftDto>> getAllDrafts() async {
    if (!isConnected) return [];

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from(SupabaseConfig.resumesTable)
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      return (response as List).map((json) => _parseResumeDraft(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch resumes: $e');
    }
  }

  @override
  Future<ResumeDraftDto?> getDraft(String id) async {
    if (!isConnected) return null;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from(SupabaseConfig.resumesTable)
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return _parseResumeDraft(response);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch resume: $e');
    }
  }

  @override
  Future<void> saveDraft(ResumeDraftDto draft) async {
    if (!isConnected) return;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const ServerException(message: 'User not authenticated');
    }

    try {
      final data = _toSupabaseFormat(draft);
      data['user_id'] = userId;

      await _client
          .from(SupabaseConfig.resumesTable)
          .upsert(data, onConflict: 'id');
    } catch (e) {
      throw ServerException(message: 'Failed to save resume: $e');
    }
  }

  @override
  Future<void> deleteDraft(String id) async {
    if (!isConnected) return;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client
          .from(SupabaseConfig.resumesTable)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException(message: 'Failed to delete resume: $e');
    }
  }

  /// Parse Supabase row to ResumeDraftDto
  ResumeDraftDto _parseResumeDraft(Map<String, dynamic> json) {
    // Supabase stores JSON as jsonb, need to handle both String and Map
    Map<String, dynamic> parseJsonField(dynamic field) {
      if (field is String) {
        return jsonDecode(field) as Map<String, dynamic>;
      } else if (field is Map) {
        return Map<String, dynamic>.from(field);
      }
      return {};
    }

    List<dynamic> parseJsonList(dynamic field) {
      if (field is String) {
        return jsonDecode(field) as List<dynamic>;
      } else if (field is List) {
        return field;
      }
      return [];
    }

    return ResumeDraftDto(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      template: TemplateDto.fromJson(parseJsonField(json['template'])),
      profile: ProfileDto.fromJson(parseJsonField(json['profile'])),
      contact: ContactDto.fromJson(parseJsonField(json['contact'])),
      experiences: (parseJsonList(json['experiences']))
          .map((e) => ExperienceDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      educations: (parseJsonList(json['educations']))
          .map((e) => EducationDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      skills: (parseJsonList(
        json['skills'],
      )).map((e) => SkillDto.fromJson(Map<String, dynamic>.from(e))).toList(),
      projects: (parseJsonList(
        json['projects'],
      )).map((e) => ProjectDto.fromJson(Map<String, dynamic>.from(e))).toList(),
      languages: (parseJsonList(json['languages']))
          .map((e) => LanguageDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      hobbies: (parseJsonList(
        json['hobbies'],
      )).map((e) => HobbyDto.fromJson(Map<String, dynamic>.from(e))).toList(),
      isDraft: json['is_draft'] as bool? ?? true,
      resumeLanguage: json['resume_language'] as String? ?? 'english',
      isCloudSynced: true,
    );
  }

  /// Convert ResumeDraftDto to Supabase format
  Map<String, dynamic> _toSupabaseFormat(ResumeDraftDto draft) {
    return {
      'id': draft.id,
      'title': draft.title,
      'created_at': draft.createdAt.toIso8601String(),
      'updated_at': draft.updatedAt.toIso8601String(),
      'template': draft.template.toJson(),
      'profile': draft.profile.toJson(),
      'contact': draft.contact.toJson(),
      'experiences': draft.experiences.map((e) => e.toJson()).toList(),
      'educations': draft.educations.map((e) => e.toJson()).toList(),
      'skills': draft.skills.map((e) => e.toJson()).toList(),
      'projects': draft.projects.map((e) => e.toJson()).toList(),
      'languages': draft.languages.map((e) => e.toJson()).toList(),
      'hobbies': draft.hobbies.map((e) => e.toJson()).toList(),
      'is_draft': draft.isDraft,
      'resume_language': draft.resumeLanguage,
    };
  }
}
