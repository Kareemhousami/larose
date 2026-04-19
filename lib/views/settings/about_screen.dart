import 'package:flutter/material.dart';
import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';

/// About Us screen with La Rose branding, mission, and company story.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'About ',
                style: AppTheme.sectionHeader(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimary,
                ),
              ),
              TextSpan(
                text: 'La Rose',
                style: AppTheme.brandWordmark(
                  color: AppTheme.primary,
                  fontSize: 28,
                ),
              ),
            ],
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
            // Brand header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary10,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_florist,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('La Rose', style: AppTheme.brandWordmark(fontSize: 30)),
                  const SizedBox(height: 4),
                  Text(
                    'Flower Delivery, Reimagined',
                    style: AppTheme.bodyText(color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Our Story
            _SectionCard(
              icon: Icons.auto_stories,
              title: 'Our Story',
              body:
                  'La Rose was born from a simple belief: every moment deserves the perfect bloom. '
                  'Founded with a passion for connecting people through flowers, we have grown from a '
                  'small local florist into a beloved delivery service trusted by thousands.',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Mission
            _SectionCard(
              icon: Icons.eco,
              title: 'Our Mission',
              body:
                  'We source only the freshest blooms from sustainable farms around the globe. '
                  'Every arrangement is crafted by hand with care, ensuring your moments are '
                  'perfectly fragrant. We believe in responsible sourcing, zero-waste packaging, '
                  'and delivering joy to your doorstep.',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Values
            _SectionCard(
              icon: Icons.favorite_outline,
              title: 'Our Values',
              body:
                  'Quality: We never compromise on the freshness of our flowers.\n'
                  'Sustainability: Eco-friendly practices from farm to door.\n'
                  'Care: Every bouquet is arranged with love and attention to detail.\n'
                  'Community: Supporting local growers and artisan florists.',
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // App version
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Version 1.0.0',
                  style: AppTheme.productCardSubtitle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool isDark;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.heroPadding),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.primary5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary20,
                  borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.sectionHeader(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
