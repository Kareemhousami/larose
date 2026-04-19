import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../app/routes.dart';
import '../../widgets/primary_button.dart';

/// Confirmation screen shown after a successful order placement.
///
/// Displays a success message with animated check icon and offers
/// navigation back to home or orders.
class SaveConfirmationScreen extends StatelessWidget {
  /// Creates a [SaveConfirmationScreen].
  const SaveConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final args = ModalRoute.of(context)?.settings.arguments;
    final orderId = args is Map ? args['orderId'] as String? : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary),
          onPressed: () =>
              Navigator.pushNamedAndRemoveUntil(
                  context, Routes.home, (route) => false),
        ),
        title: Text(
          'Confirmation',
          style: AppTheme.sectionHeader(color: AppTheme.primary),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated success icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppTheme.primary10,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 56,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Order Placed!',
                style: AppTheme.sectionHeader(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimary,
                ).copyWith(fontSize: 24),
              ),
              if (orderId != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Order #${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                  style: AppTheme.productCardSubtitle(
                    color: AppTheme.primary,
                  ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  style: AppTheme.bodyText(
                    color: isDark
                        ? AppTheme.textSubtleDark
                        : AppTheme.textSubtle,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'Your beautiful flowers are on their way.\nThank you for choosing ',
                    ),
                    TextSpan(
                      text: 'La Rose',
                      style: AppTheme.brandWordmark(
                        color: AppTheme.primary,
                        fontSize: 24,
                      ),
                    ),
                    const TextSpan(text: '!'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'Continue Shopping',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, Routes.home, (route) => false),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, Routes.orders, (route) => false),
                child: Text(
                  'View Orders',
                  style: AppTheme.viewAllLink()
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
