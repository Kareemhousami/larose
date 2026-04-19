// lib/services/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseException, FirebaseFirestore, Timestamp;

import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import 'api/delivery_api.dart';
import 'api/order_api.dart';
import 'firestore_paths.dart';

/// Creates and reads cash-on-delivery orders.
class OrderService {
  OrderService({
    FirebaseFirestore? firestore,
    OrderApi? orderApi,
    DeliveryApi? deliveryApi,
  })  : _firestoreOverride = firestore,
        _orderApiOverride = orderApi,
        _deliveryApiOverride = deliveryApi;

  final FirebaseFirestore? _firestoreOverride;
  final OrderApi? _orderApiOverride;
  final DeliveryApi? _deliveryApiOverride;

  late final FirebaseFirestore _firestore =
      _firestoreOverride ?? FirebaseFirestore.instance;
  late final OrderApi _orderApi =
      _orderApiOverride ?? OrderApi(firestore: _firestoreOverride);
  late final DeliveryApi _deliveryApi =
      _deliveryApiOverride ?? DeliveryApi(firestore: _firestoreOverride);

  Future<Map<String, dynamic>> previewCheckoutPricing({
    required Address shippingAddress,
    required List<CartItem> items,
  }) async {
    final subtotalAmount = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final location = shippingAddress.location;
    final lat = (location['lat'] as num?)?.toDouble();
    final lng = (location['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) {
      throw FirebaseException(
        plugin: 'order_service',
        code: 'invalid-argument',
        message: 'Delivery pricing requires a pinned address.',
      );
    }

    final deliverySnapshot = await _deliveryApi.lockDeliveryPricing(
      destinationLat: lat,
      destinationLng: lng,
    );
    final deliveryFee =
        (deliverySnapshot['deliveryFee'] as num?)?.toDouble() ?? 0.0;

    return {
      'subtotalAmount': subtotalAmount,
      'deliveryFee': deliveryFee,
      'totalAmount': subtotalAmount + deliveryFee,
      'deliveryPricing': deliverySnapshot['deliveryPricing'] ?? const {},
    };
  }

  Future<String> placeCashOnDeliveryOrder({
    required String uid,
    required Address shippingAddress,
    required List<CartItem> items,
  }) async {
    return _orderApi.placeCashOnDeliveryOrder(
      uid: uid,
      shippingAddress: shippingAddress,
      items: items,
      deliveryApi: _deliveryApi,
    );
  }

  Future<List<Order>> getOrders(String uid) async {
    final snapshot = await FirestorePaths.orders(_firestore)
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return Future.wait(snapshot.docs.map(_mapOrderDocument));
  }

  Future<List<Order>> getAllOrders() async {
    final snapshot = await FirestorePaths.orders(_firestore)
        .orderBy('createdAt', descending: true)
        .get();
    return Future.wait(snapshot.docs.map(_mapOrderDocument));
  }

  Future<Order?> getOrder(String orderId) async {
    final doc = await FirestorePaths.orders(_firestore).doc(orderId).get();
    if (!doc.exists) {
      return null;
    }
    return _mapOrderDocument(doc);
  }

  Future<List<OrderEvent>> getOrderEvents(String orderId) async {
    final snapshot = await FirestorePaths.orderEvents(_firestore, orderId)
        .orderBy('createdAt', descending: false)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return OrderEvent.fromJson({
        ...data,
        'createdAt': _serializeDate(data['createdAt']),
      });
    }).toList();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus nextStatus,
  }) async {
    await _orderApi.updateOrderStatus(
      orderId: orderId,
      nextStatus: nextStatus,
    );
  }

  Future<void> addOrderAdminNote({
    required String orderId,
    required String note,
  }) async {
    await _orderApi.addOrderAdminNote(orderId: orderId, note: note);
  }

  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    await _orderApi.cancelOrder(orderId: orderId, reason: reason);
  }

  Future<void> confirmOrderDelivered(String orderId) async {
    await _orderApi.confirmOrderDelivered(orderId: orderId);
  }

  DeliveryApi get deliveryApi => _deliveryApi;

  Future<Order> _mapOrderDocument(dynamic doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final events = await getOrderEvents(doc.id as String);
    return Order.fromJson({
      'id': doc.id,
      ...data,
      'items': data['items'] ?? <Map<String, dynamic>>[],
      'createdAt': _serializeDate(data['createdAt']),
      'updatedAt': _serializeDate(data['updatedAt']),
      'lastStatusChangedAt': _serializeDate(data['lastStatusChangedAt']),
      'deliveredAt': _serializeDate(data['deliveredAt']),
      'events': events.map((event) => event.toJson()).toList(),
    });
  }

  String _serializeDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    return value?.toString() ?? DateTime.now().toIso8601String();
  }
}
