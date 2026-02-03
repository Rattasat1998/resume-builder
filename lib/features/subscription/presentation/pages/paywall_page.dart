import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../../../core/localization/app_language.dart';
import '../../../../../core/localization/app_language_cubit.dart';
import '../../domain/entities/user_plan.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state.status == SubscriptionStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        } else if (state.userPlan != UserPlan.free) {
          print('DEBUG: PaywallPage - User is Pro. Preparing to pop.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings(
                  context.read<AppLanguageCubit>().state,
                ).welcomePro(state.userPlan.displayName),
              ),
            ),
          );

          // Delay to allow native UI to settle/dismiss cleanly
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              print('DEBUG: PaywallPage - POPPING now.');
              Navigator.of(context).pop();
            }
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: PaywallView(
            onPurchaseCompleted: (customerInfo, storeTransaction) {
              context.read<SubscriptionBloc>().add(
                const SubscriptionInitialized(),
              );
            },
            onRestoreCompleted: (customerInfo) {
              context.read<SubscriptionBloc>().add(
                const SubscriptionInitialized(),
              );
            },
            onDismiss: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}
