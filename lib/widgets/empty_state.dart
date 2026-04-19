import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';

/// Reusable empty state widget with icon, title, subtitle, and optional action.
///
/// Used across Cart, Favorites, Orders, and Search screens to display
/// a consistent empty state when no data is available.
class EmptyState extends StatelessWidget {
  /// Icon to display.
  final IconData icon;

  /// Title text.
  final String title;

  /// Subtitle / description text.
  final String subtitle;

  /// Optional action button label.
  final String? actionLabel;

  /// Callback when the action button is tapped.
  final VoidCallback? onAction;

  /// Creates an [EmptyState] widget.
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
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
              child: Icon(icon, size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTheme.sectionHeader(
                color:
                    isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodyText(
                color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: PrimaryButton(
                  text: actionLabel!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
