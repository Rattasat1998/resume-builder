import '../../../../core/utils/result.dart';

import '../entities/resume_draft.dart';
import '../repositories/resume_builder_repository.dart';

/// Use case for creating a new resume draft
class CreateDraft {
  final ResumeBuilderRepository _repository;

  CreateDraft(this._repository);

  Future<Result<ResumeDraft>> call({String? title}) async {
    // Offline Mode: Limits removed
    // try {
    //   // 1. Check User Plan Limits
    //   final userPlan = await _subscriptionRepository.getUserPlan();

    //   // Free plan limit check (maxResumes < infinity)
    //   if (userPlan.maxResumes < 900000) {
    //     final draftsResult = await _repository.loadAllDrafts();

    //     if (draftsResult.isSuccess) {
    //       final currentCount = draftsResult.getOrThrow().length;
    //       if (currentCount >= userPlan.maxResumes) {
    //         // Return a specific failure that UI can handle to show Paywall
    //         return Error(
    //           LimitFailure(
    //             message:
    //                 'Free limit reached. Upgrade to create unlimited resumes.',
    //             code: 'LIMIT_REACHED',
    //           ),
    //         );
    //       }
    //     }
    //   }
    // } catch (e) {
    //   // Fail safe: allow creation if check fails? Or block?
    //   // Proceeding with creation to avoid blocking user on network error
    // }

    return _repository.createDraft(title: title);
  }
}
