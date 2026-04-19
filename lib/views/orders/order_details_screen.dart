import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/orders_viewmodel.dart';
import '../../widgets/order_status_badge.dart';
import '../../widgets/primary_button.dart';

/// Full order details screen showing items, total, address, and tracking link.
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Future<Order?>? _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = context.read<OrdersViewModel>().getOrder(widget.orderId);
  }

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
          onPressed: () => popOrGoTo(context, Routes.orders),
        ),
        title: Text(
          'Order Details',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Order?>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }
          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Order header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.cardPadding),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.primary5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
                            style: AppTheme.sectionHeader(
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Placed ${_formatDate(order.createdAt)}',
                        style: AppTheme.productCardSubtitle(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cash on Delivery',
                        style: AppTheme.productCardSubtitle(
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Items
                Text(
                  'Items',
                  style: AppTheme.sectionHeader(
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusDefault,
                          ),
                          child: Image.network(
                            item.product.thumbnail,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 56,
                              height: 56,
                              color: AppTheme.primary5,
                              child: const Icon(
                                Icons.image,
                                color: AppTheme.textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              Text(
                                'Qty: ${item.quantity}',
                                style: AppTheme.productCardSubtitle(),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: AppTheme.productPriceShop(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pricing breakdown
                if (order.subtotalAmount != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Products',
                        style: AppTheme.bodyText(
                          color: isDark
                              ? AppTheme.textSubtleDark
                              : AppTheme.textSubtle,
                        ),
                      ),
                      Text(
                        '\$${order.subtotalAmount!.toStringAsFixed(2)}',
                        style: AppTheme.productPriceShop(),
                      ),
                    ],
                  ),
                ],
                if (order.deliveryFee != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery',
                        style: AppTheme.bodyText(
                          color: isDark
                              ? AppTheme.textSubtleDark
                              : AppTheme.textSubtle,
                        ),
                      ),
                      Text(
                        '\$${order.deliveryFee!.toStringAsFixed(2)}',
                        style: AppTheme.productPriceShop(),
                      ),
                    ],
                  ),
                ],
                Divider(color: AppTheme.primary10),
                const SizedBox(height: 8),
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
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: AppTheme.productPriceHome(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Shipping address
                if (order.shippingAddress.isNotEmpty) ...[
                  Text(
                    'Shipping Address',
                    style: AppTheme.sectionHeader(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            order.shippingAddress,
                            style: AppTheme.bodyText(
                              color: isDark
                                  ? AppTheme.textSubtleDark
                                  : AppTheme.textSubtle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Track order button
                PrimaryButton(
                  text: 'Track Order',
                  onPressed: () => Navigator.pushNamed(
                    context,
                    Routes.orderTracking.replaceFirst(':id', order.id),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
