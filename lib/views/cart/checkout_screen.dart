import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../models/address.dart';
import '../../models/cart_item.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/address_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/orders_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/primary_button.dart';

/// Checkout screen that creates a real cash-on-delivery order.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedAddressId;
  String? _lastPricingKey;

  void _loadPricingIfNeeded({
    required Address address,
    required List<CartItem> items,
  }) {
    final total = items.fold<double>(0, (s, item) => s + item.totalPrice);
    // Reuse the last successful request key to avoid repeated pricing calls during rebuilds.
    final key = '${address.id}_${items.length}_$total';
    if (key == _lastPricingKey) return;
    _lastPricingKey = key;
    context.read<OrdersViewModel>().loadCheckoutPricing(
      shippingAddress: address,
      items: items,
    );
  }

  Future<void> _placeOrder(Address address) async {
    final cartVm = context.read<CartViewModel>();
    final ordersVm = context.read<OrdersViewModel>();

    final orderId = await ordersVm.placeCashOnDeliveryOrder(
      shippingAddress: address,
      items: cartVm.items,
    );
    if (!mounted || orderId == null) {
      return;
    }
    await cartVm.clearCart();
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.confirmation,
      (route) => false,
      arguments: {'orderId': orderId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartVm = context.watch<CartViewModel>();
    final ordersVm = context.watch<OrdersViewModel>();
    final addressVm = context.watch<AddressViewModel>();
    final addresses = addressVm.addresses;

    if (addresses.isEmpty) {
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
            onPressed: () => popOrGoTo(context, Routes.cart),
          ),
          title: Text(
            'Checkout',
            style: AppTheme.sectionHeader(
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: EmptyState(
          icon: Icons.location_on_outlined,
          title: 'Add a delivery address to continue',
          subtitle: 'Save a pinned map location before placing your order.',
          actionLabel: 'Add Address',
          onAction: () => Navigator.pushNamed(context, Routes.addAddress),
        ),
      );
    }

    final selectedAddress = addresses.firstWhere(
      (address) => address.id == _selectedAddressId,
      // Fall back to a stable address so checkout still works before the user taps anything.
      orElse: () => addressVm.defaultAddress ?? addresses.first,
    );

    if (cartVm.items.isNotEmpty) {
      // Trigger pricing from build, but guard it with the request key above.
      _loadPricingIfNeeded(address: selectedAddress, items: cartVm.items);
    }

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
          onPressed: () => popOrGoTo(context, Routes.cart),
        ),
        title: Text(
          'Checkout',
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Address',
                  style: AppTheme.sectionHeader(
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.addAddress),
                  child: const Text('Add New'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...addresses.map(
              (address) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AddressOptionCard(
                  address: address,
                  isSelected: address.id == selectedAddress.id,
                  onTap: () {
                    setState(() {
                      _selectedAddressId = address.id;
                      _lastPricingKey = null;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.cardPadding),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(color: AppTheme.primary5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Payment method: Cash on Delivery',
                      style: AppTheme.bodyText(
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Order Summary',
              style: AppTheme.sectionHeader(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...cartVm.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.title} x${item.quantity}',
                        style: AppTheme.bodyText(
                          color: isDark
                              ? AppTheme.textSubtleDark
                              : AppTheme.textSubtle,
                        ),
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: AppTheme.productCardTitle(
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (ordersVm.checkoutSubtotalAmount != null)
              _SummaryRow(
                label: 'Products',
                amount: ordersVm.checkoutSubtotalAmount!,
                isDark: isDark,
              ),
            if (ordersVm.checkoutDeliveryFee != null)
              _SummaryRow(
                label: 'Delivery',
                amount: ordersVm.checkoutDeliveryFee!,
                isDark: isDark,
              ),
            const Divider(),
            _SummaryRow(
              label: 'Total',
              amount: ordersVm.checkoutTotalAmount ?? cartVm.totalPrice,
              isDark: isDark,
              emphasize: true,
            ),
            if (ordersVm.checkoutPricingError != null) ...[
              const SizedBox(height: 12),
              Text(
                ordersVm.checkoutPricingError!,
                style: AppTheme.bodyText(color: Colors.red),
              ),
            ],
            if (ordersVm.error != null) ...[
              const SizedBox(height: 12),
              Text(
                ordersVm.error!,
                style: AppTheme.bodyText(color: Colors.red),
              ),
            ],
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Place Order',
              isLoading: ordersVm.isLoading,
              // Disable submission until pricing is known so the total cannot drift.
              onPressed: cartVm.items.isEmpty ||
                      ordersVm.checkoutTotalAmount == null ||
                      ordersVm.checkoutPricingError != null
                  ? null
                  : () => _placeOrder(selectedAddress),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _AddressOptionCard extends StatelessWidget {
  const _AddressOptionCard({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final Address address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.cardPadding),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.primary5,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.locationLabel.isNotEmpty
                        ? address.locationLabel
                        : address.shortLabel,
                    style: AppTheme.productCardTitle(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ),
                  ),
                  if (address.deliveryNote.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      address.deliveryNote,
                      style: AppTheme.bodyText(
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                  if (address.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(address.phone, style: AppTheme.productCardSubtitle()),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.isDark,
    this.emphasize = false,
  });

  final String label;
  final double amount;
  final bool isDark;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: emphasize
                ? AppTheme.sectionHeader(
                    color:
                        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  )
                : AppTheme.bodyText(
                    color:
                        isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
                  ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: emphasize
                ? AppTheme.productPriceHome()
                : AppTheme.productCardTitle(
                    color:
                        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }
}
