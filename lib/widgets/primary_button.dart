import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Primary pill-shaped button matching the La Rose design system.
///
/// Full-width by default, 48dp tall, rounded-full, primary background,
/// with a shadow using primary/30.
class PrimaryButton extends StatelessWidget {
  /// Button label text.
  final String text;

  /// Callback when pressed, or null to disable.
  final VoidCallback? onPressed;

  /// Whether to show a loading indicator instead of text.
  final bool isLoading;

  /// Creates a [PrimaryButton] with the given [text] and [onPressed].
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppTheme.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary30,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: AppTheme.buttonPaddingHorizontal),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(text, style: AppTheme.buttonText()),
      ),
    );
  }
}
