import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../domain/entities/user_plan.dart';

enum SubscriptionStatus { initial, loading, loaded, error }

class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final UserPlan userPlan;
  final Offerings? offerings;
  final String? errorMessage;
  final DateTime? expirationDate;

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.userPlan = UserPlan.free,
    this.offerings,
    this.errorMessage,
    this.expirationDate,
  });

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    UserPlan? userPlan,
    Offerings? offerings,
    String? errorMessage,
    DateTime? expirationDate,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      userPlan: userPlan ?? this.userPlan,
      offerings: offerings ?? this.offerings,
      errorMessage: errorMessage,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userPlan,
    offerings,
    errorMessage,
    expirationDate,
  ];
}
