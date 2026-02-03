import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'core/config/supabase_config.dart';
import 'core/localization/app_language.dart';
import 'core/localization/app_language_cubit.dart';
import 'core/storage/key_value_store.dart';
import 'features/auth/data/datasources/auth_remote_ds.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/domain/entities/app_user.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/resume_builder/data/datasources/resume_local_ds.dart';
import 'features/resume_builder/data/datasources/resume_remote_ds.dart';
import 'features/resume_builder/data/repositories/resume_builder_repository_impl.dart';
import 'features/resume_builder/data/services/image_storage_service.dart';
import 'features/resume_builder/domain/entities/resume_draft.dart';
import 'features/resume_builder/domain/entities/resume_language.dart';
import 'features/resume_builder/domain/repositories/resume_builder_repository.dart';
import 'features/resume_builder/domain/usecases/autosave_draft.dart';
import 'features/resume_builder/domain/usecases/create_draft.dart';
import 'features/resume_builder/domain/usecases/export_pdf.dart';
import 'features/resume_builder/domain/usecases/load_draft.dart';
import 'features/resume_builder/domain/usecases/remove_item.dart';
import 'features/resume_builder/domain/usecases/reorder_item.dart';
import 'features/resume_builder/domain/usecases/update_section.dart';
import 'features/resume_builder/presentation/bloc/builder/builder_bloc.dart';
import 'features/resume_builder/presentation/bloc/builder/builder_event.dart';
import 'features/resume_builder/presentation/bloc/preview/preview_cubit.dart';
import 'features/resume_builder/presentation/pages/builder_shell_page.dart';
import 'features/resume_builder/presentation/pages/preview_page.dart';
import 'features/resume_builder/presentation/pages/templates_page.dart';
import 'features/subscription/data/repositories/revenue_cat_repository_impl.dart';
import 'features/subscription/domain/repositories/subscription_repository.dart';
import 'features/subscription/presentation/bloc/subscription_bloc.dart';
import 'features/subscription/presentation/bloc/subscription_event.dart';
import 'features/subscription/presentation/bloc/subscription_state.dart';
import 'features/subscription/domain/entities/user_plan.dart';
import 'features/subscription/presentation/pages/subscription_details_page.dart';
import 'features/subscription/presentation/pages/paywall_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final keyValueStore = SharedPreferencesStore(prefs);

  // Initialize Supabase if configured
  ResumeRemoteDataSource? remoteDataSource;
  ImageStorageService? imageStorage;
  AuthRepository? authRepository;

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    final client = Supabase.instance.client;
    remoteDataSource = ResumeRemoteDataSourceImpl(client);
    imageStorage = ImageStorageService(client);

    // Initialize Auth
    final authRemoteDs = AuthRemoteDataSourceImpl(client);
    authRepository = AuthRepositoryImpl(authRemoteDs);
  }

  // Initialize Subscription
  final subscriptionRepository = RevenueCatRepositoryImpl();
  await subscriptionRepository.init();

  // Initialize data sources and repositories
  final localDataSource = ResumeLocalDataSourceImpl(keyValueStore);
  final repository = ResumeBuilderRepositoryImpl(
    localDataSource,
    remoteDataSource: remoteDataSource,
    imageStorage: imageStorage,
    subscriptionRepository: subscriptionRepository,
  );

  runApp(
    MyApp(
      repository: repository,
      authRepository: authRepository,
      subscriptionRepository: subscriptionRepository,
      keyValueStore: keyValueStore,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ResumeBuilderRepository repository;
  final AuthRepository? authRepository;
  final SubscriptionRepository subscriptionRepository;
  final KeyValueStore keyValueStore;

  const MyApp({
    super.key,
    required this.repository,
    this.authRepository,
    required this.subscriptionRepository,
    required this.keyValueStore,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppLanguageCubit()),
        if (authRepository != null)
          BlocProvider(
            create: (_) => AuthBloc(
              authRepository: authRepository!,
              subscriptionRepository: subscriptionRepository,
            )..add(const AuthCheckRequested()),
          ),
        BlocProvider(
          create: (_) => SubscriptionBloc(
            subscriptionRepository,
            authRepository: authRepository,
          )..add(const SubscriptionInitialized()),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ResumeBuilderRepository>.value(value: repository),
          if (authRepository != null)
            RepositoryProvider<AuthRepository>.value(value: authRepository!),
          RepositoryProvider<SubscriptionRepository>.value(
            value: subscriptionRepository,
          ),
        ],
        child: MaterialApp(
          title: 'Resume Builder',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          home: authRepository != null ? const AuthWrapper() : const HomePage(),
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (context) => const RegisterPage());
      case '/forgot-password':
        return MaterialPageRoute(
          builder: (context) => const ForgotPasswordPage(),
        );
      case '/home':
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/builder':
        final draftId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => _builderPage(context, draftId),
        );
      case '/preview':
        // Support both old format (ResumeDraft) and new format (Map with draft and language)
        ResumeDraft draft;
        ResumeLanguage language = ResumeLanguage.english;

        if (settings.arguments is ResumeDraft) {
          draft = settings.arguments as ResumeDraft;
        } else if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          draft = args['draft'] as ResumeDraft;
          language =
              args['language'] as ResumeLanguage? ?? ResumeLanguage.english;
        } else {
          return null;
        }

        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => PreviewCubit()
              ..loadPreview(draft)
              ..changeLanguage(language),
            child: PreviewPage(draft: draft),
          ),
        );
      case '/templates':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => TemplatesPage(
            currentTemplate: args['template'],
            onTemplateChanged: args['onChanged'],
          ),
        );
      case '/paywall':
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => const PaywallWrapper(),
        );
      case '/subscription-details':
        return MaterialPageRoute(
          builder: (context) => const SubscriptionDetailsPage(),
        );
      default:
        return null;
    }
  }

  Widget _builderPage(BuildContext context, String? draftId) {
    // We need KeyValueStore here. It's not in context but available in main scope.
    // Wait, keyValueStore is local in main(). I should pass it to MyApp or provide via RepositoryProvider.
    // Actually, ResumeLocalDataSourceImpl uses it. I can access it via repository? No.
    // Better to propagate it or use GetIt/Provider.
    // For now, I'll pass it to MyApp.
    return BlocProvider(
      create: (context) => BuilderBloc(
        createDraft: CreateDraft(repository, subscriptionRepository),
        loadDraft: LoadDraft(repository),
        autosaveDraft: AutosaveDraft(repository),
        updateProfile: UpdateProfile(repository),
        updateContact: UpdateContact(repository),
        updateExperience: UpdateExperience(repository),
        updateEducation: UpdateEducation(repository),
        updateSkill: UpdateSkill(repository),
        updateProject: UpdateProject(repository),
        updateTemplate: UpdateTemplate(repository),
        removeItem: RemoveItem(repository),
        reorderItem: ReorderItem(repository),
        exportPdf: ExportPdf(repository, subscriptionRepository, keyValueStore),
      )..add(BuilderInitialized(draftId: draftId)),
      child: BuilderShellPage(draftId: draftId),
    );
  }
}

