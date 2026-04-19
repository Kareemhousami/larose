import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

/// Manages the shopping cart state persisted in Firestore.
class CartViewModel extends ChangeNotifier {
  CartViewModel({CartService? cartService})
      : _cartService = cartService ?? CartService();

  final CartService _cartService;

  String? _uid;
  final List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  Future<void> bindUser(String? uid) async {
    if (_uid == uid) {
      return;
    }
    _uid = uid;
    _items.clear();
    notifyListeners();
    if (uid == null || uid.isEmpty) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final loaded = await _cartService.getCartItems(uid);
      _items
        ..clear()
        ..addAll(loaded);
    } on FirebaseException catch (e) {
      _error = _mapCartError(
        e,
        defaultMessage: 'Unable to load your cart right now.',
      );
    } catch (e) {
      _error = _fallbackError('Unable to load your cart right now.', e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(Product product) async {
    _error = null;
    final index = _items.indexWhere((item) => item.product.id == product.id);
    final previousItems = _cloneItems();
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      final item = CartItem(product: product);
      _items.add(item);
    }
    notifyListeners();

    try {
      await _persist(
        _items.firstWhere((item) => item.product.id == product.id),
      );
    } on FirebaseException catch (e) {
      _restoreItems(previousItems);
      _error = _mapCartError(
        e,
        defaultMessage: 'Unable to add this item to your cart.',
      );
    } catch (e) {
      _restoreItems(previousItems);
      _error = _fallbackError('Unable to add this item to your cart.', e);
    }
    notifyListeners();
  }

  Future<void> removeFromCart(int productId) async {
    _error = null;
    final previousItems = _cloneItems();
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();

    try {
      if (_uid != null) {
        await _cartService.removeCartItem(_uid!, productId);
      }
    } on FirebaseException catch (e) {
      _restoreItems(previousItems);
      _error = _mapCartError(
        e,
        defaultMessage: 'Unable to remove this item from your cart.',
      );
    } catch (e) {
      _restoreItems(previousItems);
      _error = _fallbackError(
        'Unable to remove this item from your cart.',
        e,
      );
    }
    notifyListeners();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index < 0) {
      return;
    }
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }
    _error = null;
    final previousItems = _cloneItems();
    _items[index].quantity = quantity;
    notifyListeners();

    try {
      await _persist(_items[index]);
    } on FirebaseException catch (e) {
      _restoreItems(previousItems);
      _error = _mapCartError(
        e,
        defaultMessage: 'Unable to update your cart quantity.',
      );
    } catch (e) {
      _restoreItems(previousItems);
      _error = _fallbackError('Unable to update your cart quantity.', e);
    }
    notifyListeners();
  }

  Future<void> clearCart() async {
    final uid = _uid;
    _error = null;
    final previousItems = _cloneItems();
    _items.clear();
    notifyListeners();

    try {
      if (uid != null) {
        await _cartService.clearCart(uid);
      }
    } on FirebaseException catch (e) {
      _restoreItems(previousItems);
      _error = _mapCartError(
        e,
        defaultMessage: 'Unable to clear your cart right now.',
      );
    } catch (e) {
      _restoreItems(previousItems);
      _error = _fallbackError('Unable to clear your cart right now.', e);
    }
    notifyListeners();
  }

  Future<void> _persist(CartItem item) async {
    final uid = _uid;
    if (uid == null) {
      return;
    }
    await _cartService.setCartItem(uid, item.product, item.quantity);
  }

  List<CartItem> _cloneItems() {
    return _items
        .map((item) => CartItem(product: item.product, quantity: item.quantity))
        .toList();
  }

  void _restoreItems(List<CartItem> items) {
    _items
      ..clear()
      ..addAll(items);
  }

  String _mapCartError(
    FirebaseException exception, {
    required String defaultMessage,
  }) {
    switch (exception.code) {
      case 'permission-denied':
        return 'You do not have permission to update this cart.';
      case 'unavailable':
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return _fallbackError(defaultMessage, exception);
    }
  }

  String _fallbackError(String message, Object error) {
    if (kDebugMode) {
      return '$message ${error.toString()}';
    }
    return message;
  }
}
