import 'dart:typed_data';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/uid.dart';
import '../../domain/entities/resume_draft.dart';
import '../../domain/entities/sections/contact.dart';
import '../../domain/entities/sections/education.dart';
import '../../domain/entities/sections/experience.dart';
import '../../domain/entities/sections/profile.dart';
import '../../domain/entities/sections/project.dart';
import '../../domain/entities/sections/skill.dart';
import '../../domain/entities/template.dart';
import '../../domain/repositories/resume_builder_repository.dart';
import '../datasources/resume_local_ds.dart';
import '../datasources/resume_remote_ds.dart';
import '../mappers/resume_builder_mapper.dart';
import '../services/image_storage_service.dart';
import '../services/pdf_generator_service.dart';
import '../../../subscription/domain/repositories/subscription_repository.dart';

/// Implementation of ResumeBuilderRepository
class ResumeBuilderRepositoryImpl implements ResumeBuilderRepository {
  final ResumeLocalDataSource _localDataSource;
  final ResumeRemoteDataSource? _remoteDataSource;
  final ImageStorageService? _imageStorage;
  final SubscriptionRepository? _subscriptionRepository;

  ResumeBuilderRepositoryImpl(
    this._localDataSource, {
    ResumeRemoteDataSource? remoteDataSource,
    ImageStorageService? imageStorage,
    SubscriptionRepository? subscriptionRepository,
  }) : _remoteDataSource = remoteDataSource,
       _imageStorage = imageStorage,
       _subscriptionRepository = subscriptionRepository;

  /// Check if remote sync is available
  bool get _hasRemote => _remoteDataSource?.isConnected ?? false;

