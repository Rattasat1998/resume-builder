import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_state.dart';
import '../../domain/entities/user_plan.dart';

class SubscriptionDetailsPage extends StatelessWidget {
  const SubscriptionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageCubit, AppLanguage>(
      builder: (context, language) {
        final strings = AppStrings(language);
        return Scaffold(
          appBar: AppBar(
            title: Text(strings.settings), // Or create a specific string
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
                builder: (context, state) {
                  if (state.userPlan != UserPlan.free) {
                    return _buildSubscriptionInfo(context, state, strings);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionInfo(
    BuildContext context,
    SubscriptionState state,
    AppStrings strings,
  ) {
    final theme = Theme.of(context);
    final expirationDate = state.expirationDate;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, size: 64, color: theme.primaryColor),
            const SizedBox(height: 16),
            Text(
              strings.welcomePro(state.userPlan.displayName),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (expirationDate != null) ...[
              Text(
                'Expires on:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${expirationDate.day}/${expirationDate.month}/${expirationDate.year}",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                'Lifetime Access', // Or localized string
                style: theme.textTheme.titleMedium,
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
