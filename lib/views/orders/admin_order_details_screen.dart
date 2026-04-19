import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/admin_orders_viewmodel.dart';
import '../../widgets/order_status_badge.dart';
import '../../widgets/primary_button.dart';

/// Admin detail screen with status controls and note management.
class AdminOrderDetailsScreen extends StatefulWidget {
  const AdminOrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  Future<Order?>? _orderFuture;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (context.read<AuthViewModel>().isAdmin) {
      _orderFuture = context.read<AdminOrdersViewModel>().getOrder(widget.orderId);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authVm = context.watch<AuthViewModel>();
    final viewModel = context.watch<AdminOrdersViewModel>();

    if (!authVm.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor:
              (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
                  .withValues(alpha: 0.8),
          title: Text(
            'Admin access only',
            style: AppTheme.sectionHeader(
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
            child: Text(
              'You do not have permission to access order management.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyText(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
                .withValues(alpha: 0.8),
        title: Text(
          'Manage Order',
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
          if (_noteController.text.isEmpty) {
            _noteController.text = order.adminNote;
          }
          final availableStatuses = _nextStatuses(order.status);

          return ListView(
            padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
            children: [
              Container(
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
                      children: [
                        Expanded(
                          child: Text(
                            'Order ${order.id}',
                            style: AppTheme.sectionHeader(
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        OrderStatusBadge(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.shippingAddressData['fullName'] as String? ??
                          'Customer',
                      style: AppTheme.bodyText(
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.shippingAddress,
                      style: AppTheme.productCardSubtitle(
                        color: isDark
                            ? AppTheme.textSubtleDark
                            : AppTheme.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Admin Note',
                style: AppTheme.sectionHeader(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Add an internal note',
                  filled: true,
                  fillColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    borderSide: BorderSide(color: AppTheme.primary10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'Save Note',
                isLoading: viewModel.isLoading,
                onPressed: () => _saveNote(context, order.id),
              ),
              const SizedBox(height: 24),
              Text(
                'Actions',
                style: AppTheme.sectionHeader(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              for (final status in availableStatuses) ...[
                PrimaryButton(
                  text: _statusActionLabel(status),
                  isLoading: viewModel.isLoading,
                  onPressed: () => _updateStatus(context, order.id, status),
                ),
                const SizedBox(height: 12),
              ],
              if (order.status != OrderStatus.cancelled &&
                  order.status != OrderStatus.delivered)
                OutlinedButton(
                  onPressed: () => _cancelOrder(context, order.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel Order'),
                ),
              if (viewModel.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  viewModel.error!,
                  style: AppTheme.bodyText(color: Colors.redAccent),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<OrderStatus> _nextStatuses(OrderStatus status) {
    switch (status) {
      case OrderStatus.awaitingConfirmation:
        return [OrderStatus.preparing];
      case OrderStatus.preparing:
        return [OrderStatus.donePreparing];
      case OrderStatus.donePreparing:
        return [OrderStatus.outForDelivery];
      case OrderStatus.outForDelivery:
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return const [];
    }
  }

  String _statusActionLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return 'Start Preparing';
      case OrderStatus.donePreparing:
        return 'Done Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.awaitingConfirmation:
        return 'Awaiting Confirmation';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _orderFuture = context.read<AdminOrdersViewModel>().getOrder(widget.orderId);
    });
  }

  Future<void> _saveNote(BuildContext context, String orderId) async {
    final success = await context.read<AdminOrdersViewModel>().addAdminNote(
      orderId: orderId,
      note: _noteController.text.trim(),
    );
    if (success && context.mounted) {
      await _refresh();
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    String orderId,
    OrderStatus status,
  ) async {
    final success =
        await context.read<AdminOrdersViewModel>().updateOrderStatus(
              orderId: orderId,
              nextStatus: status,
            );
    if (success && context.mounted) {
      await _refresh();
    }
  }

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    final success = await context.read<AdminOrdersViewModel>().cancelOrder(
          orderId: orderId,
          reason: 'Cancelled by admin',
        );
    if (success && context.mounted) {
      await _refresh();
    }
  }

}
