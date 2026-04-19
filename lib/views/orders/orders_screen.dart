import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/orders_viewmodel.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/order_status_badge.dart';
import '../../widgets/empty_state.dart';

/// Displays the signed-in user's Firestore-backed orders.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersViewModel>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersVm = context.watch<OrdersViewModel>();
    final orders = ordersVm.orders;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
                .withValues(alpha: 0.8),
        title: Text(
          'My Orders',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ordersVm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : orders.isEmpty
              ? EmptyState(
                  icon: Icons.receipt_long,
                  title: 'No orders yet',
                  subtitle: 'Your order history will appear here.',
                  actionLabel: 'Start Shopping',
                  onAction: () => Navigator.pushNamed(context, Routes.shop),
                )
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => context.read<OrdersViewModel>().refresh(),
                  child: ListView.separated(
                  padding: const EdgeInsets.all(AppTheme.paddingHorizontal)
                      .copyWith(bottom: 80),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => _OrderCard(order: orders[index]),
                ),
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 300;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              Routes.orderTracking.replaceFirst(':id', order.id),
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.cardPadding),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(color: AppTheme.primary5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCompact)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OrderCardHeader(order: order, isDark: isDark),
                        const SizedBox(height: 10),
                        OrderStatusBadge(status: order.status),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _OrderCardHeader(order: order, isDark: isDark),
                        ),
                        const SizedBox(width: 12),
                        OrderStatusBadge(status: order.status),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary5,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.primary10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.shippingAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.bodyText(
                              color: isDark
                                  ? AppTheme.textSubtleDark
                                  : AppTheme.textSubtle,
                            ).copyWith(fontSize: 13, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (isCompact)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: AppTheme.productPriceHome().copyWith(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: _TrackOrderButton(orderId: order.id),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: AppTheme.productPriceHome().copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        _TrackOrderButton(orderId: order.id),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrderCardHeader extends StatelessWidget {
  const _OrderCardHeader({required this.order, required this.isDark});

  final Order order;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _displayOrderLabel(order),
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ).copyWith(fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          'Placed ${_formatDate(order.createdAt)}',
          style: AppTheme.productCardSubtitle(
            color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
          ).copyWith(fontSize: 12),
        ),
      ],
    );
  }

  String _displayOrderLabel(Order order) {
    final fullName = (order.shippingAddressData['fullName'] as String? ?? '')
        .trim();
    final firstName = fullName.isEmpty
        ? 'Order'
        : fullName.split(RegExp(r'\s+')).first;
    final cleaned = firstName.replaceAll(RegExp(r'[^A-Za-z]'), '');
    final name = cleaned.isEmpty
        ? 'Order'
        : '${cleaned[0].toUpperCase()}${cleaned.substring(1)}';
    final compactId = order.id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final suffixSource = compactId.isNotEmpty
        ? compactId
        : order.createdAt.millisecondsSinceEpoch.toString();
    final suffix = suffixSource.length <= 3
        ? suffixSource.toUpperCase()
        : suffixSource.substring(suffixSource.length - 3).toUpperCase();
    return name == 'Order' ? 'Order $suffix' : '$name-$suffix';
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

class _TrackOrderButton extends StatelessWidget {
  const _TrackOrderButton({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Navigator.pushNamed(
        context,
        Routes.orderTracking.replaceFirst(':id', orderId),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        side: BorderSide(color: AppTheme.primary20),
        backgroundColor: AppTheme.primary5,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.radiusFull,
          ),
        ),
      ),
      icon: const Icon(Icons.local_shipping_outlined, size: 18),
      label: const Text('Track your order'),
    );
  }
}
