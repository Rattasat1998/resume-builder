import '../../../../core/utils/result.dart';
import '../entities/resume_draft.dart';
import '../repositories/resume_builder_repository.dart';

/// Use case for reordering items within a section
class ReorderItem {
  final ResumeBuilderRepository _repository;

  ReorderItem(this._repository);

  /// Reorder experience items
  Future<Result<ResumeDraft>> reorderExperiences(
    String draftId,
    List<String> orderedIds,
  ) {
    return _repository.reorderExperiences(draftId, orderedIds);
  }

  /// Reorder education items
  Future<Result<ResumeDraft>> reorderEducations(
    String draftId,
    List<String> orderedIds,
  ) {
    return _repository.reorderEducations(draftId, orderedIds);
  }

  /// Reorder skill items
  Future<Result<ResumeDraft>> reorderSkills(
    String draftId,
    List<String> orderedIds,
  ) {
    return _repository.reorderSkills(draftId, orderedIds);
  }

  /// Reorder project items
  Future<Result<ResumeDraft>> reorderProjects(
    String draftId,
    List<String> orderedIds,
  ) {
    return _repository.reorderProjects(draftId, orderedIds);
  }
}

