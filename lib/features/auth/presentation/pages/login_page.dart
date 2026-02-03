import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_language_cubit.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Auth strings for localization
class AuthStrings {
  final AppLanguage language;

  AuthStrings(this.language);

  bool get isEnglish => language == AppLanguage.english;

  String get welcomeBack => isEnglish ? 'Welcome Back' : 'ยินดีต้อนรับกลับ';
  String get signInToContinue =>
      isEnglish ? 'Sign in to continue' : 'ลงชื่อเข้าใช้เพื่อดำเนินการต่อ';
  String get createAccount => isEnglish ? 'Create Account' : 'สร้างบัญชี';
  String get signUpToGetStarted =>
      isEnglish ? 'Sign up to get started' : 'ลงทะเบียนเพื่อเริ่มต้น';
  String get email => isEnglish ? 'Email' : 'อีเมล';
  String get password => isEnglish ? 'Password' : 'รหัสผ่าน';
  String get confirmPassword =>
      isEnglish ? 'Confirm Password' : 'ยืนยันรหัสผ่าน';
  String get fullName => isEnglish ? 'Full Name' : 'ชื่อเต็ม';
  String get signIn => isEnglish ? 'Sign In' : 'เข้าสู่ระบบ';
  String get signUp => isEnglish ? 'Sign Up' : 'ลงทะเบียน';
  String get forgotPassword => isEnglish ? 'Forgot Password?' : 'ลืมรหัสผ่าน?';
  String get dontHaveAccount =>
      isEnglish ? "Don't have an account? " : 'ยังไม่มีบัญชี? ';
  String get alreadyHaveAccount =>
      isEnglish ? 'Already have an account? ' : 'มีบัญชีอยู่แล้ว? ';
  String get orContinueWith =>
      isEnglish ? 'Or continue with' : 'หรือดำเนินการต่อด้วย';
  String get resetPassword => isEnglish ? 'Reset Password' : 'รีเซ็ตรหัสผ่าน';
  String get enterEmailToReset => isEnglish
      ? 'Enter your email to receive a password reset link'
      : 'กรอกอีเมลเพื่อรับลิงก์รีเซ็ตรหัสผ่าน';
  String get sendResetLink => isEnglish ? 'Send Reset Link' : 'ส่งลิงก์รีเซ็ต';
  String get backToSignIn =>
      isEnglish ? 'Back to Sign In' : 'กลับไปเข้าสู่ระบบ';
  String get resetEmailSent => isEnglish
      ? 'Password reset email sent! Check your inbox.'
      : 'ส่งอีเมลรีเซ็ตรหัสผ่านแล้ว! ตรวจสอบกล่องจดหมาย';
  String get emailRequired =>
      isEnglish ? 'Email is required' : 'กรุณากรอกอีเมล';
  String get invalidEmail =>
      isEnglish ? 'Please enter a valid email' : 'กรุณากรอกอีเมลที่ถูกต้อง';
  String get passwordRequired =>
      isEnglish ? 'Password is required' : 'กรุณากรอกรหัสผ่าน';
  String get passwordTooShort => isEnglish
      ? 'Password must be at least 6 characters'
      : 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
  String get passwordsDoNotMatch =>
      isEnglish ? 'Passwords do not match' : 'รหัสผ่านไม่ตรงกัน';
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo/Icon
                            Icon(
                              Icons.description_rounded,
                              size: 80,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 24),

                            // Title
                            Text(
                              strings.welcomeBack,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.signInToContinue,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),

                            // Email field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
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
                            const SizedBox(height: 16),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleSignIn(),
                              decoration: InputDecoration(
                                labelText: strings.password,
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return strings.passwordRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/forgot-password',
                                  );
                                },
                                child: Text(strings.forgotPassword),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sign in button
                            FilledButton(
                              onPressed: state.isLoading ? null : _handleSignIn,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                                      strings.signIn,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                            const SizedBox(height: 24),

                            // Sign up link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  strings.dontHaveAccount,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/register',
                                    );
                                  },
                                  child: Text(strings.signUp),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    strings.orContinueWith,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Google Sign-In button
                            OutlinedButton.icon(
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(
                                        const AuthSignInWithGoogleRequested(),
                                      );
                                    },
                              icon: const Icon(
                                Icons.circle,
                                color: Colors.red,
                              ), // Placeholder for Google Logo
                              label: const Text('Google'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Guest mode button
                            OutlinedButton.icon(
                              onPressed: () {
                                // Navigator.pushReplacementNamed(context, '/home');
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              },
                              icon: const Icon(Icons.person_outline),
                              label: Text(strings.continueAsGuest),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
