import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Formatted price display with optional strikethrough original price.
///
/// Shows `$XX.XX` formatted text. If [originalPrice] is provided and differs
/// from [price], shows it with strikethrough next to the current price.
class PriceDisplay extends StatelessWidget {
  /// Current price.
  final double price;

  /// Original price before discount (shown with strikethrough).
  final double? originalPrice;

  /// Text style for the current price.
  final TextStyle? style;

  /// Creates a [PriceDisplay] widget.
  const PriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final priceStyle = style ?? AppTheme.productPriceShop();
    final hasDiscount =
        originalPrice != null && originalPrice! > price;

    if (!hasDiscount) {
      return Text(
        '\$${price.toStringAsFixed(2)}',
        style: priceStyle,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: priceStyle,
        ),
        const SizedBox(width: 6),
        Text(
          '\$${originalPrice!.toStringAsFixed(2)}',
          style: AppTheme.productCardSubtitle().copyWith(
            decoration: TextDecoration.lineThrough,
            decorationColor: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
