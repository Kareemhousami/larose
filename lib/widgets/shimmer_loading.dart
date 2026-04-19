import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated shimmer placeholder for loading states.
///
/// Uses a sliding linear gradient to create the shimmer effect.
/// Colors are derived from [AppTheme] so it works in both light and dark mode.
class ShimmerLoading extends StatefulWidget {
  /// Width of the shimmer container.
  final double width;

  /// Height of the shimmer container.
  final double height;

  /// Border radius of the shimmer container.
  final double borderRadius;

  /// Creates a [ShimmerLoading] placeholder.
  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppTheme.radiusDefault,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? Colors.white.withValues(alpha: 0.06) : AppTheme.primary5;
    final highlightColor =
        isDark ? Colors.white.withValues(alpha: 0.12) : AppTheme.primary10;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-1.0 + 2.0 * _controller.value + 1.0, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

/// A skeleton placeholder that matches [ProductCard] dimensions for shop grids.
class ProductCardSkeleton extends StatelessWidget {
  /// Creates a [ProductCardSkeleton].
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder
        const ShimmerLoading(
          width: double.infinity,
          height: 140,
          borderRadius: AppTheme.radiusXl,
        ),
        const SizedBox(height: 8),
        // Title placeholder
        const ShimmerLoading(width: 120, height: 14),
        const SizedBox(height: 6),
        // Subtitle placeholder
        const ShimmerLoading(width: 80, height: 10),
        const SizedBox(height: 8),
        // Price placeholder
        const ShimmerLoading(width: 60, height: 14),
      ],
    );
  }
}

/// A horizontal row of [ProductCardSkeleton] for the home featured section.
class HomeProductSkeletonRow extends StatelessWidget {
  /// Number of skeleton cards to show.
  final int count;

  /// Creates a [HomeProductSkeletonRow].
  const HomeProductSkeletonRow({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppTheme.paddingHorizontal),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: AppTheme.cardGap),
        itemBuilder: (_, _) {
          return const SizedBox(
            width: AppTheme.homeCardWidth,
            child: ProductCardSkeleton(),
          );
        },
      ),
    );
  }
}

/// A 2-column grid of [ProductCardSkeleton] for shop loading state.
class ProductGridSkeleton extends StatelessWidget {
  /// Number of skeleton items to show.
  final int count;

  /// Creates a [ProductGridSkeleton].
  const ProductGridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding:
          const EdgeInsets.symmetric(horizontal: AppTheme.paddingHorizontal),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: AppTheme.cardGap,
        mainAxisSpacing: AppTheme.cardGap,
      ),
      itemCount: count,
      itemBuilder: (_, _) => const ProductCardSkeleton(),
    );
  }
}
