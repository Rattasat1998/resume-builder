import '../../../../core/utils/result.dart';
import '../entities/resume_draft.dart';
import '../repositories/resume_builder_repository.dart';

/// Use case for removing items from sections
class RemoveItem {
  final ResumeBuilderRepository _repository;

  RemoveItem(this._repository);

  /// Remove an experience item
  Future<Result<ResumeDraft>> removeExperience(
    String draftId,
    String experienceId,
  ) {
    return _repository.removeExperience(draftId, experienceId);
  }

  /// Remove an education item
  Future<Result<ResumeDraft>> removeEducation(
    String draftId,
    String educationId,
  ) {
    return _repository.removeEducation(draftId, educationId);
  }

  /// Remove a skill item
  Future<Result<ResumeDraft>> removeSkill(
    String draftId,
    String skillId,
  ) {
    return _repository.removeSkill(draftId, skillId);
  }

  /// Remove a project item
  Future<Result<ResumeDraft>> removeProject(
    String draftId,
    String projectId,
  ) {
    return _repository.removeProject(draftId, projectId);
  }
}

