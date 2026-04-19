import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../app/routes.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../models/product.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_loading.dart';

/// Main storefront landing page with search, promotions, and featured bouquets.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _heroBouquetImageUrl;

  @override
  void initState() {
    super.initState();
    _loadHeroImage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final productVm = context.read<ProductViewModel>();
      // Avoid re-fetching when the home tab rebuilds with products already in memory.
      if (productVm.products.isEmpty) {
        productVm.fetchProducts();
      }
    });
  }

  Future<void> _loadHeroImage() async {
    try {
      // Keep the hero artwork in Storage so merchandising can swap it without an app release.
      final url = await FirebaseStorage.instance
          .ref('flower_types/roses/1.png')
          .getDownloadURL();
      if (mounted) setState(() => _heroBouquetImageUrl = url);
    } catch (_) {}
  }

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
      drawer: _HomeDrawer(isDark: isDark),
      appBar: _buildAppBar(context, isDark),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          final productVm = context.read<ProductViewModel>();
          await productVm.fetchProducts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The home page is composed of independent sections so each block can evolve separately.
              _buildSearchBar(context, isDark),
              _buildHeroSection(context),
              const SizedBox(height: 24),
              _buildQuickActions(context, isDark),
              const SizedBox(height: 28),
              _buildOurStorySection(context, isDark),
              const SizedBox(height: 28),
              _buildPromotionsSection(context, isDark),
              const SizedBox(height: 28),
              _buildFeaturedSection(context, isDark, productVm),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.surface,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.primary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        'La Rose',
        style: AppTheme.brandWordmark(),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline_rounded, color: AppTheme.primary),
          onPressed: () => Navigator.pushNamed(context, Routes.profile),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppTheme.primary),
          onPressed: () => Navigator.pushNamed(context, Routes.settings),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    final productVm = context.read<ProductViewModel>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primary10, width: 1.1),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppTheme.primary60, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                style: AppTheme.bodyText(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimary,
                ).copyWith(fontSize: 14, height: 1.2),
                decoration: InputDecoration(
                  hintText: 'Search flowers, bouquets...',
                  hintStyle: AppTheme.bodyText(
                    color: isDark
                        ? AppTheme.textMutedDark
                        : AppTheme.textMuted,
                  ).copyWith(fontSize: 14, height: 1.2),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  final normalized = value.trim();
                  setState(() {
                    _searchQuery = normalized;
                  });
                  // Search is live, so the view model mirrors the trimmed query on every edit.
                  productVm.searchProducts(normalized);
                },
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                  productVm.searchProducts('');
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primary10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.primary,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        key: const Key('homeHeroCard'),
        width: double.infinity,
        height: AppTheme.heroMinHeight,
        decoration: BoxDecoration(
          color: AppTheme.primary5,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.primary10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Show the Storage-backed image when available, otherwise keep a branded placeholder.
            if (_heroBouquetImageUrl != null)
              Image.network(
                _heroBouquetImageUrl!,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, _, _) => Container(
                  color: AppTheme.primary10,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.local_florist_rounded,
                    size: 56,
                    color: AppTheme.primary,
                  ),
                ),
              )
            else
              Container(
                color: AppTheme.primary10,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.local_florist_rounded,
                  size: 56,
                  color: AppTheme.primary,
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                // Darken the lower half so white copy stays readable on any photo.
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.backgroundDark.withValues(alpha: 0.88),
                    AppTheme.backgroundDark.withValues(alpha: 0.52),
                    AppTheme.backgroundDark.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                        ),
                        child: Text(
                          'NEW COLLECTION',
                          style: AppTheme.categoryChip(
                            color: Colors.white,
                          ).copyWith(fontSize: 10, letterSpacing: 1.1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Explore Our\nFlower Shop',
                        style: AppTheme.heroHeading().copyWith(
                          fontSize: 26,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Fresh blooms delivered to your door',
                        style: AppTheme.bodyText(
                          color: Colors.white.withValues(alpha: 0.84),
                        ).copyWith(fontSize: 13, height: 1.35),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, Routes.shop),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                          child: Ink(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary30,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Shop Now',
                                  style: AppTheme.buttonText().copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    // These shortcuts point to the app's highest-traffic shopping and account screens.
    final actions = [
      _QuickAction(
        Icons.grid_view_rounded,
        'Events',
        Routes.shopCategories,
      ),
      _QuickAction(Icons.local_florist_rounded, 'Types', Routes.shopTypes),
      _QuickAction(Icons.favorite_rounded, 'Favorites', Routes.favorites),
      _QuickAction(Icons.receipt_long_rounded, 'Orders', Routes.orders),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: actions.map((action) {
          return Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, action.route),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primary10,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Icon(action.icon, color: AppTheme.primary, size: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTheme.categoryChip(
                      color: isDark
                          ? AppTheme.textSubtleDark
                          : AppTheme.textSubtle,
                    ).copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOurStorySection(BuildContext context, bool isDark) {
    final bodyColor = isDark
        ? AppTheme.textSubtleDark
        : AppTheme.textSubtle;
    final titleColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.textPrimary;
    final surface = isDark ? AppTheme.surfaceDark : AppTheme.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.primary10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              surface,
              AppTheme.primary5,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primary10,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Our Story',
              style: AppTheme.sectionHeader(color: titleColor).copyWith(
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'La Rose began with a quiet belief that flowers can hold the words we sometimes struggle to say. Every bouquet is arranged to feel intimate, graceful, and memorable, so each delivery arrives like a small love letter at the door.',
              style: AppTheme.bodyText(color: bodyColor).copyWith(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.about),
                child: const Text('Learn more about us'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionsSection(BuildContext context, bool isDark) {
    final titleColor = isDark
        ? AppTheme.textPrimaryDark
        : AppTheme.textPrimary;
    final bodyColor = isDark
        ? AppTheme.textSubtleDark
        : AppTheme.textSubtle;
    final surface = isDark ? AppTheme.surfaceDark : AppTheme.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Touches',
            style: AppTheme.sectionHeader(
              color: titleColor,
            ).copyWith(fontSize: 22),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              // Stack on narrow widths, otherwise keep both promo cards visible at once.
              final stacked = constraints.maxWidth < 720;
              final welcomeCard = _PromoCard(
                icon: Icons.local_shipping_outlined,
                eyebrow: 'WELCOME OFFER',
                title: '15% off and free delivery on your first order.',
                description:
                    'Begin your La Rose story with a bouquet that arrives beautifully and effortlessly, with a little extra generosity from us.',
                isDark: isDark,
                backgroundColors: [
                  AppTheme.primary,
                  AppTheme.primary90,
                ],
                foregroundColor: Colors.white,
                accentColor: Colors.white.withValues(alpha: 0.18),
              );
              final birthdayCard = _PromoCard(
                icon: Icons.cake_outlined,
                eyebrow: 'BIRTHDAY TREAT',
                title: 'Celebrate January 1 birthdays with a 25% floral gift.',
                description:
                    'If your special day blooms on New Year\'s Day, your bouquet arrives with an extra celebration woven into every stem.',
                isDark: isDark,
                backgroundColors: [
                  surface,
                  AppTheme.primary5,
                ],
                foregroundColor: titleColor,
                accentColor: AppTheme.primary10,
                bodyColor: bodyColor,
                borderColor: AppTheme.primary10,
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    welcomeCard,
                    const SizedBox(height: 16),
                    birthdayCard,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: welcomeCard),
                  const SizedBox(width: 16),
                  Expanded(child: birthdayCard),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(
    BuildContext context,
    bool isDark,
    ProductViewModel productVm,
  ) {
    final isSearching = _searchQuery.trim().isNotEmpty;
    // Search swaps the product source without changing the section layout.
    final visibleProducts = isSearching
        ? productVm.searchResults
        : productVm.products;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.sectionPaddingVertical,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingHorizontal,
            ),
            child: SectionHeader(
              title: _searchQuery.trim().isEmpty
                  ? 'Featured Bouquets'
                  : 'Search Results',
              onViewAll: () => Navigator.pushNamed(context, Routes.shop),
            ),
          ),
          const SizedBox(height: 16),
          if (productVm.isLoading)
            const HomeProductSkeletonRow()
          else if (visibleProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingHorizontal,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ).copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try a different flower, bouquet, or event keyword.',
                      style: AppTheme.bodyText(
                        color: isDark
                            ? AppTheme.textSubtleDark
                            : AppTheme.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingHorizontal,
                ),
                itemCount: visibleProducts.length > 10
                    ? 10
                    : visibleProducts.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppTheme.cardGap),
                itemBuilder: (_, index) {
                  final product = visibleProducts[index];
                  return _HomeProductCard(product: product, isDark: isDark);
                },
              ),
            ),
        ],
      ),
    );
  }

}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;

  const _QuickAction(this.icon, this.label, this.route);
}

