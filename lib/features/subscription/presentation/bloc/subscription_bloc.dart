import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/user_plan.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;
  final AuthRepository? _authRepository;

  SubscriptionBloc(this._repository, {AuthRepository? authRepository})
    : _authRepository = authRepository,
      super(const SubscriptionState()) {
    on<SubscriptionInitialized>(_onInitialized);
    on<SubscriptionPurchaseRequested>(_onPurchaseRequested);
    on<SubscriptionRestoreRequested>(_onRestoreRequested);
    on<SubscriptionPlanChanged>(_onPlanChanged);

    // Listen to real-time plan updates
    _repository.planStream.listen((plan) {
      add(SubscriptionPlanChanged(plan));
    });
  }

  Future<void> _onInitialized(
    SubscriptionInitialized event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStatus.loading));

    await _repository.init();
    final userPlan = await _repository.getUserPlan();
    final expirationDate = await _repository.getExpirationDate();
    final offeringsResult = await _repository.getOfferings();

    offeringsResult.fold(
      onSuccess: (offerings) {
        // Always sync with backend to ensure DB reflects current status (Pro or Free)
        _syncToBackend(userPlan);

        emit(
          state.copyWith(
            status: SubscriptionStatus.loaded,
            userPlan: userPlan,
            expirationDate: expirationDate,
            offerings: offerings,
          ),
        );
      },
      onFailure: (failure) {
        emit(
          state.copyWith(
            status: SubscriptionStatus.error,
            errorMessage: failure.message,
            userPlan: userPlan,
            expirationDate: expirationDate, // Keep fetched date
          ),
        );
      },
    );
  }

  Future<void> _onPurchaseRequested(
    SubscriptionPurchaseRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStatus.loading));

    final result = await _repository.purchasePackage(event.package);

    result.fold(
      onSuccess: (_) async {
        // Update subscription in backend
        await _syncToBackend(UserPlan.subscription);

        // Reload to get updated plan
        add(const SubscriptionInitialized());
      },
      onFailure: (failure) {
        // Reload offerings/status to reset UI state
        add(const SubscriptionInitialized());
        emit(
          state.copyWith(
            status: SubscriptionStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> _onRestoreRequested(
    SubscriptionRestoreRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: SubscriptionStatus.loading));

    final result = await _repository.restorePurchases();

    result.fold(
      onSuccess: (_) async {
        // Update subscription in backend
        final plan = await _repository.getUserPlan();
        await _syncToBackend(plan);

        // Reload to get updated plan
        add(const SubscriptionInitialized());
      },
      onFailure: (failure) {
        emit(
          state.copyWith(
            status: SubscriptionStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> _onPlanChanged(
    SubscriptionPlanChanged event,
    Emitter<SubscriptionState> emit,
  ) async {
    // Sync with backend whenever plan changes from external source
    await _syncToBackend(event.plan);
    add(const SubscriptionInitialized());
  }

  Future<void> _syncToBackend(UserPlan plan) async {
    final authRepo = _authRepository;
    debugPrint('DEBUG: Syncing to backend. Plan: $plan');
    if (authRepo != null) {
      String tier = 'free';
      DateTime? expirationDate;

      if (plan == UserPlan.subscription) {
        tier = 'pro';
        expirationDate = await _repository.getExpirationDate();
      }

      debugPrint(
        'DEBUG: Updating subscription status. Tier: $tier, Expiry: $expirationDate',
      );
      try {
        await authRepo.updateSubscriptionStatus(
          tier: tier,
          expiryDate: expirationDate,
        );
        debugPrint('DEBUG: Subscription status updated in backend');
      } catch (e) {
        debugPrint('DEBUG: Failed to update subscription status: $e');
      }
    }
  }
}
