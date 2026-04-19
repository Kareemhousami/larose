import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/navigation.dart';
import '../../theme/app_theme.dart';
import '../../app/routes.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirmation_dialog.dart';

/// Displays cart items with quantity controls and a checkout button.
///
/// Uses [CartViewModel] to read/modify cart state.
class CartScreen extends StatelessWidget {
  /// Creates a [CartScreen].
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartVm = context.watch<CartViewModel>();

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
          onPressed: () => popOrGoTo(context, Routes.shop),
        ),
        title: Text(
          'Your Cart',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_bag_outlined,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
            tooltip: 'Clear cart',
            onPressed: cartVm.items.isEmpty
                ? null
                : () => _confirmClearCart(context, cartVm),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.primary10),
        ),
      ),
      body: cartVm.items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add some beautiful flowers!',
              actionLabel: 'Start Shopping',
              onAction: () => Navigator.pushNamed(context, Routes.shop),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
                    itemCount: cartVm.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final item = cartVm.items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.surfaceDark
                              : AppTheme.surface,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusXl,
                          ),
                          border: Border.all(color: AppTheme.primary5),
                        ),
                        child: Row(
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusLg,
                              ),
                              child: Image.network(
                                item.product.thumbnail,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 80,
                                  height: 80,
                                  color: AppTheme.primary5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.title,
                                    style: AppTheme.productCardTitle(
                                      color: isDark
                                          ? AppTheme.textPrimaryDark
                                          : AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)}',
                                    style: AppTheme.productPriceShop(),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity controls
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      cartVm.removeFromCart(item.product.id),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: AppTheme.textMuted,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _QuantityButton(
                                      icon: Icons.remove,
                                      onTap: () => cartVm.updateQuantity(
                                        item.product.id,
                                        item.quantity - 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: AppTheme.productCardTitle(
                                          color: isDark
                                              ? AppTheme.textPrimaryDark
                                              : AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    _QuantityButton(
                                      icon: Icons.add,
                                      onTap: () => cartVm.updateQuantity(
                                        item.product.id,
                                        item.quantity + 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Checkout section
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
                    border: Border(top: BorderSide(color: AppTheme.primary10)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: AppTheme.sectionHeader(
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '\$${cartVm.totalPrice.toStringAsFixed(2)}',
                            style: AppTheme.productPriceHome().copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        text: 'Checkout',
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.checkout),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
        child: Ink(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primary10,
            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          ),
          child: Icon(icon, size: 16, color: AppTheme.primary),
        ),
      ),
    );
  }
}

Future<void> _confirmClearCart(
  BuildContext context,
  CartViewModel cartVm,
) async {
  final shouldClear = await showConfirmationDialog(
    context,
    title: 'Clear cart?',
    message: 'Remove all items from your cart?',
    confirmLabel: 'Clear',
    isDestructive: true,
  );

  if (shouldClear == true) {
    await cartVm.clearCart();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart cleared.')));
    }
  }
}
