import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/product.dart';
import 'firestore_paths.dart';

/// Reads product and category data from Firestore.
class CatalogService {
  static const Map<String, String> supportedFlowerTypeNamesById = {
    'hydrangeas': 'Hydrangeas',
    'lilies': 'Lilies',
    'mixed-blooms': 'Mixed Blooms',
    'orchids': 'Orchids',
    'peonies': 'Peonies',
    'roses': 'Roses',
    'sunflowers': 'Sunflowers',
    'tulips': 'Tulips',
  };

  static const Map<String, String> supportedCategoryNamesById = {
    'anniversary': 'Anniversary',
    'birthday': 'Birthday',
    'congratulations': 'Congratulations',
    'graduation': 'Graduation',
    'new-baby': 'New Baby',
    'romantic': 'Romantic',
    'sympathy': 'Sympathy',
    'wedding': 'Wedding',
  };

  CatalogService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore,
       _storage = storage;

  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;

  /// Cached download URLs keyed by flower type folder ID.
  final Map<String, List<String>> _storageUrlCache = {};

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;
  FirebaseStorage get storage => _storage ?? FirebaseStorage.instance;

  Future<List<Product>> getProducts({
    int limit = 40,
    String? category,
    String? flowerType,
    bool featuredOnly = false,
  }) async {
    Query<Map<String, dynamic>> query = FirestorePaths.products(firestore)
        .limit(limit);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (flowerType != null && flowerType.isNotEmpty) {
      query = query.where('flowerType', isEqualTo: flowerType);
    }
    if (featuredOnly) {
      query = query.where('featured', isEqualTo: true);
    }

    final snapshot = await query.get();
    final products = snapshot.docs
        .map((doc) => Product.fromJson({'id': doc.id, ...doc.data()}, docId: doc.id))
        .toList();
    // ignore: avoid_print
    print('[CatalogService] getProducts(category=$category, flowerType=$flowerType) → ${products.length} results');
    return _assignStorageImages(products);
  }

  Future<Product> getProduct(int id) async {
    final doc = await FirestorePaths.products(firestore).doc('$id').get();
    if (!doc.exists) {
      throw StateError('Product $id was not found.');
    }
    final product = Product.fromJson({'id': doc.id, ...doc.data()!}, docId: doc.id);
    final resolved = await _assignStorageImages([product]);
    return resolved.first;
  }

  Future<List<String>> getCategories() async {
    final snapshot = await FirestorePaths.categories(firestore)
        .where('active', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  Future<List<String>> getFlowerTypes() async {
    final snapshot = await FirestorePaths.flowerTypes(firestore).get();
    final orderedTypes = <String>[];

    for (final entry in supportedFlowerTypeNamesById.entries) {
      final match = snapshot.docs.where((doc) => doc.id == entry.key).firstOrNull;
      if (match == null) {
        continue;
      }
      final data = match.data();
      final flowerTypeName = data['flowerTypeName'] as String? ?? entry.value;
      orderedTypes.add(flowerTypeName);
    }

    return orderedTypes;
  }

  Future<List<Map<String, dynamic>>> getEventBouquets(String eventId, {int limit = 40}) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getFlowerTypeImagesByName(String flowerType) async {
    return [];
  }

  Future<List<Product>> searchProducts(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return [];
    }
    final products = await getProducts(limit: 100);
    return products.where((product) {
      return product.title.toLowerCase().contains(normalized) ||
          product.description.toLowerCase().contains(normalized) ||
          product.category.toLowerCase().contains(normalized) ||
          product.flowerType.toLowerCase().contains(normalized);
    }).toList();
  }

  /// Converts a flower type display name to its Storage folder ID.
  static String _flowerTypeFolderId(String flowerTypeName) {
    for (final entry in supportedFlowerTypeNamesById.entries) {
      if (entry.value == flowerTypeName) return entry.key;
    }
    return flowerTypeName.toLowerCase().replaceAll(' ', '-');
  }

  /// Converts a category display name to its Storage folder ID.
  static String categoryFolderId(String categoryName) {
    for (final entry in supportedCategoryNamesById.entries) {
      if (entry.value == categoryName) return entry.key;
    }
    return categoryName.toLowerCase().replaceAll(' ', '-');
  }

  /// Fetches and caches download URLs for all images in an arbitrary Storage folder path.
  Future<List<String>> _getFolderImageUrls(String folderPath) async {
    if (_storageUrlCache.containsKey(folderPath)) {
      return _storageUrlCache[folderPath]!;
    }

    try {
      final ref = storage.ref(folderPath);
      final result = await ref.listAll();
      final items = result.items.toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      final urls = <String>[];
      for (final item in items) {
        urls.add(await item.getDownloadURL());
      }
      _storageUrlCache[folderPath] = urls;
      return urls;
    } catch (_) {
      return [];
    }
  }

  /// Replaces product thumbnails and images with Firebase Storage URLs.
  ///
  /// Products with [flowerType] set are resolved from `flower_types/{folderId}/`.
  /// Products with [category] set (and empty [flowerType]) are resolved from
  /// `events/{categoryId}/bouquets/`.
  Future<List<Product>> _assignStorageImages(List<Product> products) async {
    // Group flower-type products by flowerType display name.
    final flowerTypeGroups = <String, List<int>>{};
    // Group event products by category display name.
    final categoryGroups = <String, List<int>>{};

    for (var i = 0; i < products.length; i++) {
      final flowerType = products[i].flowerType;
      final category = products[i].category;
      if (flowerType.isNotEmpty) {
        flowerTypeGroups.putIfAbsent(flowerType, () => []).add(i);
      } else if (category.isNotEmpty) {
        categoryGroups.putIfAbsent(category, () => []).add(i);
      }
    }

    for (final entry in flowerTypeGroups.entries) {
      final folderId = _flowerTypeFolderId(entry.key);
      final urls = await _getFolderImageUrls('flower_types/$folderId');
      if (urls.isEmpty) continue;

      for (var j = 0; j < entry.value.length; j++) {
        final productIndex = entry.value[j];
        final imageIndex = j % urls.length;
        products[productIndex] = products[productIndex].copyWith(
          thumbnail: urls[imageIndex],
          images: urls,
        );
      }
    }

    for (final entry in categoryGroups.entries) {
      final catId = categoryFolderId(entry.key);
      final urls = await _getFolderImageUrls('events/$catId/bouquets');
      if (urls.isEmpty) continue;

      for (var j = 0; j < entry.value.length; j++) {
        final productIndex = entry.value[j];
        final imageIndex = j % urls.length;
        products[productIndex] = products[productIndex].copyWith(
          thumbnail: urls[imageIndex],
          images: urls,
        );
      }
    }

    return products;
  }
}
