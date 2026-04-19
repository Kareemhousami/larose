import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Themed text field matching the La Rose design system.
///
/// Wraps [TextFormField] with consistent prefix icon, styling, and
/// validation. Eliminates inconsistency between auth screens (with icons)
/// and other screens (bare fields).
class AppTextField extends StatelessWidget {
  /// Hint text displayed when the field is empty.
  final String hintText;

  /// Optional prefix icon.
  final IconData? prefixIcon;

  /// Optional suffix icon.
  final IconData? suffixIcon;

  /// Callback when the suffix icon is tapped.
  final VoidCallback? onSuffixTap;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Validation function.
  final String? Function(String?)? validator;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Whether to obscure text (for passwords).
  final bool obscureText;

  /// Whether the field is enabled.
  final bool enabled;

  /// Maximum number of lines.
  final int maxLines;

  /// Optional callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Creates an [AppTextField].
  const AppTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      onChanged: onChanged,
      style: AppTheme.bodyText(
        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.primary60, size: 20)
            : null,
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(suffixIcon, color: AppTheme.textMuted, size: 20),
              )
            : null,
        filled: true,
        fillColor: isDark ? AppTheme.surfaceDark : AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          borderSide: BorderSide(color: AppTheme.primary5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          borderSide: BorderSide(color: AppTheme.primary50, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTheme.bodyText(
          color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
        ),
      ),
    );
  }
}
