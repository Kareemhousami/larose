import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';

/// Reusable error state widget with icon, message, and retry button.
///
/// Dark-mode aware via [Theme.of(context).brightness].
class ErrorState extends StatelessWidget {
  /// Error message to display.
  final String message;

  /// Callback when "Try Again" is tapped.
  final VoidCallback? onRetry;

  /// Creates an [ErrorState] widget.
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingHorizontal * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary10,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: AppTheme.sectionHeader(
                color:
                    isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodyText(
                color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: PrimaryButton(
                  text: 'Try Again',
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
