import 'package:flutter/material.dart';

/// Shared network image wrapper with branded loading and fallback states.
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.borderRadius,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget child = Image.network(
      imageUrl,
      fit: fit,
      height: height,
      width: width,
      // Prefer the browser's native image element on web for more stable remote rendering.
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8EEF3),
                Color(0xFFF2D5E4),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF2D5E4),
                Color(0xFFE7B7CE),
                Color(0xFFD88CB2),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.local_florist_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
        );
      },
    );

    if (borderRadius != null) {
      // Clip the wrapper so loading and error placeholders match the final shape.
      child = ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    return child;
  }
}
