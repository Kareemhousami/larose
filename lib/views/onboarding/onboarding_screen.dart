import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../services/storage_service.dart';

/// Onboarding screen shown to first-time users.
///
/// 3-page swipeable introduction with dot indicators and a "Get Started" CTA.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <_OnboardingPage>[
    _OnboardingPage(
      icon: Icons.local_florist,
      title: 'Welcome to La Rose',
      description:
          'Discover beautiful, hand-crafted flower arrangements delivered fresh to your doorstep.',
    ),
    _OnboardingPage(
      icon: Icons.shopping_bag_outlined,
      title: 'Easy Ordering',
      description:
          'Browse our curated collection, add to cart, and checkout with cash on delivery. Simple and secure.',
    ),
    _OnboardingPage(
      icon: Icons.delivery_dining,
      title: 'Fast Delivery',
      description:
          'Same-day delivery for orders placed before 2 PM. Track your order in real-time from confirmation to your door.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final storage = await StorageService.getInstance();
    await storage.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTheme.bodyText(color: AppTheme.textMuted)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primary10,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 56,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        if (page.title == 'Welcome to La Rose')
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Welcome to ',
                                  style: AppTheme.sectionHeader(
                                    color: isDark
                                        ? AppTheme.textPrimaryDark
                                        : AppTheme.textPrimary,
                                  ).copyWith(fontSize: 24),
                                ),
                                TextSpan(
                                  text: 'La Rose',
                                  style: AppTheme.brandWordmark(
                                    color: AppTheme.primary,
                                    fontSize: 30,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          )
                        else
                          Text(
                            page.title,
                            style: AppTheme.sectionHeader(
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimary,
                            ).copyWith(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: AppTheme.bodyText(
                            color: isDark
                                ? AppTheme.textSubtleDark
                                : AppTheme.textSubtle,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primary : AppTheme.primary20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingHorizontal),
              child: PrimaryButton(
                text: isLast ? 'Get Started' : 'Next',
                onPressed: () {
                  if (isLast) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
