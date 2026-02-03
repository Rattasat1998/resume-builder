import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../domain/entities/user_plan.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitialized extends SubscriptionEvent {
  const SubscriptionInitialized();
}

class SubscriptionPurchaseRequested extends SubscriptionEvent {
  final Package package;

  const SubscriptionPurchaseRequested(this.package);

  @override
  List<Object?> get props => [package];
}

class SubscriptionRestoreRequested extends SubscriptionEvent {
  const SubscriptionRestoreRequested();
}

class SubscriptionPlanChanged extends SubscriptionEvent {
  final UserPlan plan;

  const SubscriptionPlanChanged(this.plan);

  @override
  List<Object?> get props => [plan];
}
