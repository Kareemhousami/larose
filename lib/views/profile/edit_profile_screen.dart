import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/primary_button.dart';

/// Screen for editing user profile information.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final result = await context.read<AuthViewModel>().updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Profile updated successfully.'),
        ),
      );
      popOrGoTo(context, Routes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
                .withValues(alpha: 0.8),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
          onPressed: () => popOrGoTo(context, Routes.profile),
        ),
        title: Text(
          'Edit Profile',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(hintText: 'First Name'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(hintText: 'Last Name'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Email'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
              if (authVm.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  authVm.error!,
                  style: AppTheme.bodyText(color: Colors.red),
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Save Changes',
                isLoading: authVm.isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
