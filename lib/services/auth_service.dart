import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/user.dart';
import 'firestore_paths.dart';

class ProfileUpdateResult {
  const ProfileUpdateResult({
    required this.user,
    this.emailVerificationRequired = false,
    this.message,
  });

  final User user;
  final bool emailVerificationRequired;
  final String? message;
}

/// Handles Firebase Auth and user profile persistence.
class AuthService {
  AuthService({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<firebase_auth.User?> authStateChanges() => _auth.authStateChanges();

  Future<User?> getCurrentUser() async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      return null;
    }
    return _loadProfile(authUser);
  }

  Future<User> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _loadProfile(credential.user!);
  }

  Future<User> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _profileDoc(credential.user!.uid).set({
      'id': credential.user!.uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'username': '$firstName $lastName'.trim().toLowerCase().replaceAll(' ', '.'),
      'avatarUrl': credential.user!.photoURL ?? '',
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return _loadProfile(credential.user!);
  }

  Future<ProfileUpdateResult> updateProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw StateError('No active user session');
    }

    final emailChanged = authUser.email != email;
    if (emailChanged) {
      await authUser.verifyBeforeUpdateEmail(email);
    }

    final updatePayload = <String, dynamic>{
      'id': uid,
      'firstName': firstName,
      'lastName': lastName,
      'username': '$firstName $lastName'.trim().toLowerCase().replaceAll(' ', '.'),
      'avatarUrl': authUser.photoURL ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!emailChanged) {
      updatePayload['email'] = email;
    }

    await _profileDoc(uid).set(updatePayload, SetOptions(merge: true));

    final updatedUser = await _loadProfile(authUser);
    return ProfileUpdateResult(
      user: updatedUser,
      emailVerificationRequired: emailChanged,
      message: emailChanged
          ? 'A verification email has been sent to your new address. Please verify it to complete the change.'
          : 'Profile updated successfully.',
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();

  Future<Map<String, bool>> getNotificationPreferences() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No active user session');
    }

    final snapshot = await _profileDoc(uid).get();
    final data = snapshot.data();
    final rawPreferences = data?['notificationPreferences'];
    if (rawPreferences is! Map) {
      return const {};
    }
    return rawPreferences.map(
      (key, value) => MapEntry(key.toString(), value == true),
    );
  }

  Future<void> updateNotificationPreferences(
    Map<String, bool> preferences,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No active user session');
    }

    await _profileDoc(uid).set(
      {
        'notificationPreferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<Map<String, bool>> getPrivacySettings() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No active user session');
    }

    final snapshot = await _profileDoc(uid).get();
    final data = snapshot.data();
    final rawSettings = data?['privacySettings'];
    if (rawSettings is! Map) {
      return const {};
    }
    return rawSettings.map(
      (key, value) => MapEntry(key.toString(), value == true),
    );
  }

  Future<void> updatePrivacySettings(
    Map<String, bool> settings,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No active user session');
    }

    await _profileDoc(uid).set(
      {
        'privacySettings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<User> _loadProfile(firebase_auth.User authUser) async {
    final doc = _profileDoc(authUser.uid);
    final snapshot = await doc.get();
    final tokenResult = await authUser.getIdTokenResult(true);
    final isAdmin = tokenResult.claims?['admin'] == true;
    if (!snapshot.exists) {
      final names = _splitName(authUser.displayName);
      await doc.set({
        'id': authUser.uid,
        'email': authUser.email ?? '',
        'firstName': names.$1,
        'lastName': names.$2,
        'username': (authUser.displayName ?? authUser.email ?? 'la_rose_user')
            .toLowerCase()
            .replaceAll(' ', '.'),
        'avatarUrl': authUser.photoURL ?? '',
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final data = (await doc.get()).data() ?? <String, dynamic>{};
    return User.fromJson({
      ...data,
      'id': authUser.uid,
      'email': authUser.email ?? data['email'],
      'isAdmin': isAdmin,
      'role': isAdmin ? 'admin' : data['role'],
    });
  }

  DocumentReference<Map<String, dynamic>> _profileDoc(String uid) =>
      FirestorePaths.users(_firestore).doc(uid);

  (String, String) _splitName(String? displayName) {
    final parts = (displayName ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return ('La', 'Rose');
    }
    if (parts.length == 1) {
      return (parts.first, '');
    }
    return (parts.first, parts.sublist(1).join(' '));
  }
}
