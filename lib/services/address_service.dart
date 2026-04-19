import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/address.dart';
import 'firestore_paths.dart';

/// Manages user addresses in Firestore.
class AddressService {
  AddressService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @visibleForTesting
  static List<Address> deduplicateAddresses(List<Address> addresses) {
    final dedupedByKey = <String, Address>{};
    final order = <String>[];

    for (final address in addresses) {
      final key = _addressUniquenessKey(address);
      final existing = dedupedByKey[key];
      if (existing == null) {
        dedupedByKey[key] = address;
        order.add(key);
        continue;
      }
      if (!existing.isDefault && address.isDefault) {
        dedupedByKey[key] = address;
      }
    }

    return order.map((key) => dedupedByKey[key]!).toList();
  }

  Future<List<Address>> getAddresses(String uid) async {
    final snapshot = await FirestorePaths.addresses(_firestore, uid)
        .orderBy('createdAt', descending: true)
        .get();
    final addresses = snapshot.docs
        .map((doc) => Address.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
    return deduplicateAddresses(addresses);
  }

  Future<void> saveAddress(String uid, Address address) async {
    final collection = FirestorePaths.addresses(_firestore, uid);
    final existingAddresses = address.id.isEmpty ? await getAddresses(uid) : const <Address>[];
    final matchingAddress = address.id.isEmpty
        ? existingAddresses.cast<Address?>().firstWhere(
            (item) => item != null && _addressUniquenessKey(item) == _addressUniquenessKey(address),
            orElse: () => null,
          )
        : null;
    final doc = address.id.isEmpty
        ? collection.doc(matchingAddress?.id ?? collection.doc().id)
        : collection.doc(address.id);

    if (address.isDefault) {
      final existing = await collection.where('isDefault', isEqualTo: true).get();
      final batch = _firestore.batch();
      for (final item in existing.docs) {
        batch.set(item.reference, {'isDefault': false}, SetOptions(merge: true));
      }
      batch.set(doc, {
        ...address.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await batch.commit();
      return;
    }

    await doc.set({
      ...address.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    await FirestorePaths.addresses(_firestore, uid).doc(addressId).delete();
  }

  static String _addressUniquenessKey(Address address) {
    final lat = (address.location['lat'] as num?)?.toDouble();
    final lng = (address.location['lng'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      return 'geo:${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)}';
    }
    return 'id:${address.id}';
  }
}
