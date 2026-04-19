import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../app/routes.dart';
import '../viewmodels/cart_viewmodel.dart';

/// Custom bottom navigation bar matching the La Rose design.
///
/// 5 tabs: Home, Shop, Favorites, Orders, Cart.
/// Active tab uses primary color with filled icon and bold label.
class BottomNavBar extends StatelessWidget {
  /// The currently selected tab index (0-4).
  final int currentIndex;

  /// Creates a [BottomNavBar] with the given [currentIndex].
  const BottomNavBar({super.key, required this.currentIndex});

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront,
        label: 'Shop'),
    _NavItem(
        icon: Icons.favorite_border,
        activeIcon: Icons.favorite,
        label: 'Favorites'),
    _NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Orders'),
    _NavItem(
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag,
        label: 'Cart'),
  ];

  static const List<String> _routes = [
    Routes.home,
    Routes.shop,
    Routes.favorites,
    Routes.orders,
    Routes.cart,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final backgroundColor = isDark ? AppTheme.navDark : AppTheme.surface;
    final activePillColor =
        isDark ? AppTheme.primary.withValues(alpha: 0.22) : AppTheme.primary;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(color: AppTheme.primary10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 6, 10, bottomInset > 0 ? 4 : 6),
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isActive = index == currentIndex;
                final color = isActive
                    ? Colors.white
                    : (isDark ? AppTheme.textMutedDark : AppTheme.textMuted);
                final iconWidget = Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: color,
                  size: 20,
                );

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () {
                        if (index == currentIndex) return;
                        Navigator.pushReplacementNamed(context, _routes[index]);
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? activePillColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(
                                      alpha: isDark ? 0.18 : 0.28,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              width: 32,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white.withValues(
                                        alpha: isDark ? 0.14 : 0.18,
                                      )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: index == 4
                                  ? Builder(
                                      builder: (context) {
                                        final cart =
                                            Provider.of<CartViewModel?>(
                                          context,
                                        );

                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Center(child: iconWidget),
                                            if ((cart?.itemCount ?? 0) > 0)
                                              Positioned(
                                                top: -2,
                                                right: -2,
                                                child: Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                    minWidth: 14,
                                                    minHeight: 14,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isActive
                                                        ? Colors.white
                                                        : AppTheme.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          7,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${cart!.itemCount}',
                                                      style: AppTheme.navLabel(
                                                        active: true,
                                                        color: isActive
                                                            ? AppTheme.primary
                                                            : Colors.white,
                                                      ).copyWith(fontSize: 8),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    )
                                  : iconWidget,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.navLabel(
                                active: isActive,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
