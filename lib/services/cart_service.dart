import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import 'firestore_paths.dart';

/// Persists the user's cart in Firestore.
class CartService {
  CartService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  Future<List<CartItem>> getCartItems(String uid) async {
    final snapshot = await FirestorePaths.cartItems(firestore, uid).get();
    return snapshot.docs
        .map((doc) => CartItem.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  Future<void> setCartItem(String uid, Product product, int quantity) async {
    final ref = FirestorePaths.cartItems(firestore, uid).doc('${product.id}');
    if (quantity <= 0) {
      await ref.delete();
      return;
    }
    final item = CartItem(product: product, quantity: quantity);
    await ref.set(
      {
        ...item.toJson(forCart: true),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> removeCartItem(String uid, int productId) {
    return FirestorePaths.cartItems(firestore, uid).doc('$productId').delete();
  }

  Future<void> clearCart(String uid) async {
    final snapshot = await FirestorePaths.cartItems(firestore, uid).get();
    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
