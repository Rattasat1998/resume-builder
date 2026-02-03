import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';

/// Forgot Password Page
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthPasswordResetRequested(email: _emailController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLanguageCubit, AppLanguage>(
      builder: (context, appLanguage) {
        final strings = AuthStrings(appLanguage);

        return BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
              context.read<AuthBloc>().add(const AuthErrorCleared());
            }
            if (state.passwordResetSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(strings.resetEmailSent),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(strings.resetPassword),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Icon
                            Icon(
                              Icons.lock_reset_rounded,
                              size: 80,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 24),

                            // Title
                            Text(
                              strings.resetPassword,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.enterEmailToReset,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),

                            // Email field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleResetPassword(),
                              decoration: InputDecoration(
                                labelText: strings.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return strings.emailRequired;
                                }
                                if (!value.contains('@')) {
                                  return strings.invalidEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Send reset link button
                            FilledButton(
                              onPressed: state.isLoading ? null : _handleResetPassword,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: state.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      strings.sendResetLink,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                            const SizedBox(height: 16),

                            // Back to sign in
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(strings.backToSignIn),
                            ),
                          ],
                        ),
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

