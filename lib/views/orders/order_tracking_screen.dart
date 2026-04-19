import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/orders_viewmodel.dart';
import '../../widgets/order_status_badge.dart';
import '../../widgets/primary_button.dart';

/// Displays the tracking timeline for a specific order.
class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Future<Order?>? _orderFuture;
  Order? _currentOrder;
  Timer? _autoRefreshTimer;
  Timer? _countdownTimer;
  int? _remainingMinutes;

  static const _autoRefreshInterval = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    _orderFuture = _loadOrder();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<Order?> _loadOrder() async {
    final order = await context.read<OrdersViewModel>().getOrder(
      widget.orderId,
    );
    if (mounted && order != null) {
      _currentOrder = order;
      _startTimersIfDelivery(order);
    }
    return order;
  }

  void _startTimersIfDelivery(Order order) {
    _autoRefreshTimer?.cancel();
    _countdownTimer?.cancel();

    // Only live deliveries need polling and a local ETA countdown.
    if (order.status != OrderStatus.outForDelivery) return;

    // Auto-refresh from server every 2 minutes.
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      _refreshTracking();
    });

    // Start local countdown.
    _updateRemainingMinutes(order);
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted || _currentOrder == null) return;
      _updateRemainingMinutes(_currentOrder!);
    });
  }

  void _updateRemainingMinutes(Order order) {
    final etaUpdatedAt = order.deliveryEtaUpdatedAt;
    final etaMinutes =
        order.deliveryEtaMinutes ?? order.deliveryEtaRangeMaxMinutes;

    if (etaUpdatedAt == null || etaMinutes == null) {
      setState(() => _remainingMinutes = null);
      return;
    }

    final elapsed = DateTime.now().difference(etaUpdatedAt).inMinutes;
    // Clamp at zero so stale ETA snapshots never show negative time.
    final remaining = (etaMinutes - elapsed).clamp(0, etaMinutes);
    setState(() => _remainingMinutes = remaining);
  }

  Future<void> _confirmDelivered() async {
    final success = await context.read<OrdersViewModel>().confirmDelivered(
      widget.orderId,
    );
    if (!success || !mounted) {
      return;
    }
    setState(() {
      _orderFuture = _loadOrder();
    });
  }

  Future<void> _refreshTracking() async {
    final order = await context.read<OrdersViewModel>().refreshTracking(
      widget.orderId,
    );
    if (mounted && order != null) {
      _currentOrder = order;
      _updateRemainingMinutes(order);
      _startTimersIfDelivery(order);
      setState(() {
        _orderFuture = Future.value(order);
      });
    }
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
          'Track Order',
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
          // Older orders may not have event documents yet, so synthesize a starting point.
          final events = order.events.isEmpty
              ? [
                  OrderEvent(
                    type: order.status.name,
                    message: 'Order created',
                    createdAt: order.createdAt,
                  ),
                ]
              : order.events;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(AppTheme.cardPadding),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.primary5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ${order.id}',
                              style: AppTheme.sectionHeader(
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cash on delivery',
                              style: AppTheme.productCardSubtitle(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Tracking Timeline',
                  style: AppTheme.sectionHeader(
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < events.length; i++)
                  _TimelineStep(
                    title: _titleFromEvent(events[i].type),
                    subtitle: events[i].message,
                    isCompleted:
                        i < events.length - 1 ||
                        order.status == OrderStatus.delivered ||
                        order.status == OrderStatus.cancelled,
                    isCurrent:
                        i == events.length - 1 &&
                        order.status != OrderStatus.delivered &&
                        order.status != OrderStatus.cancelled,
                    isLast: i == events.length - 1,
                    isDark: isDark,
                  ),
                if (order.status == OrderStatus.outForDelivery) ...[
                  const SizedBox(height: 24),
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
                        Text(
                          'Delivery Progress',
                          style: AppTheme.sectionHeader(
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_remainingMinutes != null &&
                            _remainingMinutes! <= 2)
                          Text(
                            'Almost here!',
                            style: AppTheme.productPriceShop(),
                          )
                        else if (_remainingMinutes != null)
                          Text(
                            'About $_remainingMinutes min',
                            style: AppTheme.productPriceShop(),
                          )
                        else if (order.deliveryEtaRangeMinMinutes != null &&
                            order.deliveryEtaRangeMaxMinutes != null)
                          Text(
                            'About ${order.deliveryEtaRangeMinMinutes}-${order.deliveryEtaRangeMaxMinutes} min',
                            style: AppTheme.productPriceShop(),
                          )
                        else if (order.deliveryEtaMinutes != null)
                          Text(
                            'About ${order.deliveryEtaMinutes} min',
                            style: AppTheme.productPriceShop(),
                          ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _refreshTracking,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary),
                          ),
                          child: const Text('Refresh estimate'),
                        ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          text: 'Received my order',
                          onPressed: _confirmDelivered,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _titleFromEvent(String type) {
    switch (type) {
      case 'awaitingConfirmation':
        return 'Awaiting Confirmation';
      case 'preparing':
        return 'Preparing';
      case 'donePreparing':
        return 'Done Preparing';
      case 'outForDelivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'admin_note':
        return 'Admin Note';
      default:
        return 'Order Created';
    }
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isCurrent = false,
    required this.isLast,
    required this.isDark,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.primary
                    : isCurrent
                    ? AppTheme.primary50
                    : AppTheme.primary10,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: AppTheme.primary, width: 2)
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : isCurrent
                  ? Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isCompleted ? AppTheme.primary : AppTheme.primary10,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.productCardSubtitle(
                    color: isDark
                        ? AppTheme.textSubtleDark
                        : AppTheme.textSubtle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
