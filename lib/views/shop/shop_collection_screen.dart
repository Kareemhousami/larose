import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shimmer_loading.dart';

/// Displays a single filtered bouquet collection backed by Firestore products.
class ShopCollectionScreen extends StatefulWidget {
  /// Creates a [ShopCollectionScreen].
  const ShopCollectionScreen({super.key});

  @override
  State<ShopCollectionScreen> createState() => _ShopCollectionScreenState();
}

class _ShopCollectionScreenState extends State<ShopCollectionScreen> {
  bool _handledArguments = false;
  String? _category;
  String? _flowerType;
  String _title = 'Collection';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledArguments) {
      return;
    }

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map) {
      final routeArguments = Map<String, dynamic>.from(arguments);
      _category = routeArguments['category'] as String?;
      _flowerType = routeArguments['flowerType'] as String?;
      _title = routeArguments['title'] as String? ?? _title;
    }

    _handledArguments = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ProductViewModel>().applyFilters(
        category: _category,
        flowerType: _flowerType,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productVm = context.watch<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_title, style: AppTheme.appBarTitle()),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => context.read<ProductViewModel>().applyFilters(
          category: _category,
          flowerType: _flowerType,
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _collectionDescription(),
                style: AppTheme.bodyText(
                  color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoPill(
                    label: 'Items',
                    value: '${productVm.products.length}',
                  ),
                  if (_category != null) ...[
                    const SizedBox(width: 10),
                    _InfoPill(label: 'Category', value: _category!),
                  ],
                  if (_flowerType != null) ...[
                    const SizedBox(width: 10),
                    _InfoPill(label: 'Type', value: _flowerType!),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              if (productVm.isLoading)
                const ProductGridSkeleton()
              else if (productVm.products.isEmpty)
                _EmptyCollectionState(title: _title)
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = AppTheme.cardGap;
                    final cardWidth = (constraints.maxWidth - spacing) / 2;
                    final cardHeight = ProductCard.gridMainAxisExtent(
                      cardWidth,
                      showDescription: true,
                    );

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        mainAxisExtent: cardHeight,
                      ),
                      itemCount: productVm.products.length,
                      itemBuilder: (_, index) {
                        return ProductCard(
                          product: productVm.products[index],
                          showDescription: true,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  String _collectionDescription() {
    if (_category != null) {
      return 'Showing real bouquets from Firebase for $_category.';
    }
    if (_flowerType != null) {
      return 'Showing real bouquets from Firebase for $_flowerType blooms.';
    }
    return 'Showing curated bouquets from Firebase.';
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.primary10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTheme.productCardSubtitle(
              color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
            ),
          ),
          Text(
            value,
            style: AppTheme.categoryChip(
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmptyCollectionState extends StatelessWidget {
  final String title;

  const _EmptyCollectionState({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.primary10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No bouquets found',
            style: AppTheme.sectionHeader(
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no bouquets in the $title collection right now.',
            style: AppTheme.bodyText(
              color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppTheme.cardGap;
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        final cardHeight = ProductCard.gridMainAxisExtent(
          cardWidth,
          showDescription: true,
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: cardHeight,
          ),
          itemCount: 6,
          itemBuilder: (_, _) {
            return ShimmerLoading(
              width: double.infinity,
              height: double.infinity,
              borderRadius: AppTheme.radiusXl,
            );
          },
        );
      },
    );
  }
}
