import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/navigation.dart';
import '../../theme/app_theme.dart';
import '../../app/routes.dart';
import '../../viewmodels/favorites_viewmodel.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state.dart';

/// Displays the user's favorited products in a 2-column grid.
///
/// Uses [FavoritesViewModel] to read and manage favorites.
class FavoritesScreen extends StatelessWidget {
  /// Creates a [FavoritesScreen].
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favVm = context.watch<FavoritesViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
                .withValues(alpha: 0.8),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
          onPressed: () => popOrGoTo(context, Routes.home),
        ),
        title: Text(
          'My Favorites',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.primary10),
        ),
      ),
      body: favVm.favorites.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              subtitle: 'Start adding flowers you love!',
              actionLabel: 'Browse Flowers',
              onAction: () => Navigator.pushNamed(context, Routes.shop),
            )
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () async {
                // Trigger a refresh of favorites
                favVm.bindUser(favVm.favorites.isNotEmpty ? null : null);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = AppTheme.cardGap;
                  final cardWidth =
                      (constraints.maxWidth -
                          (AppTheme.paddingHorizontal * 2) -
                          spacing) /
                      2;
                  final cardHeight = ProductCard.gridMainAxisExtent(
                    cardWidth,
                    showDescription: true,
                  );

                  return GridView.builder(
                    padding: const EdgeInsets.all(
                      AppTheme.paddingHorizontal,
                    ).copyWith(bottom: 80),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      mainAxisExtent: cardHeight,
                    ),
                    itemCount: favVm.favorites.length,
                    itemBuilder: (_, index) {
                      final product = favVm.favorites[index];
                      return ProductCard(
                        product: product,
                        showDescription: true,
                      );
                    },
                  );
                },
              ),
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