  @override
  Future<Result<ResumeDraft>> createDraft({String? title}) async {
    try {
      final draft = ResumeDraft.create(
        id: Uid.generate(),
        profileId: Uid.generate(),
        contactId: Uid.generate(),
        templateId: Uid.generate(),
        title: title ?? 'Untitled Resume',
      );

      final dto = ResumeBuilderMapper.resumeDraftToDto(draft);

      // Save to local first
      await _localDataSource.createDraft(dto);

      // Sync to remote if available
      if (_hasRemote) {
        try {
          // Check limits before initial sync
          final isAllowed = await _checkCloudLimitForNewDraft();
          if (isAllowed) {
            // Update to cloud synced
            final syncedDraft = draft.copyWith(isCloudSynced: true);
            final syncedDto = ResumeBuilderMapper.resumeDraftToDto(syncedDraft);

            await _remoteDataSource!.saveDraft(syncedDto);

            // Update local to reflect sync status
            await _localDataSource.saveDraft(syncedDto);

            return Success(syncedDraft);
          }
        } catch (e) {
          // Remote sync failed, but local save succeeded
          print('Remote sync failed: $e');
        }
      }

      return Success(draft);
    } on CacheException catch (e) {
      return Error(CacheFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<ResumeDraft>> loadDraft(String draftId) async {
    try {
      // Try local first
      var dto = await _localDataSource.getDraft(draftId);

      // If not found locally, try remote
      if (dto == null && _hasRemote) {
        dto = await _remoteDataSource!.getDraft(draftId);
        // Cache locally if found remotely
        if (dto != null) {
          await _localDataSource.saveDraft(dto);
        }
      }

      if (dto == null) {
        return const Error(NotFoundFailure(message: 'Draft not found'));
      }

      final draft = ResumeBuilderMapper.resumeDraftFromDto(dto);
      return Success(draft);
    } on CacheException catch (e) {
      return Error(CacheFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<ResumeDraft>>> loadAllDrafts() async {
    try {
      // Get local drafts
      final localDtos = await _localDataSource.getAllDrafts();

      // If remote is available, sync drafts
      if (_hasRemote) {
        try {
          final remoteDtos = await _remoteDataSource!.getAllDrafts();

          // Merge remote drafts with local (remote wins for same ID based on updatedAt)
          final mergedMap = <String, dynamic>{};

          for (final dto in localDtos) {
            mergedMap[dto.id] = dto;
          }

          for (final dto in remoteDtos) {
            final existing = mergedMap[dto.id];
            if (existing == null || dto.updatedAt.isAfter(existing.updatedAt)) {
              mergedMap[dto.id] = dto;
              // Update local cache
              await _localDataSource.saveDraft(dto);
            }
          }

          final drafts = mergedMap.values
              .map((dto) => ResumeBuilderMapper.resumeDraftFromDto(dto))
              .toList();

          // Sort by updatedAt
          drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return Success(drafts);
        } catch (e) {
          // Remote failed, use local only
          print('Remote fetch failed: $e');
        }
      }

      final drafts = localDtos
          .map(ResumeBuilderMapper.resumeDraftFromDto)
          .toList();
      return Success(drafts);
    } on CacheException catch (e) {
      return Error(CacheFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<ResumeDraft>> saveDraft(ResumeDraft draft) async {
    try {
      // 1. Upload image if needed
      var updatedDraft = await _uploadImageIfNeeded(draft);

      // 2. Determine cloud sync status
      updatedDraft = await _handleCloudSync(updatedDraft);

      final dto = ResumeBuilderMapper.resumeDraftToDto(updatedDraft);

      // 3. Save to local
      await _localDataSource.saveDraft(dto);

      // 4. Sync to remote ONLY if allowed
      if (_hasRemote && updatedDraft.isCloudSynced) {
        try {
          await _remoteDataSource!.saveDraft(dto);
        } catch (e) {
          print('Remote sync failed: $e');
        }
      }

      return Success(updatedDraft);
    } on CacheException catch (e) {
      return Error(CacheFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteDraft(String draftId) async {
    try {
      // Delete from local
      await _localDataSource.deleteDraft(draftId);

      // Delete from remote if available
      if (_hasRemote) {
        try {
          await _remoteDataSource!.deleteDraft(draftId);
        } catch (e) {
          print('Remote delete failed: $e');
        }
      }

      return const Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<ResumeDraft>> updateProfile(
    String draftId,
    Profile profile,
  ) async {
    return _updateDraft(draftId, (draft) => draft.copyWith(profile: profile));
  }

  @override
  Future<Result<ResumeDraft>> updateContact(
    String draftId,
    Contact contact,
  ) async {
    return _updateDraft(draftId, (draft) => draft.copyWith(contact: contact));
  }

  @override
  Future<Result<ResumeDraft>> addExperience(
    String draftId,
    Experience experience,
  ) async {
    return _updateDraft(draftId, (draft) {
      final experiences = [...draft.experiences, experience];
      return draft.copyWith(experiences: experiences);
    });
  }

  @override
  Future<Result<ResumeDraft>> updateExperience(
    String draftId,
    Experience experience,
  ) async {
    return _updateDraft(draftId, (draft) {
      final experiences = draft.experiences.map((e) {
        return e.id == experience.id ? experience : e;
      }).toList();
      return draft.copyWith(experiences: experiences);
    });
  }

  @override
  Future<Result<ResumeDraft>> removeExperience(
    String draftId,
    String experienceId,
  ) async {
    return _updateDraft(draftId, (draft) {
      final experiences = draft.experiences
          .where((e) => e.id != experienceId)
          .toList();
      return draft.copyWith(experiences: experiences);
    });
  }

  @override
  Future<Result<ResumeDraft>> reorderExperiences(
    String draftId,
    List<String> orderedIds,
  ) async {
    return _updateDraft(draftId, (draft) {
      final experiences = _reorderList(draft.experiences, orderedIds);
      return draft.copyWith(experiences: experiences);
    });
  }

  @override
  Future<Result<ResumeDraft>> addEducation(
    String draftId,
    Education education,
  ) async {
    return _updateDraft(draftId, (draft) {
      final educations = [...draft.educations, education];
      return draft.copyWith(educations: educations);
    });
  }

  @override
  Future<Result<ResumeDraft>> updateEducation(
    String draftId,
    Education education,
  ) async {
    return _updateDraft(draftId, (draft) {
      final educations = draft.educations.map((e) {
        return e.id == education.id ? education : e;
      }).toList();
      return draft.copyWith(educations: educations);
    });
  }

  @override
  Future<Result<ResumeDraft>> removeEducation(
    String draftId,
    String educationId,
  ) async {
    return _updateDraft(draftId, (draft) {
      final educations = draft.educations
          .where((e) => e.id != educationId)
          .toList();
      return draft.copyWith(educations: educations);
    });
  }

  @override
  Future<Result<ResumeDraft>> reorderEducations(
    String draftId,
    List<String> orderedIds,
  ) async {
    return _updateDraft(draftId, (draft) {
      final educations = _reorderList(draft.educations, orderedIds);
      return draft.copyWith(educations: educations);
    });
  }

  @override
  Future<Result<ResumeDraft>> addSkill(String draftId, Skill skill) async {
    return _updateDraft(draftId, (draft) {
      final skills = [...draft.skills, skill];
      return draft.copyWith(skills: skills);
    });
  }

  @override
  Future<Result<ResumeDraft>> updateSkill(String draftId, Skill skill) async {
    return _updateDraft(draftId, (draft) {
      final skills = draft.skills.map((s) {
        return s.id == skill.id ? skill : s;
      }).toList();
      return draft.copyWith(skills: skills);
    });
  }

  @override
  Future<Result<ResumeDraft>> removeSkill(
    String draftId,
    String skillId,
  ) async {
    return _updateDraft(draftId, (draft) {
      final skills = draft.skills.where((s) => s.id != skillId).toList();
      return draft.copyWith(skills: skills);
    });
  }

  @override
  Future<Result<ResumeDraft>> reorderSkills(
    String draftId,
    List<String> orderedIds,
  ) async {
    return _updateDraft(draftId, (draft) {
      final skills = _reorderList(draft.skills, orderedIds);
      return draft.copyWith(skills: skills);
    });
  }

  @override
  Future<Result<ResumeDraft>> addProject(
    String draftId,
    Project project,
  ) async {
    return _updateDraft(draftId, (draft) {
      final projects = [...draft.projects, project];
      return draft.copyWith(projects: projects);
    });
  }

  @override
  Future<Result<ResumeDraft>> updateProject(
    String draftId,
    Project project,
  ) async {
    return _updateDraft(draftId, (draft) {
      final projects = draft.projects.map((p) {
        return p.id == project.id ? project : p;
      }).toList();
      return draft.copyWith(projects: projects);
    });
  }

  @override
  Future<Result<ResumeDraft>> removeProject(
    String draftId,
    String projectId,
  ) async {
    return _updateDraft(draftId, (draft) {
      final projects = draft.projects.where((p) => p.id != projectId).toList();
      return draft.copyWith(projects: projects);
    });
  }

  @override
  Future<Result<ResumeDraft>> reorderProjects(
    String draftId,
    List<String> orderedIds,
  ) async {
    return _updateDraft(draftId, (draft) {
      final projects = _reorderList(draft.projects, orderedIds);
      return draft.copyWith(projects: projects);
    });
  }

  @override
  Future<Result<ResumeDraft>> updateTemplate(
    String draftId,
    Template template,
  ) async {
    return _updateDraft(draftId, (draft) => draft.copyWith(template: template));
  }

  @override
  Future<Result<Uint8List>> exportPdf(ResumeDraft draft) async {
    try {
      final pdfService = PdfGeneratorService();
      final pdfBytes = await pdfService.generatePdf(draft);
      return Success(pdfBytes);
    } catch (e) {
      return Error(ExportFailure(message: 'Failed to export PDF: $e'));
    }
  }

  /// Helper method to update a draft with a transformation function
  Future<Result<ResumeDraft>> _updateDraft(
    String draftId,
    ResumeDraft Function(ResumeDraft) transform,
  ) async {
    try {
      final dto = await _localDataSource.getDraft(draftId);
      if (dto == null) {
        return const Error(NotFoundFailure(message: 'Draft not found'));
      }

      var draft = ResumeBuilderMapper.resumeDraftFromDto(dto);
      draft = transform(draft);
      draft = draft.copyWith(updatedAt: DateTime.now());

      // 1. Upload image if needed
      draft = await _uploadImageIfNeeded(draft);

      // 2. Determine cloud sync status
      draft = await _handleCloudSync(draft);

      final updatedDto = ResumeBuilderMapper.resumeDraftToDto(draft);
      await _localDataSource.saveDraft(updatedDto);

      // 3. Sync to remote ONLY if allowed
      if (_hasRemote && draft.isCloudSynced) {
        try {
          await _remoteDataSource!.saveDraft(updatedDto);
        } catch (e) {
          // Don't fail local operation
          print('Remote sync failed: $e');
        }
      }

      return Success(draft);
    } on CacheException catch (e) {
      return Error(CacheFailure(message: e.message));
    } catch (e) {
      return Error(UnknownFailure(message: e.toString()));
    }
  }

  /// Helper to determine if draft should be synced to cloud
  Future<ResumeDraft> _handleCloudSync(ResumeDraft draft) async {
    // 1. Guest check
    if (_remoteDataSource == null || !_remoteDataSource!.isAuthenticated) {
      // Guest: force local only
      if (draft.isCloudSynced) {
        return draft.copyWith(isCloudSynced: false);
      }
      return draft;
    }

    // 2. Already synced check
    if (draft.isCloudSynced) {
      return draft;
    }

    // 3. Limit check for new sync
    try {
      final remoteDrafts = await _remoteDataSource!.getAllDrafts();
      // Filter out current draft if it matches ID (unlikely if isCloudSynced is false, but safe)
      final otherDrafts = remoteDrafts.where((d) => d.id != draft.id);

      int maxOnlineResumes = 0; // Default for Free
      if (_subscriptionRepository != null) {
        final userPlan = await _subscriptionRepository!.getUserPlan();
        maxOnlineResumes = userPlan.maxOnlineResumes;
      }

      if (otherDrafts.length < maxOnlineResumes) {
        return draft.copyWith(isCloudSynced: true);
      } else {
        // Limit reached
        print(
          'Cloud limit reached ($maxOnlineResumes resumes). Saving local only.',
        );
        return draft.copyWith(isCloudSynced: false);
      }
    } catch (e) {
      print('Failed to check remote limits: $e');
      // On error, default to local safe
      return draft.copyWith(isCloudSynced: false);
    }
  }

  /// Helper to check if a new draft can be synced to cloud
  Future<bool> _checkCloudLimitForNewDraft() async {
    if (_remoteDataSource == null || !_remoteDataSource!.isAuthenticated) {
      return false;
    }

    try {
      final remoteDrafts = await _remoteDataSource!.getAllDrafts();

      int maxOnlineResumes = 0; // Default for Free
      if (_subscriptionRepository != null) {
        final userPlan = await _subscriptionRepository!.getUserPlan();
        maxOnlineResumes = userPlan.maxOnlineResumes;
      }

      return remoteDrafts.length < maxOnlineResumes;
    } catch (e) {
      return false;
    }
  }

  /// Helper to upload avatar image if it's a local path
  Future<ResumeDraft> _uploadImageIfNeeded(ResumeDraft draft) async {
    final avatarUrl = draft.profile.avatarUrl;

    // Fast check if we need to do anything
    if (avatarUrl == null ||
        _imageStorage == null ||
        !ImageStorageService.isLocalPath(avatarUrl)) {
      return draft;
    }

    try {
      print('ResumeBuilderRepository: Attempting to upload avatar image...');
      final remoteUrl = await _imageStorage!.uploadImage(avatarUrl, draft.id);

      print('ResumeBuilderRepository: Upload result - remoteUrl: $remoteUrl');
      if (remoteUrl != null) {
        print('ResumeBuilderRepository: Updated draft with remote URL');
        return draft.copyWith(
          profile: draft.profile.copyWith(avatarUrl: remoteUrl),
        );
      } else {
        print(
          'ResumeBuilderRepository: Upload failed or returned null - keeping local path',
        );
        return draft;
      }
    } catch (e) {
      print('ResumeBuilderRepository: Error uploading image: $e');
      return draft;
    }
  }

  /// Helper method to reorder a list based on ordered IDs
  List<T> _reorderList<T>(List<T> items, List<String> orderedIds) {
    final itemMap = <String, T>{};
    for (final item in items) {
      final id = (item as dynamic).id as String;
      itemMap[id] = item;
    }

    return orderedIds
        .where((id) => itemMap.containsKey(id))
        .map((id) => itemMap[id]!)
        .toList();
  }
}
