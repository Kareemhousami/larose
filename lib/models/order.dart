import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import 'cart_item.dart';

/// Possible statuses for an order.
enum OrderStatus {
  /// Order is awaiting confirmation.
  awaitingConfirmation,

  /// Order is being prepared.
  preparing,

  /// Order preparation is complete.
  donePreparing,

  /// Order is out for delivery.
  outForDelivery,

  /// Order has been delivered.
  delivered,

  /// Order has been cancelled.
  cancelled,
}

/// Cash on delivery payment state.
enum PaymentStatus {
  pending,
  payableOnDelivery,
  completed,
  cancelled,
}

/// Timeline event for an order.
class OrderEvent {
  final String type;
  final String message;
  final DateTime createdAt;
  final String actor;
  final String actorUid;
  final Map<String, dynamic> metadata;

  const OrderEvent({
    required this.type,
    required this.message,
    required this.createdAt,
    this.actor = 'system',
    this.actorUid = '',
    this.metadata = const {},
  });

  factory OrderEvent.fromJson(Map<String, dynamic> json) {
    return OrderEvent(
      type: json['type'] as String? ?? 'update',
      message: json['message'] as String? ?? '',
      createdAt: Order._parseDate(json['createdAt']) ?? DateTime.now(),
      actor: json['actor'] as String? ?? 'system',
      actorUid: json['actorUid'] as String? ?? '',
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(
              json['metadata'] as Map<dynamic, dynamic>,
            )
          : const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'actor': actor,
      'actorUid': actorUid,
      'metadata': metadata,
    };
  }
}

/// Represents a customer order.
class Order {
  /// Unique order identifier.
  final String id;

  /// Items included in the order.
  final List<CartItem> items;

  /// Total order amount in USD.
  final double totalAmount;

  /// Current order status.
  final OrderStatus status;

  /// Current payment status.
  final PaymentStatus paymentStatus;

  /// When the order was placed.
  final DateTime createdAt;

  /// When the order was last updated.
  final DateTime? updatedAt;

  /// Shipping address for the order.
  final String shippingAddress;

  /// Structured shipping address data.
  final Map<String, dynamic> shippingAddressData;

  /// User that owns the order.
  final String userId;

  /// Currency code for pricing.
  final String currency;

  /// Total amount in minor units.
  final int totalMinor;

  /// Order event timeline.
  final List<OrderEvent> events;

  /// Latest admin note for the order.
  final String adminNote;

  /// Cancellation reason when the order is cancelled.
  final String? cancelReason;

  /// Admin currently handling the order.
  final String? assignedAdminUid;

  /// When the order status last changed.
  final DateTime? lastStatusChangedAt;

  /// When the customer confirmed the order was delivered.
  final DateTime? deliveredAt;

  /// Whether the customer confirmed the order delivery.
  final bool customerConfirmedDelivered;

  /// Future ETA estimate in minutes.
  final int? deliveryEstimateMinutes;

  /// Future route distance estimate in meters.
  final int? deliveryDistanceMeters;

  /// Future route state for delivery tracking.
  final String? deliveryRouteStatus;

  /// Assigned courier label for queue-based planning.
  final String courierLabel;

  /// Product subtotal before delivery fee, in USD.
  final double? subtotalAmount;

  /// Locked delivery fee in USD.
  final double? deliveryFee;

  /// Estimated delivery ETA in minutes.
  final int? deliveryEtaMinutes;

  /// Lower bound of the delivery ETA range in minutes.
  final int? deliveryEtaRangeMinMinutes;

  /// Upper bound of the delivery ETA range in minutes.
  final int? deliveryEtaRangeMaxMinutes;

  /// Origin used for the latest ETA calculation.
  final Map<String, dynamic> deliveryOriginSnapshot;

  /// Locked pricing snapshot used at checkout time.
  final Map<String, dynamic> deliveryPricing;

  /// Future delivery destination picked by the customer.
  final Map<String, dynamic> deliveryLocation;

  /// Future store origin coordinates.
  final Map<String, dynamic> storeLocation;

  /// When the delivery ETA was last refreshed.
  final DateTime? deliveryEtaUpdatedAt;


