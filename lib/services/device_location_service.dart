import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Error thrown when device location cannot be resolved.
class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Wraps device geolocation permissions and lookup.
class DeviceLocationService {
  Future<Map<String, double>> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException('Location services are disabled.');
    }

    final permission = await Geolocator.checkPermission();
    final resolvedPermission = permission == LocationPermission.denied
        ? await Geolocator.requestPermission()
        : permission;

    if (resolvedPermission == LocationPermission.denied ||
        resolvedPermission == LocationPermission.deniedForever) {
      throw const LocationServiceException('Location permission denied.');
    }

    final position = await Geolocator.getCurrentPosition();
    return {'lat': position.latitude, 'lng': position.longitude};
  }

  Future<String?> reverseGeocode(double latitude, double longitude) async {
    await setLocaleIdentifier('en_LB');
    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) {
      return null;
    }

    final placemark = placemarks.first;
    final parts = <String?>[
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
      placemark.country,
    ];

    final seen = <String>{};
    final normalized = parts
        .map((part) => part?.trim() ?? '')
        .where((part) => part.isNotEmpty)
        .where((part) => seen.add(part.toLowerCase()))
        .toList();

    if (normalized.isEmpty) {
      return null;
    }

    return normalized.join(', ');
  }
}
