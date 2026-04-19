import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around [SharedPreferences] for local persistence.
///
/// Uses a singleton pattern. Keys for app data:
/// - `auth_token` — login token
/// - `favorites` — JSON list of favorited product IDs
/// - `dark_mode` — theme preference
/// - `addresses` — JSON list of saved addresses
/// - `payment_methods` — JSON list of saved cards (masked)
class StorageService {
  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  /// Returns the singleton [StorageService] instance.
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // ───── String ─────

  /// Saves a string [value] for the given [key].
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Retrieves a string for the given [key], or null if not set.
  String? getString(String key) {
    return _prefs.getString(key);
  }

  // ───── Bool ─────

  /// Saves a boolean [value] for the given [key].
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Retrieves a boolean for the given [key], or null if not set.
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // ───── Remove / Clear ─────

  /// Removes the value at the given [key].
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Clears all stored preferences.
  Future<void> clear() async {
    await _prefs.clear();
  }

  // ───── Favorites helpers ──���──

  /// Retrieves the list of favorited product IDs.
  List<int> getFavoriteIds() {
    final raw = _prefs.getString('favorites');
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => e as int).toList();
  }

  /// Saves the list of favorited product [ids].
  Future<void> saveFavoriteIds(List<int> ids) async {
    await _prefs.setString('favorites', jsonEncode(ids));
  }

  // ───── Addresses helpers ─────

  /// Retrieves saved addresses.
  List<Map<String, dynamic>> getAddresses() {
    final raw = _prefs.getString('addresses');
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Saves the list of [addresses].
  Future<void> saveAddresses(List<Map<String, dynamic>> addresses) async {
    await _prefs.setString('addresses', jsonEncode(addresses));
  }

  // ───── Payment methods helpers ─────

  /// Retrieves saved payment methods.
  List<Map<String, dynamic>> getPaymentMethods() {
    final raw = _prefs.getString('payment_methods');
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Saves the list of [methods].
  Future<void> savePaymentMethods(List<Map<String, dynamic>> methods) async {
    await _prefs.setString('payment_methods', jsonEncode(methods));
  }
}
