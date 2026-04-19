import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Launch splash shown while the app resolves its initial destination.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _backgroundColor = Color(0xFFFFF5F7);
  static const _titleColor = Color(0xFF6E4754);
  static const _animationAsset = 'assets/petals.json';
  static const _animationSize = 260.0;
  static const _onboardingKey = 'has_seen_onboarding';

  late final AnimationController _textController;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textScale;
  Timer? _titleTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    final textCurve = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOutCubic,
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(textCurve);
    _textScale = Tween<double>(begin: 0.96, end: 1).animate(textCurve);

    _titleTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        _textController.forward();
      }
    });
    _navigationTimer = Timer(
      const Duration(milliseconds: 5000),
      _navigateToResolvedRoute,
    );
  }

  Future<void> _navigateToResolvedRoute() async {
    if (!mounted) {
      return;
    }

    final authVm = context.read<AuthViewModel>();
    if (!authVm.isInitialized) {
      _navigationTimer = Timer(
        const Duration(milliseconds: 200),
        _navigateToResolvedRoute,
      );
      return;
    }

    final storage = await StorageService.getInstance();
    final hasSeenOnboarding = storage.getBool(_onboardingKey) ?? false;
    if (!mounted) {
      return;
    }

    final nextRoute = !hasSeenOnboarding
        ? Routes.onboarding
        : authVm.isLoggedIn
        ? Routes.home
        : Routes.login;

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  void dispose() {
    _titleTimer?.cancel();
    _navigationTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              _animationAsset,
              width: _animationSize,
              height: _animationSize,
              repeat: false,
              fit: BoxFit.contain,
              frameRate: FrameRate.composition,
              errorBuilder: (_, _, _) => const SizedBox(
                width: _animationSize,
                height: _animationSize,
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _textOpacity,
              child: ScaleTransition(
                scale: _textScale,
                child: Text(
                  'La Rose',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 29,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3.2,
                    color: _titleColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
