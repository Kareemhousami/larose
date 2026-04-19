import 'package:flutter/foundation.dart';

import '../models/delivery_settings.dart';
import '../services/api/delivery_api.dart';

/// Manages admin delivery settings form state.
class AdminDeliverySettingsViewModel extends ChangeNotifier {
  AdminDeliverySettingsViewModel({DeliveryApi? deliveryApi})
      : _deliveryApi = deliveryApi ?? DeliveryApi();

  final DeliveryApi _deliveryApi;

  DeliverySettings? _settings;
  bool _isLoading = false;
  String? _error;

  DeliverySettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _settings = await _deliveryApi.getDeliverySettings();
    } catch (e) {
      _error = 'Failed to load delivery settings.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> save(DeliverySettings settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _deliveryApi.saveDeliverySettings(settings);
      _settings = settings;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save delivery settings.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
