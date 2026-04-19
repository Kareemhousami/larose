import 'package:cloud_firestore/cloud_firestore.dart';

/// Centralizes Firestore collection paths.
class FirestorePaths {
  FirestorePaths._();

  static CollectionReference<Map<String, dynamic>> users(
    FirebaseFirestore firestore,
  ) => firestore.collection('users');

  static CollectionReference<Map<String, dynamic>> products(
    FirebaseFirestore firestore,
  ) => firestore.collection('products');

  static CollectionReference<Map<String, dynamic>> categories(
    FirebaseFirestore firestore,
  ) => firestore.collection('categories');

  static CollectionReference<Map<String, dynamic>> flowerTypes(
    FirebaseFirestore firestore,
  ) => firestore.collection('flower_types');

  static CollectionReference<Map<String, dynamic>> orders(
    FirebaseFirestore firestore,
  ) => firestore.collection('orders');

  static CollectionReference<Map<String, dynamic>> favorites(
    FirebaseFirestore firestore,
    String uid,
  ) => users(firestore).doc(uid).collection('favorites');

  static CollectionReference<Map<String, dynamic>> addresses(
    FirebaseFirestore firestore,
    String uid,
  ) => users(firestore).doc(uid).collection('addresses');

  static CollectionReference<Map<String, dynamic>> cartItems(
    FirebaseFirestore firestore,
    String uid,
  ) => users(firestore).doc(uid).collection('cart').doc('active').collection('items');

  static CollectionReference<Map<String, dynamic>> orderEvents(
    FirebaseFirestore firestore,
    String orderId,
  ) => orders(firestore).doc(orderId).collection('events');
}
