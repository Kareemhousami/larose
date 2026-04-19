import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import 'catalog_service.dart';
import 'firestore_paths.dart';

/// Persists user favorites in Firestore.
class FavoritesService {
  FavoritesService({
    FirebaseFirestore? firestore,
    CatalogService? catalogService,
  })  : _firestore = firestore,
        _catalogService = catalogService ?? CatalogService(firestore: firestore);

  final FirebaseFirestore? _firestore;
  final CatalogService _catalogService;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  Future<List<int>> getFavoriteIds(String uid) async {
    final snapshot = await FirestorePaths.favorites(firestore, uid).get();
    return snapshot.docs
        .map((doc) => int.tryParse(doc.id) ?? 0)
        .where((id) => id != 0)
        .toList();
  }

  Future<List<Product>> getFavoriteProducts(String uid) async {
    final ids = await getFavoriteIds(uid);
    if (ids.isEmpty) {
      return [];
    }
    final products = await _catalogService.getProducts(limit: 100);
    return products.where((product) => ids.contains(product.id)).toList();
  }

  Future<void> setFavorite(String uid, Product product, bool isFavorite) async {
    final ref = FirestorePaths.favorites(firestore, uid).doc('${product.id}');
    if (isFavorite) {
      await ref.set({
        'productId': product.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }
    await ref.delete();
  }
}
