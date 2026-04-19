import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;

import '../models/address.dart';
import '../services/address_service.dart';

/// Manages user addresses backed by Firestore.
class AddressViewModel extends ChangeNotifier {
  AddressViewModel({AddressService? addressService})
      : _addressService = addressService ?? AddressService();

  final AddressService _addressService;

  String? _uid;
  final List<Address> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<Address> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  String? get error => _error;
  Address? get defaultAddress => _addresses.cast<Address?>().firstWhere(
        (address) => address?.isDefault == true,
        orElse: () => _addresses.isEmpty ? null : _addresses.first,
      );

  Future<void> bindUser(String? uid) async {
    if (_uid == uid) {
      return;
    }
    _uid = uid;
    _addresses.clear();
    notifyListeners();
    if (uid == null || uid.isEmpty) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final loaded = await _addressService.getAddresses(uid);
      _addresses
        ..clear()
        ..addAll(loaded);
    } on FirebaseException catch (e) {
      _error = _mapAddressError(
        e,
        defaultMessage: 'Unable to load your saved addresses right now.',
      );
    } catch (e) {
      _error = _fallbackError(
        'Unable to load your saved addresses right now.',
        e,
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveAddress(Address address) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('You must be logged in to save an address.');
    }
    final validationError = _validateAddress(address);
    if (validationError != null) {
      _error = validationError;
      notifyListeners();
      throw StateError(validationError);
    }
    _error = null;
    notifyListeners();
    try {
      await _addressService.saveAddress(uid, address);
      await refresh();
    } on FirebaseException catch (e) {
      _error = _mapAddressError(
        e,
        defaultMessage: 'Unable to save your address right now.',
      );
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = _fallbackError('Unable to save your address right now.', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return;
    _error = null;
    notifyListeners();
    try {
      await _addressService.deleteAddress(uid, addressId);
      await refresh();
    } on FirebaseException catch (e) {
      _error = _mapAddressError(
        e,
        defaultMessage: 'Unable to delete address.',
      );
      notifyListeners();
    } catch (e) {
      _error = _fallbackError('Unable to delete address.', e);
      notifyListeners();
    }
  }

  String _mapAddressError(
    FirebaseException exception, {
    required String defaultMessage,
  }) {
    switch (exception.code) {
      case 'permission-denied':
        return 'You do not have permission to update addresses.';
      case 'unavailable':
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return _fallbackError(defaultMessage, exception);
    }
  }

  String? _validateAddress(Address address) {
    final lat = address.location['lat'];
    final lng = address.location['lng'];
    if (lat == null || lng == null) {
      return 'A confirmed map location is required.';
    }
    if (address.phone.trim().isEmpty) {
      return 'Phone is required.';
    }
    if (address.deliveryNote.trim().isEmpty) {
      return 'Delivery note is required.';
    }
    return null;
  }

  String _fallbackError(String message, Object error) {
    if (kDebugMode) {
      return '$message ${error.toString()}';
    }
    return message;
  }
}
