import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../models/address.dart';
import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../firestore_paths.dart';
import 'delivery_api.dart';
import 'delivery_planning.dart';

/// Dart API layer for order business logic and persistence orchestration.
///
/// All order business logic (placement, status transitions, admin ops)
/// runs client-side using Firestore transactions.
class OrderApi {
  OrderApi({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
  })  : _explicitFirestore = firestore,
        _explicitAuth = auth;

  final FirebaseFirestore? _explicitFirestore;
  final firebase_auth.FirebaseAuth? _explicitAuth;
  FirebaseFirestore get _firestore => _explicitFirestore ?? FirebaseFirestore.instance;
  firebase_auth.FirebaseAuth get _auth => _explicitAuth ?? firebase_auth.FirebaseAuth.instance;

  // ── Status transition map used by order workflows ──

  static const Map<OrderStatus, Set<OrderStatus>> _allowedTransitions = {
    OrderStatus.awaitingConfirmation: {
      OrderStatus.preparing,
      OrderStatus.cancelled,
    },
    OrderStatus.preparing: {
      OrderStatus.donePreparing,
      OrderStatus.cancelled,
    },
    OrderStatus.donePreparing: {
      OrderStatus.outForDelivery,
      OrderStatus.cancelled,
    },
    OrderStatus.outForDelivery: {
      OrderStatus.cancelled,
    },
  };

  /// Returns `true` if transitioning from [current] to [next] is allowed.
  static bool isValidTransition(OrderStatus current, OrderStatus next) {
    return _allowedTransitions[current]?.contains(next) ?? false;
  }

  /// Returns `true` if the customer can confirm delivery.
  static bool canCustomerConfirmDelivered({
    required OrderStatus orderStatus,
    required String orderUserId,
    required String callerUid,
  }) {
    return orderStatus == OrderStatus.outForDelivery &&
        orderUserId == callerUid;
  }

  /// Aggregates duplicate product IDs, summing quantities.
  static List<Map<String, dynamic>> aggregateItems(
    List<Map<String, dynamic>> items,
  ) {
    final aggregated = <String, Map<String, dynamic>>{};
    for (final item in items) {
      final productId = (item['productId'] ?? '').toString();
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      if (productId.isEmpty || quantity <= 0) {
        throw ArgumentError(
          'Invalid cart item: productId=$productId, quantity=$quantity',
        );
      }
      if (aggregated.containsKey(productId)) {
        aggregated[productId]!['quantity'] =
            (aggregated[productId]!['quantity'] as int) + quantity;
      } else {
        aggregated[productId] = Map<String, dynamic>.from(item);
      }
    }
    return aggregated.values.toList();
  }

  /// Computes the order pricing breakdown from product subtotal and delivery fee.
  static Map<String, dynamic> computeOrderTotals({
    required int subtotalMinor,
    required double deliveryFee,
  }) {
    final subtotalAmount = subtotalMinor / 100;
    final totalAmount = subtotalAmount + deliveryFee;
    final totalMinor = (totalAmount * 100).round();
    return {
      'subtotalAmount': subtotalAmount,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'totalMinor': totalMinor,
    };
  }

  // ── Auth helpers ──

