import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const double _kSnackBarHorizontalMargin = 16;
const double _kSnackBarBottomGap = 16;

/// Shows the branded add-to-cart confirmation used across product flows.
void showAddToCartFeedback(BuildContext context, String title) {
  final messenger = ScaffoldMessenger.of(context);
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  // Replace any older toast so repeated taps keep a single visible confirmation.
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.fromLTRB(
        _kSnackBarHorizontalMargin,
        0,
        _kSnackBarHorizontalMargin,
        bottomInset + kBottomNavigationBarHeight + _kSnackBarBottomGap,
      ),
      duration: const Duration(seconds: 2),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary30,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_florist_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bouquet added to cart',
                    style: AppTheme.productCardTitle(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.productCardSubtitle(
                      color: Colors.white.withValues(alpha: 0.86),
                    ).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
