import 'dart:math';

/// Result of a delivery fee calculation.
class DeliveryFeeResult {
  const DeliveryFeeResult({
    required this.finalFeeUsd,
    required this.fuelCostUsd,
    required this.litersUsed,
  });

  final double finalFeeUsd;
  final double fuelCostUsd;
  final double litersUsed;
}

/// Pure delivery pricing helpers — no Firebase dependency.
class DeliveryPricing {
  DeliveryPricing._();

  static DeliveryFeeResult calculateDeliveryFee({
    required double distanceMeters,
    required double fuelPricePerLiter,
    required double avgKilometersPerLiter,
    required double operationalOverheadUsd,
    required double profitMarginPercent,
    required double minimumDeliveryFeeUsd,
    required double maximumDeliveryFeeUsd,
  }) {
    final distanceKm = distanceMeters / 1000;
    final litersUsed = distanceKm / avgKilometersPerLiter;
    final fuelCostUsd = litersUsed * fuelPricePerLiter;
    final beforeProfit = fuelCostUsd + operationalOverheadUsd;
    final withProfit = beforeProfit * (1 + profitMarginPercent / 100);
    final clamped = max(minimumDeliveryFeeUsd, min(maximumDeliveryFeeUsd, withProfit));
    final finalFee = (clamped * 100).roundToDouble() / 100;
    return DeliveryFeeResult(
      finalFeeUsd: finalFee,
      fuelCostUsd: (fuelCostUsd * 100).roundToDouble() / 100,
      litersUsed: (litersUsed * 100).roundToDouble() / 100,
    );
  }

  static Map<String, dynamic> buildLockedPricingSnapshot({
    required double distanceMeters,
    required double fuelPricePerLiter,
    required String fuelSource,
    required double avgKilometersPerLiter,
    required double operationalOverheadUsd,
    required double profitMarginPercent,
    required double minimumDeliveryFeeUsd,
    required double maximumDeliveryFeeUsd,
  }) {
    final result = calculateDeliveryFee(
      distanceMeters: distanceMeters,
      fuelPricePerLiter: fuelPricePerLiter,
      avgKilometersPerLiter: avgKilometersPerLiter,
      operationalOverheadUsd: operationalOverheadUsd,
      profitMarginPercent: profitMarginPercent,
      minimumDeliveryFeeUsd: minimumDeliveryFeeUsd,
      maximumDeliveryFeeUsd: maximumDeliveryFeeUsd,
    );
    return {
      'deliveryFee': result.finalFeeUsd,
      'pricingVersion': 1,
      'fuelSource': fuelSource,
      'fuelPricePerLiter': fuelPricePerLiter,
      'routeDistanceMeters': distanceMeters.round(),
      'fuelCostUsd': result.fuelCostUsd,
      'litersUsed': result.litersUsed,
    };
  }
}