  String _requireAuth() {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'unauthenticated',
        message: 'Authentication is required.',
      );
    }
    return user.uid;
  }

  Future<String> _requireAdmin() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'unauthenticated',
        message: 'Authentication is required.',
      );
    }
    final tokenResult = await user.getIdTokenResult();
    if (tokenResult.claims?['admin'] != true) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'permission-denied',
        message: 'Admin privileges are required.',
      );
    }
    return user.uid;
  }

  // ── Event builder ──

  Map<String, dynamic> _buildEvent({
    required String type,
    required String message,
    required String actor,
    required String actorUid,
    Map<String, dynamic> metadata = const {},
  }) {
    return {
      'type': type,
      'message': message,
      'actor': actor,
      'actorUid': actorUid,
      'metadata': metadata,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _buildInitialOrderEvent() {
    return {
      'type': OrderStatus.awaitingConfirmation.name,
      'message': 'Cash on delivery order received and awaiting confirmation.',
      'createdAt': FieldValue.serverTimestamp(),
      'actor': 'system',
    };
  }

  /// Places a cash-on-delivery order using a Firestore transaction.
  ///
  /// Atomically validates stock, reserves inventory, creates the order
  /// and its initial event. Then clears the user's cart.
  /// Returns the new order ID.
  Future<String> placeCashOnDeliveryOrder({
    required String uid,
    required Address shippingAddress,
    required List<CartItem> items,
    DeliveryApi? deliveryApi,
  }) async {
    _requireAuth();

    if (items.isEmpty) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'invalid-argument',
        message: 'Shipping address and cart items are required.',
      );
    }
    if (items.length > 50) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'invalid-argument',
        message: 'Orders are limited to 50 items.',
      );
    }

    final rawItems = items
        .map((item) => <String, dynamic>{
              'productId': item.product.id.toString(),
              'docId': item.product.docId,
              'title': item.product.title,
              'description': item.product.description,
              'thumbnail': item.product.thumbnail,
              'category': item.product.category,
              'unitPriceMinor': (item.product.price * 100).round(),
              'quantity': item.quantity,
            })
        .toList();

    final aggregated = aggregateItems(rawItems);

    // Lock delivery pricing before the transaction.
    // Falls back to $5 if pricing API is unavailable.
    double deliveryFee = 5.0;
    Map<String, dynamic> deliveryPricingSnapshot = const {'source': 'fallback'};
    final location = shippingAddress.location;
    final lat = (location['lat'] as num?)?.toDouble();
    final lng = (location['lng'] as num?)?.toDouble();
    if (lat != null && lng != null && deliveryApi != null) {
      try {
        final deliveryResult = await deliveryApi.lockDeliveryPricing(
          destinationLat: lat,
          destinationLng: lng,
        );
        deliveryFee = (deliveryResult['deliveryFee'] as num?)?.toDouble() ?? 5.0;
        deliveryPricingSnapshot = (deliveryResult['deliveryPricing'] as Map<String, dynamic>?) ?? const {};
      } catch (_) {
        // Keep $5 fallback
      }
    }

    final orderRef = FirestorePaths.orders(_firestore).doc();
    final orderEventsRef = FirestorePaths.orderEvents(_firestore, orderRef.id);

    try {
      await _firestore.runTransaction((transaction) async {
        int subtotalMinor = 0;
        final normalizedItems = <Map<String, dynamic>>[];
        // Read every product up front so stock checks and reservations stay atomic.
        final productRefs = aggregated
            .map((item) => FirestorePaths.products(_firestore)
                .doc(item['docId'] as String))
            .toList();
        final productSnaps =
            await Future.wait(productRefs.map((ref) => transaction.get(ref)));

        for (int i = 0; i < productSnaps.length; i++) {
          final requested = aggregated[i];
          final productRef = productRefs[i];
          final productSnap = productSnaps[i];

          if (!productSnap.exists) {
            throw _OrderApiFailure(
              'not-found',
              'Product ${requested['productId']} not found.',
            );
          }

          final product = productSnap.data()!;
          final inventoryCount =
              (product['inventoryCount'] ?? product['stock'] ?? 0) as int;
          final reservedCount = (product['reservedCount'] ?? 0) as int;
          final available = inventoryCount - reservedCount;
          final quantity = requested['quantity'] as int;

          if (available < quantity) {
            throw _OrderApiFailure(
              'failed-precondition',
              '${product['title'] ?? 'Product'} is out of stock.',
            );
          }

          final unitPriceMinor = requested['unitPriceMinor'] as int? ??
              ((product['priceMinor'] as num?)?.toInt() ??
                  ((product['price'] as num?)?.toDouble() ?? 0.0) * 100)
                  .round();

          normalizedItems.add({
            'productId': requested['productId'],
            'title': requested['title'] ?? product['title'] ?? '',
            'description':
                requested['description'] ?? product['description'] ?? '',
            'thumbnail': requested['thumbnail'] ??
                product['thumbnail'] ??
                product['imageUrl'] ??
                '',
            'category': requested['category'] ?? product['category'] ?? '',
            'unitPriceMinor': unitPriceMinor,
            'quantity': quantity,
          });
          subtotalMinor += unitPriceMinor * quantity;

          // Reserve inventory instead of decrementing stock so admins can still cancel safely.
          transaction.update(productRef, {
            'reservedCount': reservedCount + quantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        final totals = computeOrderTotals(
          subtotalMinor: subtotalMinor,
          deliveryFee: deliveryFee,
        );

        final addressJson = shippingAddress.toJson();

        final addressLocation =
            shippingAddress.location.isNotEmpty ? shippingAddress.location : null;

        // Store a product snapshot inside the order so later catalog edits do not rewrite history.
        final orderPayload = <String, dynamic>{
          'userId': uid,
          'status': OrderStatus.awaitingConfirmation.name,
          'paymentStatus': PaymentStatus.payableOnDelivery.name,
          'currency': 'USD',
          'subtotalAmount': totals['subtotalAmount'],
          'deliveryFee': totals['deliveryFee'],
          'deliveryPricing': deliveryPricingSnapshot,
          'totalAmount': totals['totalAmount'],
          'totalMinor': totals['totalMinor'],
          'shippingAddress': [
            addressJson['line1'],
            addressJson['city'],
            addressJson['country'],
          ].where((s) => s != null && s.toString().isNotEmpty).join(', '),
          'shippingAddressData': addressJson,
          'items': normalizedItems.map((item) => {
                'product': {
                  'id': int.tryParse(item['productId'].toString()) ?? 0,
                  'title': item['title'],
                  'description': item['description'],
                  'price': (item['unitPriceMinor'] as int) / 100,
                  'thumbnail': item['thumbnail'],
                  'category': item['category'],
                  'stock': 0,
                },
                'quantity': item['quantity'],
              }).toList(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'adminNote': '',
          'cancelReason': null,
          'assignedAdminUid': null,
          'lastStatusChangedAt': FieldValue.serverTimestamp(),
          'deliveredAt': null,
          'customerConfirmedDelivered': false,
          'deliveryLocation': addressLocation,
          'storeLocation': null,
          'deliveryEstimateMinutes': null,
          'deliveryDistanceMeters': null,
          'deliveryRouteStatus': null,
        };

        transaction.set(orderRef, orderPayload);
      });
    } on _OrderApiFailure catch (e) {
      throw FirebaseException(
        plugin: 'order_api',
        code: e.code,
        message: e.message,
      );
    }

    // Write the initial event after the order exists so customer-scoped
    // security rules can read the parent order document successfully.
    await orderEventsRef.add(_buildInitialOrderEvent());

    // Clear the cart (non-transactional, same as the Cloud Function).
    final cartSnapshot =
        await FirestorePaths.cartItems(_firestore, uid).get();
    final batch = _firestore.batch();
    for (final doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    return orderRef.id;
  }

  /// Updates order status (admin only). Validates transition rules.
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus nextStatus,
  }) async {
    final adminUid = await _requireAdmin();

    if (orderId.isEmpty) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'invalid-argument',
        message: 'orderId and nextStatus are required.',
      );
    }

    final orderRef = FirestorePaths.orders(_firestore).doc(orderId);
    final orderSnap = await orderRef.get();
    if (!orderSnap.exists) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'not-found',
        message: 'Order not found.',
      );
    }

    final currentStatus = OrderStatus.values.firstWhere(
      (e) => e.name == orderSnap.data()!['status'],
      orElse: () => OrderStatus.awaitingConfirmation,
    );

    if (!isValidTransition(currentStatus, nextStatus)) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'invalid-argument',
        message: 'invalid-transition',
      );
    }

    final updateData = <String, dynamic>{
      'status': nextStatus.name,
      'assignedAdminUid': adminUid,
      'lastStatusChangedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Compute delivery ETA when dispatching for delivery.
    if (nextStatus == OrderStatus.outForDelivery) {
      final data = orderSnap.data()!;
      final addressData =
          data['shippingAddressData'] as Map<String, dynamic>? ?? {};
      final location =
          addressData['location'] as Map<String, dynamic>? ?? {};
      final deliveryLat = (location['lat'] as num?)?.toDouble();
      final deliveryLng = (location['lng'] as num?)?.toDouble();

      if (deliveryLat != null && deliveryLng != null) {
        // Default store location (Beirut).
        const storeLat = 33.8938;
        const storeLng = 35.5018;
        final distanceMeters = DeliveryPlanning.haversineDistanceMeters(
          lat1: storeLat,
          lng1: storeLng,
          lat2: deliveryLat,
          lng2: deliveryLng,
        );
        // Estimate driving time: ~40 km/h average in Lebanese traffic.
        final drivingMinutes = (distanceMeters / 1000 / 40 * 60).ceil();
        final etaMinutes = drivingMinutes;
        updateData['deliveryEtaMinutes'] = etaMinutes;
        updateData['deliveryEtaRangeMinMinutes'] = (etaMinutes * 0.8).floor();
        updateData['deliveryEtaRangeMaxMinutes'] = (etaMinutes * 1.3).round();
        updateData['storeLocation'] = {'lat': storeLat, 'lng': storeLng};
        updateData['deliveryLocation'] = {
          'lat': deliveryLat,
          'lng': deliveryLng,
        };
        updateData['deliveryDistanceMeters'] = distanceMeters.round();
      } else {
        // No location data — use reasonable defaults.
        const etaMinutes = 30;
        updateData['deliveryEtaMinutes'] = etaMinutes;
        updateData['deliveryEtaRangeMinMinutes'] = (etaMinutes * 0.8).floor();
        updateData['deliveryEtaRangeMaxMinutes'] = (etaMinutes * 1.3).round();
      }
    }

    await orderRef.update(updateData);

    await FirestorePaths.orderEvents(_firestore, orderId).add(
      _buildEvent(
        type: nextStatus.name,
        message: 'Order moved to ${nextStatus.name}.',
        actor: 'admin',
        actorUid: adminUid,
        metadata: {
          'previousStatus': currentStatus.name,
          'nextStatus': nextStatus.name,
        },
      ),
    );
  }

  /// Adds an admin note to an order (admin only).
  Future<void> addOrderAdminNote({
    required String orderId,
    required String note,
  }) async {
    final adminUid = await _requireAdmin();

    if (orderId.isEmpty || note.trim().isEmpty) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'invalid-argument',
        message: 'orderId and note are required.',
      );
    }

    final orderRef = FirestorePaths.orders(_firestore).doc(orderId);
    final orderSnap = await orderRef.get();
    if (!orderSnap.exists) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'not-found',
        message: 'Order not found.',
      );
    }

    await orderRef.update({
      'adminNote': note.trim(),
      'assignedAdminUid': adminUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await FirestorePaths.orderEvents(_firestore, orderId).add(
      _buildEvent(
        type: 'admin_note',
        message: note.trim(),
        actor: 'admin',
        actorUid: adminUid,
        metadata: {'note': note.trim()},
      ),
    );
  }

  /// Cancels an order with a reason (admin only).
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    final adminUid = await _requireAdmin();

    if (orderId.isEmpty || reason.trim().isEmpty) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'invalid-argument',
        message: 'orderId and reason are required.',
      );
    }

    final orderRef = FirestorePaths.orders(_firestore).doc(orderId);
    final orderSnap = await orderRef.get();
    if (!orderSnap.exists) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'not-found',
        message: 'Order not found.',
      );
    }

    final status = orderSnap.data()!['status'] as String?;
    if (status == 'delivered' || status == 'cancelled') {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'invalid-argument',
        message: 'invalid-transition',
      );
    }

    await orderRef.update({
      'status': OrderStatus.cancelled.name,
      'cancelReason': reason.trim(),
      'assignedAdminUid': adminUid,
      'lastStatusChangedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await FirestorePaths.orderEvents(_firestore, orderId).add(
      _buildEvent(
        type: 'cancelled',
        message: reason.trim(),
        actor: 'admin',
        actorUid: adminUid,
        metadata: {
          'previousStatus': status,
          'nextStatus': 'cancelled',
          'reason': reason.trim(),
        },
      ),
    );
  }

  /// Customer confirms order delivery.
  Future<void> confirmOrderDelivered({
    required String orderId,
  }) async {
    final uid = _requireAuth();

    if (orderId.isEmpty) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'invalid-argument',
        message: 'orderId is required.',
      );
    }

    final orderRef = FirestorePaths.orders(_firestore).doc(orderId);
    final orderSnap = await orderRef.get();
    if (!orderSnap.exists) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'not-found',
        message: 'Order not found.',
      );
    }

    final data = orderSnap.data()!;
    final orderStatus = OrderStatus.values.firstWhere(
      (e) => e.name == data['status'],
      orElse: () => OrderStatus.awaitingConfirmation,
    );
    final orderUserId = data['userId'] as String? ?? '';

    if (!canCustomerConfirmDelivered(
      orderStatus: orderStatus,
      orderUserId: orderUserId,
      callerUid: uid,
    )) {
      throw FirebaseException(
        plugin: 'order_api',
        code: 'invalid-argument',
        message: 'invalid-transition',
      );
    }

    await orderRef.update({
      'status': OrderStatus.delivered.name,
      'deliveredAt': FieldValue.serverTimestamp(),
      'customerConfirmedDelivered': true,
      'lastStatusChangedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await FirestorePaths.orderEvents(_firestore, orderId).add(
      _buildEvent(
        type: 'delivered',
        message: 'Customer confirmed delivery.',
        actor: 'customer',
        actorUid: uid,
        metadata: {
          'previousStatus': 'outForDelivery',
          'nextStatus': 'delivered',
        },
      ),
    );
  }
}

class _OrderApiFailure implements Exception {
  const _OrderApiFailure(this.code, this.message);

  final String code;
  final String message;
}
