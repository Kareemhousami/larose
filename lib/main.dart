import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'services/firebase_bootstrap_service.dart';
import 'viewmodels/address_viewmodel.dart';
import 'viewmodels/admin_delivery_settings_viewmodel.dart';
import 'viewmodels/admin_orders_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'viewmodels/favorites_viewmodel.dart';
import 'viewmodels/orders_viewmodel.dart';
import 'viewmodels/product_viewmodel.dart';

/// Entry point for the La Rose flower delivery app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrapService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..init()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProxyProvider<AuthViewModel, CartViewModel>(
          create: (_) => CartViewModel(),
          update: (_, auth, cart) => cart!..bindUser(auth.user?.id),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, FavoritesViewModel>(
          create: (_) => FavoritesViewModel(),
          update: (_, auth, favorites) => favorites!..bindUser(auth.user?.id),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, AddressViewModel>(
          create: (_) => AddressViewModel(),
          update: (_, auth, addresses) => addresses!..bindUser(auth.user?.id),
        ),
        ChangeNotifierProxyProvider<AuthViewModel, OrdersViewModel>(
          create: (_) => OrdersViewModel(),
          update: (_, auth, orders) => orders!..bindUser(auth.user?.id),
        ),
        ChangeNotifierProvider(create: (_) => AdminOrdersViewModel()),
        ChangeNotifierProvider(create: (_) => AdminDeliverySettingsViewModel()),
      ],
      child: const LaRoseApp(),
    ),
  );
}
