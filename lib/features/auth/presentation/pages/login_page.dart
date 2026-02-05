import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

// Auth strings for localization
class AuthStrings {
  final AppLanguage language;

  AuthStrings(this.language);

  bool get isEnglish => language == AppLanguage.english;

  String get welcomeBack => isEnglish ? 'Welcome Back' : 'ยินดีต้อนรับกลับ';
  String get signInToContinue =>
      isEnglish ? 'Sign in to continue' : 'ลงชื่อเข้าใช้เพื่อดำเนินการต่อ';
  String get continueWithGoogle =>
      isEnglish ? 'Continue with Google' : 'ดำเนินการต่อด้วย Google';
  String get continueAsGuest =>
      isEnglish ? 'Continue as Guest' : 'ดำเนินการต่อในฐานะผู้เยี่ยมชม';
  String get guestModeNote => isEnglish
      ? 'Your resumes will only be saved locally'
      : 'ประวัติของคุณจะถูกบันทึกในเครื่องเท่านั้น';
}

/// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageCubit, AppLanguage>(
      builder: (context, appLanguage) {
        final strings = AuthStrings(appLanguage);

        return BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.isAuthenticated) {
              Navigator.of(context).pop();
            }
            if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
              context.read<AuthBloc>().add(const AuthErrorCleared());
            }
          },
          builder: (context, state) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo/Icon
                          Icon(
                            Icons.description_rounded,
                            size: 100,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 32),

                          // Title
                          Text(
                            strings.welcomeBack,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            strings.signInToContinue,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Google Sign-In button
                          if (state.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            OutlinedButton.icon(
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  const AuthSignInWithGoogleRequested(),
                                );
                              },
                              icon: const Icon(
                                Icons.circle, // Placeholder for Google Logo
                                color: Colors.red,
                              ),
                              label: Text(strings.continueWithGoogle),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Guest mode button
                          if (!state.isLoading) ...[
                            TextButton.icon(
                              onPressed: () {
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              },
                              icon: const Icon(Icons.person_outline),
                              label: Text(strings.continueAsGuest),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                foregroundColor: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.guestModeNote,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
