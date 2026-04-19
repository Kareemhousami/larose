import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';

/// Entry screen for shopping flows.
class ShopScreen extends StatelessWidget {
  /// Creates a [ShopScreen].
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? AppTheme.backgroundDark
            : AppTheme.backgroundLight,
        title: Text('Shop', style: AppTheme.appBarTitle(isShop: true)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose How To Browse',
              style: AppTheme.sectionHeader(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick one clear path: shop by event or shop by flower type.',
              style: AppTheme.bodyText(
                color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
              ),
            ),
            const SizedBox(height: 24),
            _BrowseCard(
              icon: Icons.grid_view_rounded,
              eyebrow: 'SHOP BY EVENT',
              title: 'Browse Events',
              description:
                  'See all events first, then open one collection at a time.',
              buttonLabel: 'Open Events',
              onTap: () => Navigator.pushNamed(context, Routes.shopCategories),
            ),
            const SizedBox(height: 16),
            _BrowseCard(
              icon: Icons.local_florist_rounded,
              eyebrow: 'SHOP BY TYPE',
              title: 'Browse Flower Types',
              description:
                  'Explore roses, tulips, lilies, and more as separate flower groups.',
              buttonLabel: 'Open Types',
              onTap: () => Navigator.pushNamed(context, Routes.shopTypes),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

class _BrowseCard extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  const _BrowseCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.primary10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary10,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            eyebrow,
            style: AppTheme.categoryChip(
              color: AppTheme.primary,
            ).copyWith(fontSize: 11, letterSpacing: 1.1),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTheme.sectionHeader(
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ).copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTheme.bodyText(
              color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
