import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../subscription/domain/entities/user_plan.dart';
import '../../../subscription/presentation/bloc/subscription_bloc.dart';
import '../../../subscription/presentation/bloc/subscription_event.dart';
import '../../../subscription/presentation/bloc/subscription_state.dart';

class MenuDashboardPage extends StatefulWidget {
  const MenuDashboardPage({super.key});

  @override
  State<MenuDashboardPage> createState() => _MenuDashboardPageState();
}

class _MenuDashboardPageState extends State<MenuDashboardPage> {
  @override
  void initState() {
    super.initState();
    _checkSubscriptionAndShowPaywall();
  }

  void _checkSubscriptionAndShowPaywall() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Delay slightly to let the UI settle
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Check auth status first - don't show paywall if not authenticated
      final authBloc = context.read<AuthBloc?>();
      if (authBloc == null) return;

      final authState = authBloc.state;

      // Wait for auth check to complete (don't show if still loading)
      if (authState.status == AuthStatus.initial) {
        return;
      }

      // Don't show paywall if user is not logged in
      if (!authState.isAuthenticated) {
        return;
      }

      final subscriptionBloc = context.read<SubscriptionBloc>();
      final state = subscriptionBloc.state;

      // Only show paywall if user is authenticated AND is free tier
      if (state.status == SubscriptionStatus.loaded &&
          state.userPlan == UserPlan.free) {
        Navigator.of(context).pushNamed('/paywall');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageCubit, AppLanguage>(
      builder: (context, appLanguage) {
        final strings = AppStrings(appLanguage);
        final authBloc = context.watch<AuthBloc?>();
        final isAuthenticated = authBloc?.state.isAuthenticated ?? false;
        final user = authBloc?.state.user;

        return Scaffold(
          body: SafeArea(
            bottom: true,
            top: false,
            child: RefreshIndicator(
              onRefresh: () async {
                // Trigger subscription refresh
                context.read<SubscriptionBloc>().add(
                  const SubscriptionInitialized(),
                );
              },
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(
                    context,
                    strings,
                    appLanguage,
                    authBloc,
                    isAuthenticated,
                    user,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: _buildMenuList(context, strings),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    AppStrings strings,
    AppLanguage appLanguage,
    AuthBloc? authBloc,
    bool isAuthenticated,
    AppUser? user,
  ) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subState) {
        final isPremium =
            subState.status == SubscriptionStatus.loaded &&
            subState.userPlan != UserPlan.free;

        return SliverAppBar(
          expandedHeight: isAuthenticated && user != null
              ? 200.0
              : kToolbarHeight,
          pinned: true,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          title: Text(
            strings.dashboard,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            if (!isPremium && isAuthenticated)
              IconButton(
                onPressed: () => Navigator.of(context).pushNamed('/paywall'),
                icon: const Icon(Icons.workspace_premium, color: Colors.amber),
                tooltip: 'Upgrade to Pro',
              ),
            // _buildLanguageSwitcher(context, appLanguage),
            // const SizedBox(width: 8),
            if (authBloc != null)
              _buildUserMenu(context, isAuthenticated, strings),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: isAuthenticated && user != null
                ? _buildProfileHeader(context, user, isPremium, subState)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AppUser user,
    bool isPremium,
    SubscriptionState subState,
  ) {
    print(user.avatarUrl ?? '');
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (user.fullName != null && user.fullName!.isNotEmpty)
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPremium
                            ? Colors.amber
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPremium ? Icons.star : Icons.person,
                            size: 14,
                            color: isPremium ? Colors.black87 : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPremium ? 'PRO' : 'FREE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isPremium ? Colors.black87 : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, AppStrings strings) {
    final menuItems = [
      _MenuItem(
        icon: Icons.description_outlined,
        title: strings.menuMyResumes,
        description: strings.menuMyResumesDesc,
        color: const Color(0xFF2563EB),
        onTap: () => Navigator.of(context).pushNamed('/my-resumes'),
      ),
      _MenuItem(
        icon: Icons.edit_note_outlined,
        title: strings.menuCoverLetter,
        description: strings.menuCoverLetterDesc,
        color: const Color(0xFF7C3AED),
        onTap: () => Navigator.of(context).pushNamed('/cover-letter'),
      ),
      _MenuItem(
        icon: Icons.psychology_outlined,
        title: strings.menuAtsCheck,
        description: strings.menuAtsCheckDesc,
        color: const Color(0xFF059669),
        onTap: () => Navigator.of(context).pushNamed('/interview-coach'),
      ),
      _MenuItem(
        icon: Icons.calculate_outlined,
        title: strings.salaryEstimator,
        description: strings.salaryEstimatorDesc,
        color: const Color(0xFFF59E0B),
        onTap: () => Navigator.of(context).pushNamed('/salary-estimator'),
      ),
      _MenuItem(
        icon: Icons.map_outlined,
        title: strings.dreamJobRoadmap,
        description: strings.dreamJobRoadmapDesc,
        color: const Color(0xFF6366F1), // Indigo
        onTap: () => Navigator.of(context).pushNamed('/dream-roadmap'),
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        title: strings.menuSettings,
        description: strings.menuSettingsDesc,
        color: const Color(0xFF6B7280),
        onTap: () => Navigator.of(context).pushNamed('/subscription-details'),
      ),
    ];

    return Column(
      children: menuItems
          .map((item) => _buildMenuListTile(context, item, strings))
          .toList(),
    );
  }

  Widget _buildMenuListTile(
    BuildContext context,
    _MenuItem item,
    AppStrings strings,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: item.onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.color, size: 28),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (item.isComingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  strings.comingSoon,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, AppStrings strings) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚧 ${strings.comingSoon}!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildLanguageSwitcher(
    BuildContext context,
    AppLanguage currentLanguage,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppLanguage.values.map((lang) {
          final isSelected = currentLanguage == lang;
          return GestureDetector(
            onTap: () => context.read<AppLanguageCubit>().changeLanguage(lang),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                lang == AppLanguage.english ? 'EN' : 'TH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.white70,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserMenu(
    BuildContext context,
    bool isAuthenticated,
    AppStrings strings,
  ) {
    if (!isAuthenticated) {
      return TextButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/login'),
        icon: const Icon(Icons.login, size: 18, color: Colors.white),
        label: Text(
          strings.signIn,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'logout':
            _showLogoutConfirmation(context, strings);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red),
              const SizedBox(width: 8),
              Text(strings.signOut, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.signOut),
        content: Text(strings.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: Text(
              strings.signOut,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final bool isComingSoon;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    this.isComingSoon = false,
  });
}
