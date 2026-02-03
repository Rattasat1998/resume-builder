import '../../../../core/utils/result.dart';
import '../entities/resume_draft.dart';
import '../repositories/resume_builder_repository.dart';

/// Use case for autosaving a resume draft
class AutosaveDraft {
  final ResumeBuilderRepository _repository;

  AutosaveDraft(this._repository);

  Future<Result<ResumeDraft>> call(ResumeDraft draft) {
    final updatedDraft = draft.copyWith(
      updatedAt: DateTime.now(),
    );
    return _repository.saveDraft(updatedDraft);
  }
}

