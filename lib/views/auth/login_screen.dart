import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/primary_button.dart';

/// Login screen with email and password fields.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final success = await context.read<AuthViewModel>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );
    if (!mounted) {
      return;
    }
    if (success) {
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  void _goToSignup() {
    context.read<AuthViewModel>().clearError();
    Navigator.pushReplacementNamed(context, Routes.signup);
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
                      border: Border.all(color: AppTheme.primary20),
                    ),
                    child: const Icon(
                      Icons.local_florist,
                      size: 30,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'La Rose',
                    style: AppTheme.brandWordmark(fontSize: 32),
                  ),
                  const SizedBox(height: 4),
                  Container(height: 1, width: 48, color: AppTheme.primary30),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome Back',
                    style: AppTheme.sectionHeader(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ).copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage your orders, favorites, and cart',
                    style: AppTheme.bodyText(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: AppTheme.primary60,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter your email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppTheme.primary60,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                        icon: Icon(
                          _isPasswordObscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.primary60,
                        ),
                      ),
                    ),
                    obscureText: _isPasswordObscured,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter your password'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, Routes.forgotPassword),
                      child: Text(
                        'Forgot Password?',
                        style: AppTheme.bodyText(color: AppTheme.primary)
                            .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (authVm.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AuthErrorNotice(
                        message: authVm.error!,
                        actionLabel:
                            authVm.errorAction == AuthErrorAction.goToSignup
                                ? 'Create account'
                                : null,
                        onAction:
                            authVm.errorAction == AuthErrorAction.goToSignup
                                ? _goToSignup
                                : null,
                      ),
                    ),
                  PrimaryButton(
                    text: 'Sign In',
                    isLoading: authVm.isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTheme.bodyText(color: AppTheme.textMuted),
                      ),
                      GestureDetector(
                        onTap: _goToSignup,
                        child: Text(
                          'Join the Garden',
                          style: AppTheme.bodyText(color: AppTheme.primary)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
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

class _AuthErrorNotice extends StatelessWidget {
  const _AuthErrorNotice({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final hasAction = actionLabel != null && onAction != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary5,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.primary20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.primary10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasAction
                      ? Icons.mark_email_unread_outlined
                      : Icons.error_outline_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTheme.bodyText(
                    color: AppTheme.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (hasAction) ...[
            const SizedBox(height: 12),
            Text(
              'You can create one in just a moment.',
              style: AppTheme.productCardSubtitle(
                color: AppTheme.textSubtle,
              ).copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primary20),
                  foregroundColor: AppTheme.primary,
                  backgroundColor: Colors.white.withValues(alpha: 0.55),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
