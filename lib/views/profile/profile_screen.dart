import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../app/routes.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/bottom_nav_bar.dart';

/// Profile screen showing user info and navigation to profile sub-screens.
///
/// Displays avatar, name, email, and menu items for orders, addresses,
/// cash-on-delivery info, notifications, privacy, and settings.
class ProfileScreen extends StatelessWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authVm = context.watch<AuthViewModel>();
    final user = authVm.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
                .withValues(alpha: 0.8),
        title: Text(
          'Profile',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.primary),
            onPressed: () => Navigator.pushNamed(context, Routes.settings),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.primary10),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.paddingHorizontal)
            .copyWith(bottom: 80),
        children: [
          const SizedBox(height: 16),
          // User avatar and info
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primary10,
                  backgroundImage:
                      user?.image.isNotEmpty == true
                          ? NetworkImage(user!.image)
                          : null,
                  child: user?.image.isNotEmpty != true
                      ? const Icon(Icons.person,
                          size: 40, color: AppTheme.primary)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? 'Guest User',
                  style: AppTheme.sectionHeader(
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'guest@larose.com',
                  style: AppTheme.bodyText(color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.editProfile),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary10,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text('Edit Profile',
                        style: AppTheme.categoryChip(color: AppTheme.primary)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Menu items
          _ProfileMenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'My Orders',
            onTap: () => Navigator.pushNamed(context, Routes.orders),
            isDark: isDark,
          ),
          if (authVm.isAdmin)
            _ProfileMenuItem(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Manage Orders',
              onTap: () => Navigator.pushNamed(context, Routes.adminOrders),
              isDark: isDark,
            ),
          _ProfileMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Addresses',
            onTap: () => Navigator.pushNamed(context, Routes.addresses),
            isDark: isDark,
          ),
          _ProfileMenuItem(
            icon: Icons.payment_outlined,
            title: 'Payment Info',
            onTap: () => Navigator.pushNamed(context, Routes.addPayment),
            isDark: isDark,
          ),
          _ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () =>
                Navigator.pushNamed(context, Routes.notifications),
            isDark: isDark,
          ),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => Navigator.pushNamed(context, Routes.contact),
            isDark: isDark,
          ),
          _ProfileMenuItem(
            icon: Icons.shield_outlined,
            title: 'Privacy & Security',
            onTap: () =>
                Navigator.pushNamed(context, Routes.privacySecurity),
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Logout
          GestureDetector(
            onTap: () async {
              await authVm.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, Routes.login, (route) => false);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.primary5,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Log Out',
                      style: AppTheme.productCardTitle(
                          color: AppTheme.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: -1),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.primary5),
          ),
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
                  color:
                      isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
      ),
    );
  }
}
