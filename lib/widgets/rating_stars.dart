import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Displays a row of 5 star icons representing a rating value.
///
/// Supports filled, half, and outline stars.
class RatingStars extends StatelessWidget {
  /// Rating value from 0.0 to 5.0.
  final double rating;

  /// Size of each star icon.
  final double size;

  /// Color of the stars.
  final Color? color;

  /// Whether to show the numeric rating next to stars.
  final bool showValue;

  /// Creates a [RatingStars] widget.
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.showValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? AppTheme.primary;
    final clamped = rating.clamp(0.0, 5.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          IconData icon;
          if (clamped >= starValue) {
            icon = Icons.star;
          } else if (clamped >= starValue - 0.5) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }
          return Icon(icon, size: size, color: starColor);
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            clamped.toStringAsFixed(1),
            style: AppTheme.productCardSubtitle(color: starColor),
          ),
        ],
      ],
    );
  }
}
