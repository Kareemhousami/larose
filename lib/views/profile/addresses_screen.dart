import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/address_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirmation_dialog.dart';

/// Lists all saved addresses with edit, delete, and add options.
class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final addressVm = context.watch<AddressViewModel>();
    final addresses = addressVm.addresses;

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
          onPressed: () => popOrGoTo(context, Routes.profile),
        ),
        title: Text(
          'My Addresses',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: addresses.isEmpty
          ? EmptyState(
              icon: Icons.location_on_outlined,
              title: 'No addresses saved',
              subtitle: 'Add a shipping address for faster checkout.',
              actionLabel: 'Add Address',
              onAction: () => Navigator.pushNamed(context, Routes.addAddress),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(
                AppTheme.paddingHorizontal,
              ).copyWith(bottom: 100),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final addr = addresses[index];
                return Container(
                  padding: const EdgeInsets.all(AppTheme.cardPadding),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(
                      color: addr.isDefault
                          ? AppTheme.primary20
                          : AppTheme.primary5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              addr.fullName,
                              style: AppTheme.productCardTitle(
                                color: isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (addr.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary10,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull,
                                ),
                              ),
                              child: Text(
                                'Default',
                                style: AppTheme.occasionLabel(
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        addr.locationLabel.isNotEmpty
                            ? addr.locationLabel
                            : '${addr.line1}\n${addr.city}, ${addr.postalCode}',
                        style: AppTheme.bodyText(
                          color: isDark
                              ? AppTheme.textSubtleDark
                              : AppTheme.textSubtle,
                        ),
                      ),
                      if (addr.deliveryNote.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          addr.deliveryNote,
                          style: AppTheme.bodyText(
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                      if (addr.phone.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(addr.phone, style: AppTheme.productCardSubtitle()),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.addAddress,
                              arguments: addr,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: AppTheme.categoryChip(
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () async {
                              final confirmed = await showConfirmationDialog(
                                context,
                                title: 'Delete Address?',
                                message:
                                    'This will permanently remove this address.',
                                confirmLabel: 'Delete',
                                isDestructive: true,
                              );
                              if (confirmed == true) {
                                addressVm.deleteAddress(addr.id);
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Delete',
                                  style: AppTheme.categoryChip(
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: addresses.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, Routes.addAddress),
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
