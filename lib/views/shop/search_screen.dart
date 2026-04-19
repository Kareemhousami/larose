import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../widgets/product_card.dart';

/// Search screen with a text input and live product search results.
///
/// Uses [ProductViewModel.searchProducts] to query Firestore-backed products.
class SearchScreen extends StatefulWidget {
  /// Creates a [SearchScreen].
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productVm = context.watch<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: (isDark ? AppTheme.backgroundDark : AppTheme.surface)
            .withValues(alpha: 0.8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => popOrGoTo(context, Routes.shop),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for bouquets, flowers...',
            border: InputBorder.none,
            hintStyle: AppTheme.bodyText(color: AppTheme.textMuted),
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          style: AppTheme.bodyText(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
          onChanged: (query) {
            productVm.searchProducts(query);
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.primary),
              onPressed: () {
                _searchController.clear();
                productVm.searchProducts('');
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.primary10),
        ),
      ),
      body: _buildBody(productVm),
    );
  }

  /// Builds the body content based on search state.
  Widget _buildBody(ProductViewModel productVm) {
    if (productVm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppTheme.primary20),
            const SizedBox(height: 16),
            Text(
              'Search for your favorite flowers',
              style: AppTheme.bodyText(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    if (productVm.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.primary20),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: AppTheme.bodyText(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppTheme.cardGap;
        final cardWidth =
            (constraints.maxWidth -
                (AppTheme.paddingHorizontal * 2) -
                spacing) /
            2;
        final cardHeight = ProductCard.gridMainAxisExtent(cardWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: cardHeight,
          ),
          itemCount: productVm.searchResults.length,
          itemBuilder: (_, index) {
            return ProductCard(product: productVm.searchResults[index]);
          },
        );
      },
    );
  }
}
