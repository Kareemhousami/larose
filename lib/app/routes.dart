import 'package:flutter/material.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/home/home_screen.dart';
import '../views/shop/shop_screen.dart';
import '../views/shop/shop_categories_screen.dart';
import '../views/shop/shop_types_screen.dart';
import '../views/shop/shop_collection_screen.dart';
import '../views/shop/search_screen.dart';
import '../views/product/product_details_screen.dart';
import '../views/favorites/favorites_screen.dart';
import '../views/cart/cart_screen.dart';
import '../views/cart/checkout_screen.dart';
import '../views/shared/save_confirmation_screen.dart';
import '../views/orders/orders_screen.dart';
import '../views/orders/order_tracking_screen.dart';
import '../views/orders/order_details_screen.dart';
import '../views/orders/admin_orders_screen.dart';
import '../views/orders/admin_order_details_screen.dart';
import '../views/orders/admin_delivery_settings_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/profile/edit_profile_screen.dart';
import '../views/profile/add_address_screen.dart';
import '../views/profile/addresses_screen.dart';
import '../views/profile/add_payment_screen.dart';
import '../views/profile/notifications_screen.dart';
import '../views/profile/privacy_security_screen.dart';
import '../views/settings/settings_screen.dart';
import '../views/settings/privacy_policy_screen.dart';
import '../views/settings/terms_screen.dart';
import '../views/settings/about_screen.dart';
import '../views/settings/contact_screen.dart';
import '../views/settings/faq_screen.dart';
import '../views/onboarding/onboarding_screen.dart';

/// Centralized route definitions for the La Rose app.
///
/// All route name strings are static constants. Never use inline
/// `MaterialPageRoute` — always navigate via these named routes.
class Routes {
  Routes._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String shop = '/shop';
  static const String shopCategories = '/shop/categories';
  static const String shopTypes = '/shop/types';
  static const String shopCollection = '/shop/collection';
  static const String search = '/search';
  static const String productDetails = '/product/:id';
  static const String favorites = '/favorites';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String confirmation = '/confirmation';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:id/details';
  static const String orderTracking = '/orders/:id/track';
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetails = '/admin/orders/:id';
  static const String adminDeliverySettings = '/admin/delivery-settings';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String addresses = '/profile/addresses';
  static const String addAddress = '/profile/address/add';
  static const String addPayment = '/profile/payment/add';
  static const String notifications = '/profile/notifications';
  static const String privacySecurity = '/profile/privacy';
  static const String settings = '/settings';
  static const String privacyPolicy = '/settings/privacy-policy';
  static const String terms = '/settings/terms';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String faq = '/faq';

  /// Generates the route map for [MaterialApp.onGenerateRoute].
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    final path = uri.path;

    // Dynamic routes are handled before the static switch below.
    // Match /product/:id
    if (path.startsWith('/product/')) {
      final id = path.split('/').last;
      return _slideRoute(
        settings,
        ProductDetailsScreen(productId: int.parse(id)),
        fade: true,
      );
    }

    // Match /orders/:id/details
    if (path.startsWith('/orders/') && path.endsWith('/details')) {
      final segments = path.split('/');
      final id = segments[2];
      return _slideRoute(settings, OrderDetailsScreen(orderId: id));
    }

    // Match /orders/:id/track
    if (path.startsWith('/orders/') && path.endsWith('/track')) {
      final segments = path.split('/');
      final id = segments[2];
      return _slideRoute(settings, OrderTrackingScreen(orderId: id));
    }

    if (path == adminOrders) {
      return _slideRoute(settings, const AdminOrdersScreen());
    }

    if (path == adminDeliverySettings) {
      return _slideRoute(settings, const AdminDeliverySettingsScreen());
    }

    if (path.startsWith('/admin/orders/')) {
      final id = path.split('/').last;
      return _slideRoute(settings, AdminOrderDetailsScreen(orderId: id));
    }

    // Static routes
    switch (path) {
      case login:
        return _slideRoute(settings, const LoginScreen());
      case signup:
        return _slideRoute(settings, const SignupScreen());
      case forgotPassword:
        return _slideRoute(settings, const ForgotPasswordScreen());
      case onboarding:
        return _slideRoute(settings, const OnboardingScreen(), fade: true);
      case home:
        return _slideRoute(settings, const HomeScreen());
      case shop:
        return _slideRoute(settings, const ShopScreen());
      case shopCategories:
        return _slideRoute(settings, const ShopCategoriesScreen());
      case shopTypes:
        return _slideRoute(settings, const ShopTypesScreen());
      case shopCollection:
        return _slideRoute(settings, const ShopCollectionScreen());
      case search:
        return _slideRoute(settings, const SearchScreen());
      case favorites:
        return _slideRoute(settings, const FavoritesScreen());
      case cart:
        return _slideRoute(settings, const CartScreen());
      case checkout:
        return _slideRoute(settings, const CheckoutScreen());
      case confirmation:
        return _slideRoute(
          settings,
          const SaveConfirmationScreen(),
          fade: true,
        );
      case orders:
        return _slideRoute(settings, const OrdersScreen());
      case profile:
        return _slideRoute(settings, const ProfileScreen());
      case editProfile:
        return _slideRoute(settings, const EditProfileScreen());
      case addresses:
        return _slideRoute(settings, const AddressesScreen());
      case addAddress:
        return _slideRoute(settings, const AddAddressScreen());
      case addPayment:
        return _slideRoute(settings, const AddPaymentScreen());
      case notifications:
        return _slideRoute(settings, const NotificationsScreen());
      case privacySecurity:
        return _slideRoute(settings, const PrivacySecurityScreen());
      case Routes.settings:
        return _slideRoute(settings, const SettingsScreen());
      case privacyPolicy:
        return _slideRoute(settings, const PrivacyPolicyScreen());
      case terms:
        return _slideRoute(settings, const TermsScreen());
      case about:
        return _slideRoute(settings, const AboutScreen());
      case contact:
        return _slideRoute(settings, const ContactScreen());
      case faq:
        return _slideRoute(settings, const FaqScreen());
      default:
        return _slideRoute(settings, const LoginScreen());
    }
  }

  /// Creates a page route with slide-from-right transition.
  /// If [fade] is true, uses a fade + slight scale transition instead.
  static Route<dynamic> _slideRoute(
    RouteSettings settings,
    Widget page, {
    bool fade = false,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Use the same easing for both transition styles so navigation feels consistent.
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        if (fade) {
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
              child: child,
            ),
          );
        }

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }
}
