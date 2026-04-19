import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../models/product.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/image_carousel.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/price_display.dart';
import '../../widgets/add_to_cart_feedback.dart';

/// Displays full details for a single product.
///
/// Shows product images, title, price, description, rating, and stock.
/// Provides add-to-cart and toggle-favorite actions.
class ProductDetailsScreen extends StatefulWidget {
  /// The product ID to display.
  final int productId;

  /// Creates a [ProductDetailsScreen] for the given [productId].
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final productVm = context.read<ProductViewModel>();
    var product = productVm.getProductById(widget.productId);
    product ??= await productVm.fetchProductById(widget.productId);
    if (!mounted) return;
    setState(() {
      _product = product;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
            onPressed: () => popOrGoTo(context, Routes.shop),
          ),
        ),
        body: const Center(child: Text('Product not found')),
      );
    }

    final product = _product!;
    final favVm = context.watch<FavoritesViewModel>();
    final cartVm = context.read<CartViewModel>();
    final isFav = favVm.isFavorite(product.id);
    final canAddToCart = product.stock > 0;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: PrimaryButton(
            text: canAddToCart ? 'Add to Cart' : 'Out of Stock',
            onPressed: canAddToCart
                ? () async {
                    await cartVm.addToCart(product);
                    if (cartVm.error == null && context.mounted) {
                      showAddToCartFeedback(context, product.title);
                    }
                  }
                : null,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Image header
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.surfaceDark : AppTheme.surface)
                      .withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              onPressed: () => popOrGoTo(context, Routes.shop),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.surfaceDark : AppTheme.surface)
                        .withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppTheme.primary : AppTheme.textMuted,
                    size: 20,
                  ),
                ),
                onPressed: () => favVm.toggleFavorite(product),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ImageCarousel(
                imageUrls: product.images.isNotEmpty
                    ? product.images
                    : [product.thumbnail],
                height: 400,
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Category and flower type chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary10,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                        ),
                        child: Text(
                          product.category,
                          style: AppTheme.categoryChip(color: AppTheme.primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary5,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                        ),
                        child: Text(
                          product.flowerType,
                          style: AppTheme.categoryChip(
                            color: AppTheme.textSlate800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    product.title,
                    style: AppTheme.sectionHeader(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ).copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),

                  // Price and rating row
                  Row(
                    children: [
                      PriceDisplay(
                        price: product.price,
                        style: AppTheme.productPriceHome().copyWith(
                          fontSize: 24,
                        ),
                      ),
                      const Spacer(),
                      RatingStars(
                        rating: product.rating,
                        size: 18,
                        showValue: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: AppTheme.sectionHeader(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: AppTheme.bodyText(
                      color: isDark
                          ? AppTheme.textSubtleDark
                          : AppTheme.textSubtle,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stock info
                  Row(
                    children: [
                      Icon(
                        canAddToCart ? Icons.check_circle : Icons.cancel,
                        color: canAddToCart
                            ? AppTheme.primary
                            : AppTheme.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        canAddToCart
                            ? '${product.stock} in stock'
                            : 'Out of stock',
                        style: AppTheme.bodyText(
                          color: canAddToCart
                              ? AppTheme.primary
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 128),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
