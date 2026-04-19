import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';

/// Forgot password screen — allows users to request a password reset email.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authVm = context.read<AuthViewModel>();
    await authVm.resetPassword(_emailController.text.trim());

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _emailSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset email sent! Check your inbox.'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
          onPressed: () => popOrGoTo(context, Routes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primary10,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 30,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Reset Password',
                    style: AppTheme.sectionHeader(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ).copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyText(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter your email'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  if (_emailSent)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reset link sent!',
                            style: AppTheme.bodyText(
                              color: AppTheme.primary,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  PrimaryButton(
                    text: _emailSent ? 'Resend Link' : 'Send Reset Link',
                    isLoading: _isLoading,
                    onPressed: _handleReset,
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => popOrGoTo(context, Routes.login),
                    child: Text(
                      'Back to Sign In',
                      style: AppTheme.bodyText(
                        color: AppTheme.primary,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
