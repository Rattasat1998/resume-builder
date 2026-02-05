import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_plan.dart';
import '../../domain/repositories/subscription_repository.dart';

class RevenueCatRepositoryImpl implements SubscriptionRepository {
  // --- Configuration ---
  // 1. Debug/Test Keys (from your 'Test' project in RevenueCat)
  static const _androidDebugKey = 'test_MnIQzcirBXJPGIRhVjfcCBHFQyk';
  static const _iosDebugKey = 'test_MnIQzcirBXJPGIRhVjfcCBHFQyk';

  // 2. Production Keys (from your 'Live' project in RevenueCat)
  // TODO: Replace these with your actual standard RevenueCat API keys (usually start with 'goog_' or 'appl_')
  static const _androidProdKey = 'goog_yTpTkYkDVxIIurCJGaSiMGPnYaM';
  static const _iosProdKey = 'goog_yTpTkYkDVxIIurCJGaSiMGPnYaM';

  // Logic to select key based on environment
  String get _androidKey => kDebugMode ? _androidDebugKey : _androidProdKey;
  String get _iosKey => kDebugMode ? _iosDebugKey : _iosProdKey;

  bool _isInitialized = false;
  final _planController = StreamController<UserPlan>.broadcast();

  @override
  Stream<UserPlan> get planStream => _planController.stream;

  @override
  Future<void> init() async {
    if (_isInitialized) return;

    if (Platform.isAndroid) {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      await Purchases.configure(PurchasesConfiguration(_androidKey));
      _isInitialized = true;
    } else if (Platform.isIOS) {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      await Purchases.configure(PurchasesConfiguration(_iosKey));
      _isInitialized = true;
    }

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final plan =
          await getUserPlan(); // Re-use existing logic to determine plan
      _planController.add(plan);
    });
  }

  @override
  Future<Result<Offerings>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return Success(offerings);
    } on PlatformException catch (e) {
      return Error(
        ServerFailure(message: e.message ?? 'Failed to get offerings'),
      );
    } catch (e) {
      return Error(UnknownFailure(message: e.toString()));
    }
  }

  // Entitlement ID from RevenueCat
  static const _entitlementId = 'Resume Builder Pro';

  @override
  Future<Result<bool>> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      final isPro =
          purchaseResult
              .customerInfo
              .entitlements
              .all[_entitlementId]
              ?.isActive ??
          false;
      return Success(isPro);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return Error(UnknownFailure(message: 'Purchase cancelled'));
      }
      return Error(ServerFailure(message: e.message ?? 'Failed to purchase'));
    } catch (e) {
      return Error(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPro =
          customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
      return Success(isPro);
    } on PlatformException catch (e) {
      return Error(
        ServerFailure(message: e.message ?? 'Failed to restore purchases'),
      );
    } catch (e) {
      return Error(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<UserPlan> getUserPlan() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlements = customerInfo.entitlements.all;

      // Check for entitlement
      if (entitlements[_entitlementId]?.isActive == true) {
        return UserPlan.subscription;
      }

      return UserPlan.free;
    } catch (e) {
      return UserPlan.free;
    }
  }

  @override
  Future<DateTime?> getExpirationDate() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final dateString =
          customerInfo.entitlements.all[_entitlementId]?.expirationDate;
      if (dateString == null) return null;
      return DateTime.tryParse(dateString);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logIn(String appUserId) async {
    try {
      await Purchases.logIn(appUserId);
    } catch (e) {
      // Log error or rethrow if necessary
      debugPrint('Error logging in to RevenueCat: $e');
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      // Log error or rethrow if necessary
      debugPrint('Error logging out from RevenueCat: $e');
    }
  }
}
