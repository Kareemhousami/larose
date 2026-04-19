import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'shimmer_loading.dart';

/// Image carousel with page indicators and optional auto-advance.
///
/// Uses [PageView.builder] with dot indicators. Each image shows a
/// [ShimmerLoading] placeholder while loading.
class ImageCarousel extends StatefulWidget {
  /// List of image URLs to display.
  final List<String> imageUrls;

  /// Height of the carousel.
  final double height;

  /// How images fit within the carousel.
  final BoxFit fit;

  /// Whether to auto-advance pages.
  final bool autoAdvance;

  /// Duration between auto-advance page changes.
  final Duration autoAdvanceDuration;

  /// Creates an [ImageCarousel].
  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 400,
    this.fit = BoxFit.cover,
    this.autoAdvance = false,
    this.autoAdvanceDuration = const Duration(seconds: 4),
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.autoAdvance && widget.imageUrls.length > 1) {
      _startAutoAdvance();
    }
  }

  void _startAutoAdvance() {
    _timer = Timer.periodic(widget.autoAdvanceDuration, (_) {
      final next = (_currentPage + 1) % widget.imageUrls.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Container(
          color: AppTheme.primary5,
          child: const Center(
            child: Icon(Icons.image, size: 48, color: AppTheme.textMuted),
          ),
        ),
      );
    }

    if (widget.imageUrls.length == 1) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: _buildImage(widget.imageUrls.first),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _buildImage(widget.imageUrls[index]);
            },
          ),
          // Dot indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: widget.fit,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return ShimmerLoading(
          width: double.infinity,
          height: widget.height,
          borderRadius: 0,
        );
      },
      errorBuilder: (_, _, _) => Container(
        color: AppTheme.primary5,
        child: const Center(
          child: Icon(Icons.broken_image, size: 48, color: AppTheme.textMuted),
        ),
      ),
    );
  }
}
