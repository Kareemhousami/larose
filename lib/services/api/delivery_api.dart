import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/delivery_settings.dart';
import 'delivery_planning.dart';
import 'delivery_pricing.dart';

/// Firestore-backed delivery operations.
class DeliveryApi {
  DeliveryApi({
    FirebaseFirestore? firestore,
  })  : _explicitFirestore = firestore;

  final FirebaseFirestore? _explicitFirestore;
  FirebaseFirestore get _firestore => _explicitFirestore ?? FirebaseFirestore.instance;

  Future<DeliverySettings?> getDeliverySettings() async {
    final doc = await _firestore
        .collection('delivery_settings')
        .doc('config')
        .get();
    if (!doc.exists) return null;
    return DeliverySettings.fromJson(doc.data()!);
  }

  Future<void> saveDeliverySettings(DeliverySettings settings) async {
    await _firestore
        .collection('delivery_settings')
        .doc('config')
        .set(settings.toJson());
  }

  Future<Map<String, dynamic>> lockDeliveryPricing({
    required double destinationLat,
    required double destinationLng,
  }) async {
    final settings = await getDeliverySettings();
    if (settings == null) {
      return {'deliveryFee': 0.0, 'deliveryPricing': const <String, dynamic>{}};
    }

    final storeLat = (settings.storeLocation['lat'] as num?)?.toDouble() ?? 0;
    final storeLng = (settings.storeLocation['lng'] as num?)?.toDouble() ?? 0;

    final distanceMeters = DeliveryPlanning.haversineDistanceMeters(
      lat1: storeLat, lng1: storeLng,
      lat2: destinationLat, lng2: destinationLng,
    );

    final snapshot = DeliveryPricing.buildLockedPricingSnapshot(
      distanceMeters: distanceMeters,
      fuelPricePerLiter: settings.fallbackFuelPricePerLiter,
      fuelSource: 'fallback',
      avgKilometersPerLiter: settings.avgKilometersPerLiter,
      operationalOverheadUsd: settings.operationalOverheadUsd,
      profitMarginPercent: settings.profitMarginPercent,
      minimumDeliveryFeeUsd: settings.minimumDeliveryFeeUsd,
      maximumDeliveryFeeUsd: settings.maximumDeliveryFeeUsd,
    );

    return snapshot;
  }

}
