import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';

/// Contact / Support screen with contact info and support options.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

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
          'Help & Support',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primary10,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 32,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'How can we help?',
                    style: AppTheme.sectionHeader(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'We\'re here for you',
                    style: AppTheme.bodyText(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Contact methods
            _ContactTile(
              icon: Icons.email_outlined,
              title: 'Email Us',
              subtitle: 'support@larose.com',
              onTap: () => _copyToClipboard(context, 'support@larose.com'),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _ContactTile(
              icon: Icons.phone_outlined,
              title: 'Call Us',
              subtitle: '+961 1 234 567',
              onTap: () => _copyToClipboard(context, '+9611234567'),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _ContactTile(
              icon: Icons.chat_outlined,
              title: 'WhatsApp',
              subtitle: '+961 71 234 567',
              onTap: () => _copyToClipboard(context, '+96171234567'),
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Operating hours
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.cardPadding),
              decoration: BoxDecoration(
                color: AppTheme.primary5,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Operating Hours',
                        style: AppTheme.productCardTitle(
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _HoursRow(
                    day: 'Monday - Friday',
                    hours: '8:00 AM - 8:00 PM',
                    isDark: isDark,
                  ),
                  _HoursRow(
                    day: 'Saturday',
                    hours: '9:00 AM - 6:00 PM',
                    isDark: isDark,
                  ),
                  _HoursRow(
                    day: 'Sunday',
                    hours: '10:00 AM - 4:00 PM',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Response time note
            Center(
              child: Text(
                'We typically respond within 24 hours.',
                style: AppTheme.productCardSubtitle(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.cardPadding),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.primary5),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.productCardTitle(
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                    Text(subtitle, style: AppTheme.productCardSubtitle()),
                  ],
                ),
              ),
              const Icon(Icons.copy, color: AppTheme.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String hours;
  final bool isDark;

  const _HoursRow({
    required this.day,
    required this.hours,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: AppTheme.bodyText(
              color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
            ),
          ),
          Text(
            hours,
            style: AppTheme.productCardTitle(
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
