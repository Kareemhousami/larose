import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/product_viewmodel.dart';

/// Shows all flower types.
class ShopTypesScreen extends StatefulWidget {
  /// Creates a [ShopTypesScreen].
  const ShopTypesScreen({super.key});

  @override
  State<ShopTypesScreen> createState() => _ShopTypesScreenState();
}

class _ShopTypesScreenState extends State<ShopTypesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductViewModel>().fetchFlowerTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productVm = context.watch<ProductViewModel>();
    final flowerTypes = productVm.flowerTypes;

    return Scaffold(
      appBar: AppBar(
        title: Text('Shop By Type', style: AppTheme.appBarTitle()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flower Types',
              style: AppTheme.sectionHeader(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a bloom type to open that flower collection.',
              style: AppTheme.bodyText(
                color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 156,
              ),
              itemCount: flowerTypes.length,
              itemBuilder: (_, index) {
                final flowerType = flowerTypes[index];
                return _TypeOptionCard(
                  icon: _flowerTypeIcon(flowerType),
                  title: flowerType,
                  subtitle: 'Open $flowerType bouquets',
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.shopCollection,
                    arguments: {
                      'flowerType': flowerType,
                      'title': flowerType,
                      'browseMode': 'Type',
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

class _TypeOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TypeOptionCard({
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

IconData _flowerTypeIcon(String flowerType) {
  switch (flowerType) {
    case 'Roses':
      return Icons.local_florist_rounded;
    case 'Tulips':
      return Icons.filter_vintage_rounded;
    case 'Lilies':
      return Icons.spa_rounded;
    case 'Orchids':
      return Icons.eco_rounded;
    case 'Peonies':
      return Icons.yard_rounded;
    case 'Sunflowers':
      return Icons.wb_sunny_outlined;
    case 'Mixed Blooms':
      return Icons.auto_awesome_mosaic_rounded;
    default:
      return Icons.local_florist_outlined;
  }
}
