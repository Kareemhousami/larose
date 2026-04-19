import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'add_to_cart_feedback.dart';
import 'shimmer_loading.dart';

/// A product card used in the shop 2-column grid.
///
/// Displays product image, title, subtitle, price, favorite button,
/// and add-to-cart button. Navigates to product details on tap.
class ProductCard extends StatelessWidget {
  /// The product to display.
  final Product product;
  final bool showDescription;
  final ValueChanged<Product>? onAddToCartSuccess;

  static double gridMainAxisExtent(
    double cardWidth, {
    bool showDescription = false,
  }) => cardWidth + (showDescription ? 178 : 140);

  /// Creates a [ProductCard] for the given [product].
  const ProductCard({
    super.key,
    required this.product,
    this.showDescription = false,
    this.onAddToCartSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favVm = context.watch<FavoritesViewModel>();
    final cartVm = context.read<CartViewModel>();
    final isFav = favVm.isFavorite(product.id);
    final tags = [
      product.category,
      product.flowerType,
    ].where((tag) => tag.isNotEmpty).toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/product/${product.id}');
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.primary5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with favorite overlay
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.thumbnail,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return ShimmerLoading(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 0,
                        );
                      },
                      errorBuilder: (_, _, _) => Container(
                        color: AppTheme.primary5,
                        child: const Icon(
                          Icons.image,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => favVm.toggleFavorite(product),
                        child: Container(
                          width: AppTheme.actionButtonSize,
                          height: AppTheme.actionButtonSize,
                          decoration: BoxDecoration(
                            color:
                                (isDark ? AppTheme.navDark : AppTheme.surface)
                                    .withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFav
                                ? AppTheme.primary
                                : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info section
              Padding(
                padding: const EdgeInsets.all(AppTheme.cardPaddingShop),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: AppTheme.productCardTitle(
                        color: isDark ? Colors.white : AppTheme.textSlate800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showDescription && product.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        product.description.trim(),
                        style: AppTheme.bodyText(
                          color: isDark
                              ? AppTheme.textSubtleDark
                              : AppTheme.textSubtle,
                        ).copyWith(fontSize: 12, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: tags
                              .map(
                                (tag) => Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary5,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusFull,
                                      ),
                                      border: Border.all(
                                        color: AppTheme.primary10,
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: AppTheme.productCardSubtitle(
                                        color: AppTheme.textSubtle,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: AppTheme.productPriceShop(),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await cartVm.addToCart(product);
                            if (cartVm.error == null) {
                              if (onAddToCartSuccess != null) {
                                onAddToCartSuccess!(product);
                              } else if (context.mounted) {
                                showAddToCartFeedback(context, product.title);
                              }
                            }
                          },
                          child: Container(
                            width: AppTheme.actionButtonSize,
                            height: AppTheme.actionButtonSize,
                            decoration: BoxDecoration(
                              color: AppTheme.primary10,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusDefault,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
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
}
