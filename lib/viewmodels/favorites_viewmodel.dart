import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;

import '../models/product.dart';
import '../services/favorites_service.dart';

/// Manages the user's favorite products stored in Firestore.
class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel({FavoritesService? favoritesService})
      : _favoritesService = favoritesService ?? FavoritesService();

  final FavoritesService _favoritesService;

  String? _uid;
  final List<Product> _favorites = [];
  List<int> _favoriteIds = [];
  String? _error;

  List<Product> get favorites => List.unmodifiable(_favorites);
  String? get error => _error;

  Future<void> bindUser(String? uid) async {
    if (_uid == uid) {
      return;
    }
    _uid = uid;
    _favorites.clear();
    _favoriteIds = [];
    notifyListeners();
    if (uid == null || uid.isEmpty) {
      return;
    }
    _error = null;
    try {
      _favoriteIds = await _favoritesService.getFavoriteIds(uid);
      final products = await _favoritesService.getFavoriteProducts(uid);
      _favorites
        ..clear()
        ..addAll(products);
    } on FirebaseException catch (e) {
      _error = _mapFavoritesError(
        e,
        defaultMessage: 'Unable to load your favorites right now.',
      );
    } catch (e) {
      _error = _fallbackError('Unable to load your favorites right now.', e);
    }
    notifyListeners();
  }

  bool isFavorite(int productId) => _favoriteIds.contains(productId);

  Future<void> toggleFavorite(Product product) async {
    final uid = _uid;
    final makeFavorite = !isFavorite(product.id);
    _error = null;
    final previousFavoriteIds = List<int>.from(_favoriteIds);
    final previousFavorites = List<Product>.from(_favorites);

    if (makeFavorite) {
      _favoriteIds.add(product.id);
      _favorites.add(product);
    } else {
      _favoriteIds.remove(product.id);
      _favorites.removeWhere((item) => item.id == product.id);
    }
    notifyListeners();

    try {
      if (uid != null) {
        await _favoritesService.setFavorite(uid, product, makeFavorite);
      }
    } on FirebaseException catch (e) {
      _favoriteIds = previousFavoriteIds;
      _favorites
        ..clear()
        ..addAll(previousFavorites);
      _error = _mapFavoritesError(
        e,
        defaultMessage: 'Unable to update your favorites right now.',
      );
      notifyListeners();
    } catch (e) {
      _favoriteIds = previousFavoriteIds;
      _favorites
        ..clear()
        ..addAll(previousFavorites);
      _error = _fallbackError('Unable to update your favorites right now.', e);
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(int productId) async {
    final uid = _uid;
    final product = _favorites.cast<Product?>().firstWhere(
          (item) => item?.id == productId,
          orElse: () => null,
        );
    _error = null;
    final previousFavoriteIds = List<int>.from(_favoriteIds);
    final previousFavorites = List<Product>.from(_favorites);
    _favoriteIds.remove(productId);
    _favorites.removeWhere((item) => item.id == productId);
    notifyListeners();

    try {
      if (uid != null && product != null) {
        await _favoritesService.setFavorite(uid, product, false);
      }
    } on FirebaseException catch (e) {
      _favoriteIds = previousFavoriteIds;
      _favorites
        ..clear()
        ..addAll(previousFavorites);
      _error = _mapFavoritesError(
        e,
        defaultMessage: 'Unable to remove this favorite right now.',
      );
      notifyListeners();
    } catch (e) {
      _favoriteIds = previousFavoriteIds;
      _favorites
        ..clear()
        ..addAll(previousFavorites);
      _error = _fallbackError('Unable to remove this favorite right now.', e);
      notifyListeners();
    }
  }

  String _mapFavoritesError(
    FirebaseException exception, {
    required String defaultMessage,
  }) {
    switch (exception.code) {
      case 'permission-denied':
        return 'You do not have permission to update favorites.';
      case 'unavailable':
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return _fallbackError(defaultMessage, exception);
    }
  }

  String _fallbackError(String message, Object error) {
    if (kDebugMode) {
      return '$message ${error.toString()}';
    }
    return message;
  }
}
