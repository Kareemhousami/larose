import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/product_viewmodel.dart';

/// Shows all shopping categories.
class ShopCategoriesScreen extends StatefulWidget {
  /// Creates a [ShopCategoriesScreen].
  const ShopCategoriesScreen({super.key});

  @override
  State<ShopCategoriesScreen> createState() => _ShopCategoriesScreenState();
}

class _ShopCategoriesScreenState extends State<ShopCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ProductViewModel>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productVm = context.watch<ProductViewModel>();
    final categories = productVm.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text('Shop By Event', style: AppTheme.appBarTitle()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Events',
              style: AppTheme.sectionHeader(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an event to open its bouquet collection.',
              style: AppTheme.bodyText(
                color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
              ),
            ),
            const SizedBox(height: 20),
            if (productVm.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              )
            else if (categories.isEmpty)
              Text(
                'No categories are available from Firebase right now.',
                style: AppTheme.bodyText(
                  color: isDark
                      ? AppTheme.textSubtleDark
                      : AppTheme.textSubtle,
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 156,
                ),
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final category = categories[index];
                  return _EventOptionCard(
                    icon: _categoryIcon(category),
                    title: category,
                    subtitle: 'Open $category bouquets',
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.shopCollection,
                      arguments: {
                        'category': category,
                        'title': category,
                        'browseMode': 'Event',
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _EventOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EventOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.primary10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary10,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.sectionHeader(
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimary,
                        ).copyWith(fontSize: 17, height: 1.15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTheme.productCardSubtitle(
                          color: isDark
                              ? AppTheme.textSubtleDark
                              : AppTheme.textSubtle,
                        ).copyWith(fontSize: 12, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Wedding':
      return Icons.favorite_rounded;
    case 'Birthday':
      return Icons.cake_rounded;
    case 'Anniversary':
      return Icons.celebration_rounded;
    case 'Sympathy':
      return Icons.spa_outlined;
    case 'Graduation':
      return Icons.school_rounded;
    case 'New Baby':
      return Icons.child_care_rounded;
    case 'Congratulations':
      return Icons.auto_awesome_rounded;
    case 'Romantic':
      return Icons.favorite_border_rounded;
    default:
      return Icons.local_offer_rounded;
  }
}
