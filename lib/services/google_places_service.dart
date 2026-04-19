import 'dart:convert';

import 'package:http/http.dart' as http;

/// Wraps Google Places REST calls used by the address picker flow.
class GooglePlacesService {
  GooglePlacesService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Map<String, dynamic>>> search(
    String query,
    String apiKey, {
    String countryCode = 'lb',
  }) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': query,
        'components': 'country:$countryCode',
        'key': apiKey,
      },
    );
    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['predictions'] as List<dynamic>? ?? [])
        .map((prediction) => Map<String, dynamic>.from(prediction as Map))
        .toList();
  }

  Future<Map<String, dynamic>?> getPlaceDetails(
    String placeId,
    String apiKey,
  ) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'fields': 'formatted_address,geometry,name',
        'key': apiKey,
      },
    );
    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final result = body['result'];
    if (result is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(result);
  }

  Future<String?> reverseGeocode(
    double lat,
    double lng,
    String apiKey, {
    String countryCode = 'lb',
    String languageCode = 'en',
  }) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': '$lat,$lng',
        'language': languageCode,
        'region': countryCode,
        'key': apiKey,
      },
    );
    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = body['status'] as String?;
    if (status == 'ZERO_RESULTS') {
      return null;
    }
    final results = body['results'] as List<dynamic>? ?? const [];
    if (results.isEmpty) {
      return null;
    }
    final first = results.first;
    if (first is! Map) {
      return null;
    }
    return first['formatted_address'] as String?;
  }
}
