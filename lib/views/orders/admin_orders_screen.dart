import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/admin_orders_viewmodel.dart';
import '../../widgets/order_status_badge.dart';

/// Admin list screen for managing all orders.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<AuthViewModel>().isAdmin) {
        return;
      }
      context.read<AdminOrdersViewModel>().loadOrders();
    });
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
          'All Orders',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
            child: TextField(
              onChanged: viewModel.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by order id or customer',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  borderSide: BorderSide(color: AppTheme.primary10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  borderSide: BorderSide(color: AppTheme.primary10),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingHorizontal,
              ),
              children: [
                _StatusChip(
                  label: 'All',
                  selected: viewModel.statusFilter == null,
                  onTap: () => viewModel.setStatusFilter(null),
                ),
                for (final status in OrderStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _StatusChip(
                      label: _labelForStatus(status),
                      selected: viewModel.statusFilter == status,
                      onTap: () => viewModel.setStatusFilter(status),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : RefreshIndicator(
                    color: AppTheme.primary,
                    onRefresh: viewModel.loadOrders,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppTheme.paddingHorizontal)
                          .copyWith(bottom: 24),
                      itemBuilder: (_, index) {
                        final order = viewModel.filteredOrders[index];
                        final fullName =
                            order.shippingAddressData['fullName'] as String? ??
                            'Customer';
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusXl,
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.adminOrderDetails.replaceFirst(
                                ':id',
                                order.id,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.cardPadding),
                              decoration: BoxDecoration(
                                color:
                                    isDark ? AppTheme.surfaceDark : AppTheme.surface,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusXl),
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
                                          style: AppTheme.productCardTitle(
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
                                    fullName,
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
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemCount: viewModel.filteredOrders.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _labelForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.awaitingConfirmation:
        return 'Awaiting';
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
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primary,
      labelStyle: AppTheme.categoryChip(
        color: selected ? Colors.white : AppTheme.primary,
      ),
      backgroundColor: AppTheme.primary5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        side: BorderSide(color: AppTheme.primary10),
      ),
    );
  }
}
