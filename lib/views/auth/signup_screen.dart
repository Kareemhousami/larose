import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../app/routes.dart';
import '../../widgets/primary_button.dart';

/// Sign up screen with name, email, and password fields.
///
/// Uses [AuthViewModel] to register a new user.
class SignupScreen extends StatefulWidget {
  /// Creates a [SignupScreen].
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    final authVm = context.read<AuthViewModel>();
    final success = await authVm.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  void _goToLogin() {
    context.read<AuthViewModel>().clearError();
    Navigator.pushReplacementNamed(context, Routes.login);
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
                  // Header
                  Text(
                    'Join the Garden',
                    style: AppTheme.sectionHeader(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ).copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LA ROSE',
                    style: AppTheme.specialOfferTag(),
                  ),
                  const SizedBox(height: 32),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppTheme.primary60,
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
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
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your email' : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
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
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 12),

                  // Error
                  if (authVm.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AuthErrorNotice(
                        message: authVm.error!,
                        actionLabel:
                            authVm.errorAction == AuthErrorAction.goToLogin
                                ? 'Go to login'
                                : null,
                        onAction:
                            authVm.errorAction == AuthErrorAction.goToLogin
                                ? _goToLogin
                                : null,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Create Account button
                  PrimaryButton(
                    text: 'Create Account',
                    isLoading: authVm.isLoading,
                    onPressed: _handleSignup,
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTheme.bodyText(color: AppTheme.textMuted),
                      ),
                      GestureDetector(
                        onTap: _goToLogin,
                        child: Text(
                          'Login',
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
                      ? Icons.person_add_alt_rounded
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
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (hasAction) ...[
            const SizedBox(height: 12),
            Text(
              'You can sign in with your existing account instead.',
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
