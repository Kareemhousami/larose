import 'dart:math';

/// Pure delivery planning helpers — no Firebase dependency.
class DeliveryPlanning {
  DeliveryPlanning._();

  static double haversineDistanceMeters({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    return 2 * earthRadius * asin(sqrt(a));
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
