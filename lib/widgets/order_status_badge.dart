import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_theme.dart';

/// A pill-shaped badge displaying the current [OrderStatus].
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  String get _label {
    switch (status) {
      case OrderStatus.awaitingConfirmation:
        return 'Awaiting Confirmation';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.donePreparing:
        return 'Done Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = status == OrderStatus.cancelled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCancelled
            ? AppTheme.textMuted.withValues(alpha: 0.15)
            : AppTheme.primary10,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        _label,
        style: AppTheme.categoryChip(
          color: isCancelled ? AppTheme.textMuted : AppTheme.primary,
        ),
      ),
    );
  }
}