/// Wrapper widget that handles authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.authenticated:
            return const HomePage();
          case AuthStatus.unauthenticated:
          case AuthStatus.loading:
            return const HomePage();
        }
      },
    );
  }
}

/// Home page showing list of drafts and create new option
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ResumeDraft>? _drafts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
    _checkSubscriptionAndShowPaywall();
  }

  void _checkSubscriptionAndShowPaywall() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Delay slightly to let the UI settle
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      final subscriptionBloc = context.read<SubscriptionBloc>();
      final state = subscriptionBloc.state;

      // If we know the user is free, show paywall
      if (state.status == SubscriptionStatus.loaded &&
          state.userPlan == UserPlan.free) {
        Navigator.of(context).pushNamed('/paywall');
      }
    });
  }

  Future<void> _loadDrafts() async {
    setState(() => _isLoading = true);

    final repository = context.read<ResumeBuilderRepository>();
    final result = await LoadAllDrafts(repository).call();

    result.fold(
      onSuccess: (drafts) {
        setState(() {
          _drafts = drafts;
          _isLoading = false;
        });
      },
      onFailure: (failure) {
        setState(() {
          _drafts = [];
          _isLoading = false;
        });
      },
    );
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
          body: RefreshIndicator(
            onRefresh: _loadDrafts,
            child: CustomScrollView(
              slivers: [
                BlocBuilder<SubscriptionBloc, SubscriptionState>(
                  builder: (context, subState) {
                    final isPremium =
                        subState.status == SubscriptionStatus.loaded &&
                        subState.userPlan != UserPlan.free;

                    return SliverAppBar(
                      expandedHeight: isAuthenticated && user != null
                          ? 280.0
                          : kToolbarHeight,
                      pinned: true,
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      title: Text(
                        strings.appTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      centerTitle: true,
                      actions: [
                        if (!isPremium)
                          IconButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/paywall'),
                            icon: const Icon(
                              Icons.workspace_premium,
                              color: Colors.amber,
                            ),
                            tooltip: 'Upgrade to Pro',
                          ),
                        _buildLanguageSwitcher(
                          context,
                          appLanguage,
                          isDarkBackground: true,
                        ),
                        const SizedBox(width: 8),
                        if (authBloc != null)
                          _buildUserMenu(
                            context,
                            isAuthenticated,
                            strings,
                            isDarkBackground: true,
                          ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: isAuthenticated && user != null
                            ? _buildProfileFlexibleSpace(user, strings)
                            : null,
                      ),
                    );
                  },
                ),
                ..._buildDraftSlivers(strings, isAuthenticated),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _createNewResume(),
            icon: const Icon(Icons.add),
            label: Text(strings.newResume),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSwitcher(
    BuildContext context,
    AppLanguage currentLanguage, {
    bool isDarkBackground = false,
  }) {
    final bgColor = isDarkBackground
        ? Colors.white.withOpacity(0.2)
        : Colors.grey.shade200;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppLanguage.values.map((lang) {
          final isSelected = currentLanguage == lang;
          // When dark bg: Selected is White, Unselected is White w/ opacity
          // When light bg: Selected is Primary, Unselected is Grey

          Color activeBg = isDarkBackground
              ? Colors.white
              : Theme.of(context).primaryColor;
          Color activeText = isDarkBackground
              ? Theme.of(context).primaryColor
              : Colors.white;
          Color inactiveText = isDarkBackground
              ? Colors.white70
              : Colors.grey.shade700;

          return GestureDetector(
            onTap: () => context.read<AppLanguageCubit>().changeLanguage(lang),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                lang == AppLanguage.english ? 'EN' : 'TH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? activeText : inactiveText,
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
    AppStrings strings, {
    bool isDarkBackground = false,
  }) {
    if (!isAuthenticated) {
      return TextButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/login'),
        icon: Icon(
          Icons.login,
          size: 18,
          color: isDarkBackground ? Colors.white : null,
        ),
        label: Text(
          strings.signIn,
          style: TextStyle(color: isDarkBackground ? Colors.white : null),
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

  List<Widget> _buildDraftSlivers(AppStrings strings, bool isAuthenticated) {
    if (_isLoading) {
      return [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_drafts == null || _drafts!.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.noResumesYet,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.tapToCreateFirst,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      if (isAuthenticated)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Your Resumes',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final draft = _drafts![index];
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: _buildDraftCard(draft, strings),
          );
        }, childCount: _drafts!.length),
      ),
      // Add some bottom padding for FAB
      const SliverToBoxAdapter(child: SizedBox(height: 80)),
    ];
  }

  Widget _buildProfileFlexibleSpace(AppUser user, AppStrings strings) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).primaryColor, Colors.deepPurple.shade400],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    backgroundColor: Colors.white,
                    child: user.avatarUrl == null
                        ? Text(
                            user.initials,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(width: 8),
                    // PRO Badge
                    BlocBuilder<SubscriptionBloc, SubscriptionState>(
                      builder: (context, subState) {
                        if (subState.userPlan == UserPlan.subscription) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    InkWell(
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onTap: () => _showEditProfileDialog(
                        context,
                        user.displayName,
                        strings,
                      ),
                    ),
                  ],
                ),

                if (user.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                BlocBuilder<SubscriptionBloc, SubscriptionState>(
                  builder: (context, subState) {
                    if (subState.userPlan == UserPlan.subscription &&
                        subState.expirationDate != null) {
                      final date = subState.expirationDate!;
                      // Pad keys with 0 if needed (simple formatting)
                      final day = date.day.toString().padLeft(2, '0');
                      final month = date.month.toString().padLeft(2, '0');
                      final year = date.year;
                      return Text(
                        'Exp: $day/$month/$year',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftCard(ResumeDraft draft, AppStrings strings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openDraft(draft.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail/Icon
              Container(
                width: 56,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            draft.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildLanguageBadge(draft.resumeLanguage, strings),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      draft.profile.fullName.isEmpty
                          ? 'No name'
                          : draft.profile.fullName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(draft.updatedAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade500),
                        ),
                        const SizedBox(width: 16),
                        _buildCompletionBadge(draft.completionPercentage),
                        const SizedBox(width: 12),
                        Tooltip(
                          message: draft.isCloudSynced
                              ? 'Synced to Cloud'
                              : 'Local Only',
                          child: Icon(
                            draft.isCloudSynced
                                ? Icons.cloud_done
                                : Icons.cloud_off,
                            size: 16,
                            color: draft.isCloudSynced
                                ? Colors.blue.shade400
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleDraftAction(value, draft, strings),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 8),
                        Text(strings.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        const Icon(Icons.copy),
                        const SizedBox(width: 8),
                        Text(strings.duplicate),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          strings.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionBadge(double percentage) {
    final color = percentage >= 80
        ? Colors.green
        : percentage >= 50
        ? Colors.orange
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${percentage.toInt()}%',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLanguageBadge(
    ResumeLanguage resumeLanguage,
    AppStrings strings,
  ) {
    final isEnglish = resumeLanguage == ResumeLanguage.english;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isEnglish
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isEnglish
              ? Colors.blue.withValues(alpha: 0.3)
              : Colors.purple.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        isEnglish ? 'EN' : 'TH',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isEnglish ? Colors.blue.shade700 : Colors.purple.shade700,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showEditProfileDialog(
    BuildContext context,
    String currentName,
    AppStrings strings,
  ) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.editProfileName),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: strings.fullName,
            hintText: strings.enterYourName,
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                context.read<AuthBloc>().add(
                  AuthProfileUpdateRequested(fullName: newName),
                );
                Navigator.pop(context);
              }
            },
            child: Text(strings.save),
          ),
        ],
      ),
    );
  }

  void _createNewResume() {
    Navigator.of(context).pushNamed('/builder').then((_) => _loadDrafts());
  }

  void _openDraft(String draftId) {
    Navigator.of(
      context,
    ).pushNamed('/builder', arguments: draftId).then((_) => _loadDrafts());
  }

  void _handleDraftAction(
    String action,
    ResumeDraft draft,
    AppStrings strings,
  ) async {
    switch (action) {
      case 'edit':
        _openDraft(draft.id);
        break;
      case 'duplicate':
        // TODO: Implement duplicate
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(strings.confirmDelete),
            content: Text(strings.deleteResumeConfirm(draft.title)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(strings.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  strings.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true && mounted) {
          final repository = context.read<ResumeBuilderRepository>();
          await repository.deleteDraft(draft.id);
          _loadDrafts();
        }
        break;
    }
  }
}
