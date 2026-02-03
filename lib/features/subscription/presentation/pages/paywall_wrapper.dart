import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_plan.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_state.dart';
import 'paywall_page.dart';
import 'subscription_details_page.dart';

class PaywallWrapper extends StatelessWidget {
  const PaywallWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state.userPlan != UserPlan.free) {
          return const SubscriptionDetailsPage();
        }
        return const PaywallPage();
      },
    );
  }
}
