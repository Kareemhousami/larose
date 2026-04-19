import 'package:flutter/material.dart';
import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';

/// Displays the La Rose privacy policy.
class PrivacyPolicyScreen extends StatelessWidget {
  /// Creates a [PrivacyPolicyScreen].
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          onPressed: () => popOrGoTo(context, Routes.settings),
        ),
        title: Text(
          'Privacy Policy',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Privacy Policy',
              style: AppTheme.sectionHeader(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: April 2026',
              style: AppTheme.productCardSubtitle(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
              'We collect information you provide directly, such as your name, email address, shipping address, and payment information when you create an account or place an order.',
              isDark,
            ),
            _buildSection(
              'How We Use Your Information',
              'We use your information to process orders, communicate with you about your purchases, send promotional offers (with your consent), and improve our services.',
              isDark,
            ),
            _buildSection(
              'Data Security',
              'We implement appropriate security measures to protect your personal information. Payment data is encrypted and processed through secure payment providers.',
              isDark,
            ),
            _buildSection(
              'Your Rights',
              'You have the right to access, update, or delete your personal information at any time through your profile settings or by contacting our support team.',
              isDark,
            ),
            _buildSection(
              'Contact Us',
              'If you have questions about this Privacy Policy, please contact us at privacy@larose.com.',
              isDark,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Builds a policy section with a title and body text.
  Widget _buildSection(String title, String body, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.productCardTitle(
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTheme.bodyText(
              color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
