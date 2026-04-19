import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// Shipping address stored for a user.
class Address {
  final String id;
  final String fullName;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String postalCode;
  final String country;
  final String deliveryNote;
  final String locationLabel;
  final String locationSource;
  final Map<String, dynamic> location;
  final bool isDefault;
  final DateTime? createdAt;

  const Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.line1,
    this.line2 = '',
    required this.city,
    required this.postalCode,
    required this.country,
    this.deliveryNote = '',
    this.locationLabel = '',
    this.locationSource = '',
    this.location = const {},
    this.isDefault = false,
    this.createdAt,
  });

  String get shortLabel => locationLabel.isNotEmpty
      ? locationLabel
      : [line1, city].where((value) => value.isNotEmpty).join(', ');

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      line1: json['line1'] as String? ?? json['street'] as String? ?? '',
      line2: json['line2'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? json['postal'] as String? ?? '',
      country: json['country'] as String? ?? '',
      deliveryNote: json['deliveryNote'] as String? ?? '',
      locationLabel: json['locationLabel'] as String? ?? '',
      locationSource: json['locationSource'] as String? ?? '',
      location: json['location'] is Map
          ? Map<String, dynamic>.from(
              json['location'] as Map<dynamic, dynamic>,
            )
          : const {},
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'line1': line1,
      'line2': line2,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'deliveryNote': deliveryNote,
      'locationLabel': locationLabel,
      'locationSource': locationSource,
      'location': location,
      'isDefault': isDefault,
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
