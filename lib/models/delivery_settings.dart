/// Delivery-planning and pricing controls managed by admins.
class DeliverySettings {
  const DeliverySettings({
    required this.storeLabel,
    required this.storeLocation,
    required this.fallbackFuelPricePerLiter,
    required this.avgKilometersPerLiter,
    required this.operationalOverheadUsd,
    required this.profitMarginPercent,
    required this.minimumDeliveryFeeUsd,
    required this.maximumDeliveryFeeUsd,
    required this.serviceMinutesPerStop,
  });

  final String storeLabel;
  final Map<String, dynamic> storeLocation;
  final double fallbackFuelPricePerLiter;
  final double avgKilometersPerLiter;
  final double operationalOverheadUsd;
  final double profitMarginPercent;
  final double minimumDeliveryFeeUsd;
  final double maximumDeliveryFeeUsd;
  final int serviceMinutesPerStop;

  factory DeliverySettings.fromJson(Map<String, dynamic> json) {
    return DeliverySettings(
      storeLabel: json['storeLabel'] as String? ?? '',
      storeLocation: json['storeLocation'] is Map
          ? Map<String, dynamic>.from(
              json['storeLocation'] as Map<dynamic, dynamic>,
            )
          : const {},
      fallbackFuelPricePerLiter:
          (json['fallbackFuelPricePerLiter'] as num?)?.toDouble() ?? 0,
      avgKilometersPerLiter:
          (json['avgKilometersPerLiter'] as num?)?.toDouble() ?? 0,
      operationalOverheadUsd:
          (json['operationalOverheadUsd'] as num?)?.toDouble() ?? 0,
      profitMarginPercent:
          (json['profitMarginPercent'] as num?)?.toDouble() ?? 0,
      minimumDeliveryFeeUsd:
          (json['minimumDeliveryFeeUsd'] as num?)?.toDouble() ?? 0,
      maximumDeliveryFeeUsd:
          (json['maximumDeliveryFeeUsd'] as num?)?.toDouble() ?? 0,
      serviceMinutesPerStop:
          (json['serviceMinutesPerStop'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeLabel': storeLabel,
      'storeLocation': storeLocation,
      'fallbackFuelPricePerLiter': fallbackFuelPricePerLiter,
      'avgKilometersPerLiter': avgKilometersPerLiter,
      'operationalOverheadUsd': operationalOverheadUsd,
      'profitMarginPercent': profitMarginPercent,
      'minimumDeliveryFeeUsd': minimumDeliveryFeeUsd,
      'maximumDeliveryFeeUsd': maximumDeliveryFeeUsd,
      'serviceMinutesPerStop': serviceMinutesPerStop,
    };
  }
}
