import 'dart:typed_data';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../../../core/utils/result.dart';
import '../../../subscription/domain/entities/user_plan.dart';
import '../../../subscription/domain/repositories/subscription_repository.dart';
import '../entities/resume_draft.dart';
import '../repositories/resume_builder_repository.dart';

/// Use case for exporting resume as PDF
class ExportPdf {
  final ResumeBuilderRepository _repository;
  final SubscriptionRepository _subscriptionRepository;
  final KeyValueStore _keyValueStore;

  static const String _exportCountKey = 'free_export_count';

  ExportPdf(
    this._repository,
    this._subscriptionRepository,
    this._keyValueStore,
  );

  Future<Result<Uint8List>> call(ResumeDraft draft) async {
    try {
      final userPlan = await _subscriptionRepository.getUserPlan();

      // Check limits for Free Plan (or plans with finite limits)
      if (userPlan.maxExports < 900000) {
        final currentCount = await _keyValueStore.getInt(_exportCountKey) ?? 0;

        if (currentCount >= userPlan.maxExports) {
          return Error(
            ExportFailure(
              message:
                  'Free export limit reached (${userPlan.maxExports}). Upgrade to export unlimited.',
              code: 'LIMIT_REACHED',
            ),
          );
        }

        // Increment counter optimistically or after success?
        // Proceeding to export first, then increment if successful.
        final result = await _repository.exportPdf(draft);

        if (result.isSuccess) {
          await _keyValueStore.setInt(_exportCountKey, currentCount + 1);
        }

        return result;
      }
    } catch (e) {
      // Logic error checking limits, proceed safe ??
      // For feature gating, defaulting to block on error might be safer for business,
      // but defaulting to allow is better for UX.
      // Let's allow if check fails to avoid blocking due to tech issues.
    }

    return _repository.exportPdf(draft);
  }
}
