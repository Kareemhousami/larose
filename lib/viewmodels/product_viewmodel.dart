import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/catalog_service.dart';

/// Manages product data fetched from Firestore.
class ProductViewModel extends ChangeNotifier {
  ProductViewModel({CatalogService? catalogService})
    : _catalogService = catalogService ?? CatalogService();

  final CatalogService _catalogService;

  List<Product> _products = [];
  List<Product> _searchResults = [];
  List<String> _categories = [];
  List<String> _flowerTypes = [];
  String? _selectedCategory;
  String? _selectedFlowerType;
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<Product> get searchResults => _searchResults;
  List<String> get categories => _categories;
  List<String> get flowerTypes => _flowerTypes;
  String? get selectedCategory => _selectedCategory;
  String? get selectedOccasion => _selectedCategory;
  String? get selectedFlowerType => _selectedFlowerType;
  bool get hasActiveFilters =>
      _selectedCategory != null || _selectedFlowerType != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts({String? category, String? flowerType}) async {
    _isLoading = true;
    _error = null;
    _products = [];
    _selectedCategory = category;
    _selectedFlowerType = flowerType;
    notifyListeners();
    try {
      _products = await _catalogService.getProducts(
        category: category,
        flowerType: flowerType,
      );
    } catch (_) {
      _error = 'Failed to load products';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> applyFilters({String? category, String? flowerType}) {
    return fetchProducts(category: category, flowerType: flowerType);
  }

  Future<void> filterByCategory(String? category) {
    return fetchProducts(category: category, flowerType: _selectedFlowerType);
  }

  Future<void> filterByOccasion(String? occasion) {
    return fetchProducts(category: occasion, flowerType: _selectedFlowerType);
  }

  Future<void> filterByFlowerType(String? flowerType) {
    return fetchProducts(category: _selectedCategory, flowerType: flowerType);
  }

  Future<void> clearOccasion() {
    return fetchProducts(flowerType: _selectedFlowerType);
  }

  Future<void> clearFlowerType() {
    return fetchProducts(category: _selectedCategory);
  }

  Future<void> clearFilters() {
    return fetchProducts();
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _catalogService.getCategories();
    } catch (_) {
      _error = 'Failed to load categories';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFlowerTypes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _flowerTypes = await _catalogService.getFlowerTypes();
      final preferredOrder = CatalogService.supportedFlowerTypeNamesById.values
          .toList(growable: false);
      _flowerTypes.sort((left, right) {
        final leftIndex = preferredOrder.indexOf(left);
        final rightIndex = preferredOrder.indexOf(right);
        // Unknown labels still show up, but always after the curated storefront order.
        if (leftIndex == -1 && rightIndex == -1) {
          return left.compareTo(right);
        }
        if (leftIndex == -1) {
          return 1;
        }
        if (rightIndex == -1) {
          return -1;
        }
        return leftIndex.compareTo(rightIndex);
      });
    } catch (_) {
      _error = 'Failed to load flower types';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      // Clearing the search box should immediately clear stale results.
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      _searchResults = await _catalogService.searchProducts(query);
    } catch (_) {
      _error = 'Search failed';
    }
    _isLoading = false;
    notifyListeners();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Product?> fetchProductById(int id) async {
    try {
      return await _catalogService.getProduct(id);
    } catch (_) {
      _error = 'Failed to load product';
      notifyListeners();
      return null;
    }
  }
}
