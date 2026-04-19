import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;

import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/order_service.dart';

/// Manages orders and order placement.
class OrdersViewModel extends ChangeNotifier {
  OrdersViewModel({OrderService? orderService})
    : _orderService = orderService;

  OrderService? _orderService;
  OrderService get _service => _orderService ??= OrderService();

  String? _uid;
  final List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  double? _checkoutSubtotalAmount;
  double? _checkoutDeliveryFee;
  double? _checkoutTotalAmount;
  String? _checkoutPricingError;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  double? get checkoutSubtotalAmount => _checkoutSubtotalAmount;
  double? get checkoutDeliveryFee => _checkoutDeliveryFee;
  double? get checkoutTotalAmount => _checkoutTotalAmount;
  String? get checkoutPricingError => _checkoutPricingError;

  static const double _fallbackDeliveryFee = 5.0;

  Future<void> loadCheckoutPricing({
    required Address shippingAddress,
    required List<CartItem> items,
  }) async {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    try {
      final snapshot = await _service.previewCheckoutPricing(
        shippingAddress: shippingAddress,
        items: items,
      );
      _checkoutSubtotalAmount =
          (snapshot['subtotalAmount'] as num?)?.toDouble();
      _checkoutDeliveryFee =
          (snapshot['deliveryFee'] as num?)?.toDouble();
      _checkoutTotalAmount =
          (snapshot['totalAmount'] as num?)?.toDouble();
      _checkoutPricingError = null;
    } on FirebaseException catch (_) {
      // Keep checkout usable offline by falling back to the same flat fee as the API layer.
      _checkoutSubtotalAmount = subtotal;
      _checkoutDeliveryFee = _fallbackDeliveryFee;
      _checkoutTotalAmount = subtotal + _fallbackDeliveryFee;
      _checkoutPricingError = null;
    } catch (_) {
      _checkoutSubtotalAmount = subtotal;
      _checkoutDeliveryFee = _fallbackDeliveryFee;
      _checkoutTotalAmount = subtotal + _fallbackDeliveryFee;
      _checkoutPricingError = null;
    }
    notifyListeners();
  }

  Future<void> bindUser(String? uid) async {
    if (_uid == uid) {
      return;
    }
    // Clear the old session immediately so another user's orders never flash on screen.
    _uid = uid;
    _orders.clear();
    notifyListeners();
    if (uid == null || uid.isEmpty) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final loaded = await _service.getOrders(uid);
      _orders
        ..clear()
        ..addAll(loaded);
    } on FirebaseException catch (e) {
      _error = _mapOrderError(
        e,
        defaultMessage: 'Unable to load your orders right now.',
      );
    } catch (e) {
      _error = _fallbackError('Unable to load your orders right now.', e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> placeCashOnDeliveryOrder({
    required Address shippingAddress,
    required List<CartItem> items,
  }) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      _error = 'You must be logged in to place an order.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final orderId = await _service.placeCashOnDeliveryOrder(
        uid: uid,
        shippingAddress: shippingAddress,
        items: items,
      );
      await refresh();
      _isLoading = false;
      notifyListeners();
      return orderId;
    } on FirebaseException catch (e) {
      _error = _mapOrderError(
        e,
        defaultMessage: 'Unable to place your order right now.',
      );
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = _fallbackError('Unable to place your order right now.', e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Order?> getOrder(String orderId) {
    return _service.getOrder(orderId);
  }

  Future<bool> confirmDelivered(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.confirmOrderDelivered(orderId);
      await refresh();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _error = _mapOrderError(
        e,
        defaultMessage: 'Unable to confirm your delivery right now.',
      );
    } catch (e) {
      _error = _fallbackError(
        'Unable to confirm your delivery right now.',
        e,
      );
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<Order?> refreshTracking(String orderId) async {
    // Refresh the focused order and the list view so both screens stay in sync.
    final order = await _service.getOrder(orderId);
    await refresh();
    return order;
  }

  String _mapOrderError(
    FirebaseException exception, {
    required String defaultMessage,
  }) {
    return describeOrderError(exception, defaultMessage: defaultMessage);
  }

  static String describeOrderError(
    FirebaseException exception, {
    required String defaultMessage,
  }) {
    switch (exception.code) {
      case 'unauthenticated':
        return 'Please sign in to continue.';
      case 'permission-denied':
        return 'You do not have permission to place this order.';
      case 'failed-precondition':
        return 'One or more items are no longer available in the requested quantity.';
      case 'invalid-argument':
        return 'Please review your checkout details and try again.';
      case 'not-found':
        return 'A product in your cart could not be found.';
      case 'unavailable':
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'unknown':
      case 'internal':
        return 'Unable to place your order right now. Please try again in a moment.';
      default:
        return _fallbackErrorStatic(defaultMessage, exception);
    }
  }

  String _fallbackError(String message, Object error) {
    return _fallbackErrorStatic(message, error);
  }

  static String _fallbackErrorStatic(String message, Object error) {
    if (kDebugMode) {
      return '$message ${error.toString()}';
    }
    return message;
  }
}
