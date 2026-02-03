import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_plan.dart';

abstract class SubscriptionRepository {
  /// Stream of user plan changes
  Stream<UserPlan> get planStream;

  /// Initialize the subscription service
  Future<void> init();

  /// Get current offerings
  Future<Result<Offerings>> getOfferings();

  /// Purchase a package
  Future<Result<bool>> purchasePackage(Package package);

  /// Restore purchases
  Future<Result<bool>> restorePurchases();

  /// Get the user's current plan
  Future<UserPlan> getUserPlan();

  /// Get subscription expiration date
  Future<DateTime?> getExpirationDate();

  /// Identify user with RevenueCat
  Future<void> logIn(String appUserId);

  /// Logout from RevenueCat
  Future<void> logOut();
}