  /// Creates an [Order] instance.
  const Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.paymentStatus = PaymentStatus.payableOnDelivery,
    required this.createdAt,
    this.updatedAt,
    required this.shippingAddress,
    this.shippingAddressData = const {},
    this.userId = '',
    this.currency = 'USD',
    this.totalMinor = 0,
    this.events = const [],
    this.adminNote = '',
    this.cancelReason,
    this.assignedAdminUid,
    this.lastStatusChangedAt,
    this.deliveredAt,
    this.customerConfirmedDelivered = false,
    this.deliveryEstimateMinutes,
    this.deliveryDistanceMeters,
    this.deliveryRouteStatus,
    this.courierLabel = '',
    this.subtotalAmount,
    this.deliveryFee,
    this.deliveryEtaMinutes,
    this.deliveryEtaRangeMinMinutes,
    this.deliveryEtaRangeMaxMinutes,
    this.deliveryOriginSnapshot = const {},
    this.deliveryPricing = const {},
    this.deliveryLocation = const {},
    this.storeLocation = const {},
    this.deliveryEtaUpdatedAt,
  });

  /// Creates an [Order] from a JSON map.
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.awaitingConfirmation,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.payableOnDelivery,
      ),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']),
      shippingAddress: json['shippingAddress'] as String? ?? '',
      shippingAddressData: json['shippingAddressData'] is Map
          ? Map<String, dynamic>.from(
              json['shippingAddressData'] as Map<dynamic, dynamic>,
            )
          : const {},
      userId: json['userId'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      totalMinor: (json['totalMinor'] as num?)?.toInt() ??
          (((json['totalAmount'] as num?)?.toDouble() ?? 0) * 100).round(),
      events: (json['events'] as List<dynamic>? ?? [])
          .map((e) => OrderEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      adminNote: json['adminNote'] as String? ?? '',
      cancelReason: json['cancelReason'] as String?,
      assignedAdminUid: json['assignedAdminUid'] as String?,
      lastStatusChangedAt: _parseDate(json['lastStatusChangedAt']),
      deliveredAt: _parseDate(json['deliveredAt']),
      customerConfirmedDelivered:
          json['customerConfirmedDelivered'] as bool? ?? false,
      deliveryEstimateMinutes:
          (json['deliveryEstimateMinutes'] as num?)?.toInt(),
      deliveryDistanceMeters:
          (json['deliveryDistanceMeters'] as num?)?.toInt(),
      deliveryRouteStatus: json['deliveryRouteStatus'] as String?,
      courierLabel: json['courierLabel'] as String? ?? '',
      subtotalAmount: (json['subtotalAmount'] as num?)?.toDouble(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      deliveryEtaMinutes: (json['deliveryEtaMinutes'] as num?)?.toInt(),
      deliveryEtaRangeMinMinutes:
          (json['deliveryEtaRangeMinMinutes'] as num?)?.toInt(),
      deliveryEtaRangeMaxMinutes:
          (json['deliveryEtaRangeMaxMinutes'] as num?)?.toInt(),
      deliveryOriginSnapshot: json['deliveryOriginSnapshot'] is Map
          ? Map<String, dynamic>.from(
              json['deliveryOriginSnapshot'] as Map<dynamic, dynamic>,
            )
          : const {},
      deliveryPricing: json['deliveryPricing'] is Map
          ? Map<String, dynamic>.from(
              json['deliveryPricing'] as Map<dynamic, dynamic>,
            )
          : const {},
      deliveryLocation: json['deliveryLocation'] is Map
          ? Map<String, dynamic>.from(
              json['deliveryLocation'] as Map<dynamic, dynamic>,
            )
          : const {},
      storeLocation: json['storeLocation'] is Map
          ? Map<String, dynamic>.from(
              json['storeLocation'] as Map<dynamic, dynamic>,
            )
          : const {},
      deliveryEtaUpdatedAt: _parseDate(json['deliveryEtaUpdatedAt']),
    );
  }

  /// Converts this order to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'shippingAddress': shippingAddress,
      'shippingAddressData': shippingAddressData,
      'userId': userId,
      'currency': currency,
      'totalMinor': totalMinor,
      'events': events.map((e) => e.toJson()).toList(),
      'adminNote': adminNote,
      'cancelReason': cancelReason,
      'assignedAdminUid': assignedAdminUid,
      'lastStatusChangedAt': lastStatusChangedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'customerConfirmedDelivered': customerConfirmedDelivered,
      'deliveryEstimateMinutes': deliveryEstimateMinutes,
      'deliveryDistanceMeters': deliveryDistanceMeters,
      'deliveryRouteStatus': deliveryRouteStatus,
      'courierLabel': courierLabel,
      'subtotalAmount': subtotalAmount,
      'deliveryFee': deliveryFee,
      'deliveryEtaMinutes': deliveryEtaMinutes,
      'deliveryEtaRangeMinMinutes': deliveryEtaRangeMinMinutes,
      'deliveryEtaRangeMaxMinutes': deliveryEtaRangeMaxMinutes,
      'deliveryOriginSnapshot': deliveryOriginSnapshot,
      'deliveryPricing': deliveryPricing,
      'deliveryLocation': deliveryLocation,
      'storeLocation': storeLocation,
      'deliveryEtaUpdatedAt': deliveryEtaUpdatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
