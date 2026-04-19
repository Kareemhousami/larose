import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../views/shared/splash_screen.dart';
import 'routes.dart';

/// Root widget for the La Rose flower delivery app.
class LaRoseApp extends StatelessWidget {
  const LaRoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return MaterialApp(
      title: 'La Rose',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: authVm.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: Routes.onGenerateRoute,
      home: const SplashScreen(),
    );
  }
}
