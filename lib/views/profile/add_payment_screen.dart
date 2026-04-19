import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

/// Cash on delivery payment info screen.
class AddPaymentScreen extends StatelessWidget {
  const AddPaymentScreen({super.key});

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
          onPressed: () => popOrGoTo(context, Routes.profile),
        ),
        title: Text(
          'Payment Method',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  const Icon(Icons.payments_outlined, color: AppTheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Cash on Delivery',
                    style: AppTheme.sectionHeader(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'At La Rose, checkout is designed to feel simple, secure, and reassuring. '
                    'We currently accept Cash on Delivery, so your bouquet is prepared with confidence '
                    'and payment is completed smoothly at arrival. Additional trusted payment methods '
                    'will be introduced soon to make every order even more seamless.',
                    style: AppTheme.bodyText(
                      color: isDark
                          ? AppTheme.textSubtleDark
                          : AppTheme.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Back',
              onPressed: () => popOrGoTo(context, Routes.profile),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
