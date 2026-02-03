import '../../../../core/utils/result.dart';
import '../entities/resume_draft.dart';
import '../repositories/resume_builder_repository.dart';

/// Use case for loading a resume draft by ID
class LoadDraft {
  final ResumeBuilderRepository _repository;

  LoadDraft(this._repository);

  Future<Result<ResumeDraft>> call(String draftId) {
    return _repository.loadDraft(draftId);
  }
}

/// Use case for loading all saved drafts
class LoadAllDrafts {
  final ResumeBuilderRepository _repository;

  LoadAllDrafts(this._repository);

  Future<Result<List<ResumeDraft>>> call() {
    return _repository.loadAllDrafts();
  }
}

