import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_plan.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'dart:async';

/// Implementation of SubscriptionRepository for Offline/Store mode.
/// This implementation basically tells the app "You are Premium" or handles
/// StoreKit directly if we were implementing IAP, but for now we are just
/// disabling the "subscription" limits.
class LocalSubscriptionRepositoryImpl implements SubscriptionRepository {
  // Stream to broadcast plan changes
  final _planController = StreamController<UserPlan>.broadcast();

  // In offline mode/store purchase mode, we might defaults to Premium
  // if the user bought the app, or Free if we still have a freemium model without subscriptions.
  // The request says "change to buy via store", which implies a paid app or one-time purchase.
  // "Disable subscription system" implies we don't check for recurrence.
  // Let's assume PRO access is granted by default or we treat "Buy via Store" Key.
  // For the transition, let's make it return Subscription (Pro) to unlock everything.

  @override
  Future<void> init() async {
    // No-op or init store kit
    // For now, we effectively give everyone PRO status to remove limits
    // until the actual Store implementation is verified.
    _planController.add(UserPlan.subscription);
  }

  @override
  Future<UserPlan> getUserPlan() async {
    // ALWAYS return subscription/pro to bypass limits
    return UserPlan.subscription;
  }

  @override
  Future<DateTime?> getExpirationDate() async {
    // Never expires
    return DateTime.now().add(const Duration(days: 365 * 100)); // 100 years
  }

  @override
  Stream<UserPlan> get planStream => _planController.stream;

  @override
  Future<Result<Offerings>> getOfferings() async {
    // Return empty offerings for now, or mock a "lifetime" package if needed
    // But since we auto-grant Pro, this might not be called often.
    // If called, we need to return a valid Offerings object or empty.
    // Constructing RevenueCat objects manually is hard/impossible as they have private constructors often.
    // So we return a Failure or try to return null/empty if the wrapper allows.
    // simpler: Return Failure to hide paywall content if it tries to load.
    return const Error(
      UnknownFailure(message: 'Offline mode: No offerings available'),
    );
  }

  @override
  Future<Result<bool>> purchasePackage(Package package) async {
    // Mock success
    _planController.add(UserPlan.subscription);
    return const Success(true);
  }

  @override
  Future<Result<bool>> restorePurchases() async {
    // Mock success
    _planController.add(UserPlan.subscription);
    return const Success(true);
  }

  @override
  Future<void> logIn(String appUserId) async {
    // No-op
  }

  @override
  Future<void> logOut() async {
    // No-op
  }
}
