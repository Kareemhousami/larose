import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/navigation.dart';
import '../../theme/app_theme.dart';
import '../../app/routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// App settings screen with dark mode toggle and links to legal pages.
///
/// Dark mode preference is persisted via [AuthViewModel.toggleDarkMode].
class SettingsScreen extends StatelessWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

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
          onPressed: () => popOrGoTo(context, Routes.home),
        ),
        title: Text(
          'Settings',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.primary10),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
        children: [
          const SizedBox(height: 16),
          // Dark Mode
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.primary5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary10,
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Dark Mode',
                    style: AppTheme.bodyText(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                Switch(
                  value: authVm.isDarkMode,
                  onChanged: (_) => authVm.toggleDarkMode(),
                  activeThumbColor: AppTheme.primary,
                ),
              ],
            ),
          ),

          // Language
          _SettingsItem(
            icon: Icons.language,
            title: 'Language',
            trailing: Text(
              'English',
              style: AppTheme.bodyText(color: AppTheme.textMuted),
            ),
            onTap: () => _showInfoDialog(
              context,
              title: 'Language',
              content:
                  'English is currently the only supported language. Additional languages can be added here later.',
            ),
            isDark: isDark,
          ),

          // FAQ
          _SettingsItem(
            icon: Icons.help_outline,
            title: 'FAQ',
            onTap: () => Navigator.pushNamed(context, Routes.faq),
            isDark: isDark,
          ),

          // Contact Support
          _SettingsItem(
            icon: Icons.support_agent_outlined,
            title: 'Contact Support',
            onTap: () => Navigator.pushNamed(context, Routes.contact),
            isDark: isDark,
          ),

          // Privacy Policy
          _SettingsItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => Navigator.pushNamed(context, Routes.privacyPolicy),
            isDark: isDark,
          ),

          // Terms of Service
          _SettingsItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => Navigator.pushNamed(context, Routes.terms),
            isDark: isDark,
          ),

          // About
          _SettingsItem(
            icon: Icons.info_outline,
            title: 'About',
            trailing: Text(
              'v1.0.0',
              style: AppTheme.bodyText(color: AppTheme.textMuted),
            ),
            onTap: () => Navigator.pushNamed(context, Routes.about),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isDark;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.primary5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary10,
                borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyText(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimary,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

Future<void> _showInfoDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