/// Reusable marketing card used by the promotions section.
class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.isDark,
    required this.backgroundColors,
    required this.foregroundColor,
    required this.accentColor,
    this.bodyColor,
    this.borderColor,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final bool isDark;
  final List<Color> backgroundColors;
  final Color foregroundColor;
  final Color accentColor;
  final Color? bodyColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 214),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: borderColor ?? Colors.transparent),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: foregroundColor, size: 24),
              ),
              const SizedBox(height: 18),
              Text(
                eyebrow,
                style: AppTheme.categoryChip(
                  color: foregroundColor.withValues(alpha: 0.82),
                ).copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTheme.sectionHeader(
                  color: foregroundColor,
                ).copyWith(fontSize: 20, height: 1.2),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: AppTheme.bodyText(
                  color: bodyColor ?? foregroundColor.withValues(alpha: 0.84),
                ).copyWith(height: 1.55),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final background = isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight;
    final surface = isDark ? AppTheme.surfaceDark : AppTheme.surface;
    final subtleText = isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle;

    return Drawer(
      backgroundColor: background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(color: AppTheme.primary10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'La Rose',
                      style: AppTheme.brandWordmark(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Fresh blooms, favorites, orders, and profile shortcuts in one place.',
                      style: AppTheme.bodyText(color: subtleText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  // Keep the drawer focused on the main destinations instead of mirroring every route.
                  children: const [
                    _DrawerItem(
                      icon: Icons.home_outlined,
                      label: 'Home',
                      route: Routes.home,
                    ),
                    _DrawerItem(
                      icon: Icons.storefront_outlined,
                      label: 'Shop',
                      route: Routes.shop,
                    ),
                    _DrawerItem(
                      icon: Icons.favorite_border_rounded,
                      label: 'Favorites',
                      route: Routes.favorites,
                    ),
                    _DrawerItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'Orders',
                      route: Routes.orders,
                    ),
                    _DrawerItem(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Cart',
                      route: Routes.cart,
                    ),
                    _DrawerItem(
                      icon: Icons.info_outline_rounded,
                      label: 'About Us',
                      route: Routes.about,
                    ),
                    _DrawerItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      route: Routes.profile,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'Navigate quickly through the app.',
                  style: AppTheme.productCardSubtitle(color: subtleText)
                      .copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary;
    final surface = isDark ? AppTheme.surfaceDark : AppTheme.surface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            // Replace the current page so drawer navigation does not create deep back stacks.
            Navigator.pushReplacementNamed(context, route);
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.primary5),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary10,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusDefault + 2),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.bodyText(color: primaryText)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textMuted,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeProductCard extends StatelessWidget {
  final Product product;
  final bool isDark;

  const _HomeProductCard({required this.product, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cartVm = context.read<CartViewModel>();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product/${product.id}'),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.primary5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppTheme.primary5,
                      child: const Icon(Icons.image, color: AppTheme.textMuted),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        // This keeps the favorite affordance visible in the compact home card.
                        Icons.favorite_border_rounded,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppTheme.productPriceHome().copyWith(
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => cartVm.addToCart(product),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: Colors.white,
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
    );
  }
}
