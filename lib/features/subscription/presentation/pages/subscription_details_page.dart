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
            title: Text(strings.menuSettings),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language Section
                _buildSectionTitle(context, strings.languageLabel),
                const SizedBox(height: 12),
                _buildLanguageSwitcher(context, language, strings),
                const SizedBox(height: 32),

                // Subscription Section
                _buildSectionTitle(context, strings.subscription),
                const SizedBox(height: 12),
                BlocBuilder<SubscriptionBloc, SubscriptionState>(
                  builder: (context, state) {
                    return _buildSubscriptionCard(context, state, strings);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildLanguageSwitcher(
    BuildContext context,
    AppLanguage currentLanguage,
    AppStrings strings,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: AppLanguage.values.map((lang) {
          final isSelected = currentLanguage == lang;
          return ListTile(
            onTap: () => context.read<AppLanguageCubit>().changeLanguage(lang),
            leading: Text(
              lang == AppLanguage.english ? '🇺🇸' : '🇹🇭',
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              lang == AppLanguage.english ? 'English' : 'ภาษาไทย',
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  )
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    SubscriptionState state,
    AppStrings strings,
  ) {
    final theme = Theme.of(context);
    final isPro = state.userPlan != UserPlan.free;
    final expirationDate = state.expirationDate;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPro
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPro ? Icons.workspace_premium : Icons.person,
                    size: 32,
                    color: isPro ? Colors.amber.shade700 : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPro ? 'PRO' : 'FREE',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isPro && expirationDate != null)
                        Text(
                          '${strings.expiresOn}: ${expirationDate.day}/${expirationDate.month}/${expirationDate.year}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        )
                      else if (isPro)
                        Text(
                          strings.lifetimeAccess,
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 13,
                          ),
                        )
                      else
                        Text(
                          strings.upgradeForMore,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isPro) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed('/paywall'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(strings.upgradeToPro),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
