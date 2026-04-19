import 'package:flutter/material.dart';
import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';

/// Displays the La Rose terms of service.
class TermsScreen extends StatelessWidget {
  /// Creates a [TermsScreen].
  const TermsScreen({super.key});

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
          'Terms of Service',
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
              'Terms of Service',
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
              'Acceptance of Terms',
              'By accessing or using the La Rose application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.',
              isDark,
            ),
            _buildSection(
              'Orders and Payments',
              'All orders placed through La Rose are subject to acceptance and availability. Prices are displayed in USD and are subject to change. Payment is processed securely at the time of order.',
              isDark,
            ),
            _buildSection(
              'Delivery',
              'We aim to deliver all orders within the estimated timeframe. Delivery times may vary based on location and availability. La Rose is not responsible for delays caused by external factors.',
              isDark,
            ),
            _buildSection(
              'Returns and Refunds',
              'Due to the perishable nature of flowers, returns are handled on a case-by-case basis. If you receive damaged or incorrect items, please contact us within 24 hours.',
              isDark,
            ),
            _buildSection(
              'Limitation of Liability',
              'La Rose shall not be liable for any indirect, incidental, or consequential damages arising from the use of our services.',
              isDark,
            ),
            _buildSection(
              'Contact',
              'For questions regarding these Terms, please contact us at legal@larose.com.',
              isDark,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Builds a terms section with a title and body text.
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
