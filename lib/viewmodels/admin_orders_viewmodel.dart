import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;

import '../models/order.dart';
import '../services/order_service.dart';

/// Manages admin order loading, filtering, and mutations.
class AdminOrdersViewModel extends ChangeNotifier {
  AdminOrdersViewModel({OrderService? orderService})
    : _orderService = orderService;

  OrderService? _orderService;
  OrderService get _service => _orderService ??= OrderService();

  final List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  OrderStatus? _statusFilter;
  String _searchQuery = '';

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderStatus? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  List<Order> get filteredOrders {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    return _orders.where((order) {
      final matchesStatus =
          _statusFilter == null || order.status == _statusFilter;
      if (!matchesStatus) {
        return false;
      }

      if (normalizedQuery.isEmpty) {
        return true;
      }

      final fullName =
          (order.shippingAddressData['fullName'] as String? ?? '').toLowerCase();
      return order.id.toLowerCase().contains(normalizedQuery) ||
          fullName.contains(normalizedQuery);
    }).toList();
  }

  @protected
  Future<List<Order>> fetchOrders() => _service.getAllOrders();

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final loaded = await fetchOrders();
      _orders
        ..clear()
        ..addAll(loaded);
    } on FirebaseException catch (e) {
      _error = _mapOrderError(
        e,
        defaultMessage: 'Unable to load orders right now.',
      );
    } catch (e) {
      _error = _fallbackError('Unable to load orders right now.', e);
    }
    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(OrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<Order?> getOrder(String orderId) => _service.getOrder(orderId);

  Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus nextStatus,
  }) async {
    return _runMutation(() async {
      await _service.updateOrderStatus(orderId: orderId, nextStatus: nextStatus);
    });
  }

  Future<bool> addAdminNote({
    required String orderId,
    required String note,
  }) async {
    return _runMutation(() async {
      await _service.addOrderAdminNote(orderId: orderId, note: note);
    });
  }

  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    return _runMutation(() async {
      await _service.cancelOrder(orderId: orderId, reason: reason);
    });
  }

  Future<bool> _runMutation(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      final loaded = await fetchOrders();
      _orders
        ..clear()
        ..addAll(loaded);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _error = _mapOrderError(
        e,
        defaultMessage: 'Unable to update the order right now.',
      );
    } catch (e) {
      _error = _fallbackError('Unable to update the order right now.', e);
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  String _mapOrderError(
    FirebaseException exception, {
    required String defaultMessage,
  }) {
    switch (exception.code) {
      case 'permission-denied':
      case 'unauthenticated':
        return 'You do not have permission to manage orders.';
      case 'invalid-argument':
        return 'This order cannot be moved to that state.';
      case 'not-found':
        return 'The order could not be found.';
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
