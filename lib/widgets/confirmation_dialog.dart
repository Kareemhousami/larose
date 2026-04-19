import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shows a styled confirmation dialog and returns the user's choice.
///
/// Returns `true` if confirmed, `false` if cancelled, or `null` if dismissed.
Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      title: Text(
        title,
        style: AppTheme.sectionHeader(
          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
        ),
      ),
      content: Text(
        message,
        style: AppTheme.bodyText(
          color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelLabel,
            style: AppTheme.categoryChip(color: AppTheme.textMuted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            backgroundColor: isDestructive
                ? Colors.redAccent.withValues(alpha: 0.1)
                : AppTheme.primary10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          child: Text(
            confirmLabel,
            style: AppTheme.categoryChip(
              color: isDestructive ? Colors.redAccent : AppTheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}
