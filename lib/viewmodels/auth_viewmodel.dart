import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthErrorAction {
  none,
  goToSignup,
  goToLogin,
}

/// Manages authentication state and dark mode preference.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthService? authService})
      : _authService = authService;

  AuthService? _authService;
  AuthService get _service => _authService ??= AuthService();

  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isDarkMode = false;
  String? _error;
  AuthErrorAction _errorAction = AuthErrorAction.none;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin == true;
  bool get isDarkMode => _isDarkMode;
  String? get error => _error;
  AuthErrorAction get errorAction => _errorAction;

  Future<void> init() async {
    final storage = await StorageService.getInstance();
    _isDarkMode = storage.getBool('dark_mode') ?? false;
    _user = await _service.getCurrentUser();
    _isInitialized = true;
    notifyListeners();

    _service.authStateChanges().listen((_) async {
      _user = await _service.getCurrentUser();
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearErrorState();
    try {
      _user = await _service.signIn(email, password);
      _setLoading(false);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _applyAuthError(_mapLoginError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _error = _fallbackError('Unable to sign in.', e);
      _errorAction = AuthErrorAction.none;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _setLoading(true);
    _clearErrorState();
    try {
      final parts = name.trim().split(RegExp(r'\s+'));
      _user = await _service.signUp(
        email: email,
        password: password,
        firstName: parts.isNotEmpty ? parts.first : '',
        lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
      );
      _setLoading(false);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _applyAuthError(_mapSignupError(e));
      _setLoading(false);
      return false;
    } catch (e) {
      _error = _fallbackError('Signup failed.', e);
      _errorAction = AuthErrorAction.none;
      _setLoading(false);
      return false;
    }
  }

  Future<ProfileUpdateResult?> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final user = _user;
    if (user == null) {
      _error = 'You must be logged in to update your profile.';
      _errorAction = AuthErrorAction.none;
      notifyListeners();
      return null;
    }
    _setLoading(true);
    _clearErrorState();
    try {
      final result = await _service.updateProfile(
        uid: user.id,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      _user = result.user;
      _setLoading(false);
      return result;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _applyAuthError(_mapGenericAuthError(e));
      _setLoading(false);
      return null;
    } catch (e) {
      _error = _fallbackError('Failed to save profile changes.', e);
      _errorAction = AuthErrorAction.none;
      _setLoading(false);
      return null;
    }
  }

  Future<void> resetPassword(String email) {
    return _service.sendPasswordResetEmail(email);
  }

  Future<void> logout() async {
    await _service.signOut();
    _user = null;
    _clearErrorState();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final storage = await StorageService.getInstance();
    await storage.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  void clearError() {
    _clearErrorState();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearErrorState() {
    _error = null;
    _errorAction = AuthErrorAction.none;
  }

  void _applyAuthError((String, AuthErrorAction) authError) {
    _error = authError.$1;
    _errorAction = authError.$2;
  }

  (String, AuthErrorAction) _mapLoginError(
    firebase_auth.FirebaseAuthException exception,
  ) {
    switch (exception.code) {
      case 'invalid-email':
        return (
          'Please enter a valid email address.',
          AuthErrorAction.none,
        );
      case 'user-not-found':
      case 'invalid-credential':
        return (
          'This account does not exist. Create one instead.',
          AuthErrorAction.goToSignup,
        );
      case 'wrong-password':
        return (
          'Incorrect password. Please try again.',
          AuthErrorAction.none,
        );
      case 'network-request-failed':
        return (
          'No internet connection. Please check your network.',
          AuthErrorAction.none,
        );
      default:
        return (
          _fallbackError('Unable to sign in.', exception),
          AuthErrorAction.none,
        );
    }
  }

  (String, AuthErrorAction) _mapSignupError(
    firebase_auth.FirebaseAuthException exception,
  ) {
    switch (exception.code) {
      case 'invalid-email':
        return (
          'Please enter a valid email address.',
          AuthErrorAction.none,
        );
      case 'email-already-in-use':
        return (
          'An account with this email already exists.',
          AuthErrorAction.goToLogin,
        );
      case 'weak-password':
        return (
          'Password is too weak. Use at least 6 characters.',
          AuthErrorAction.none,
        );
      case 'network-request-failed':
        return (
          'No internet connection. Please check your network.',
          AuthErrorAction.none,
        );
      default:
        return (
          _fallbackError('Signup failed.', exception),
          AuthErrorAction.none,
        );
    }
  }

  (String, AuthErrorAction) _mapGenericAuthError(
    firebase_auth.FirebaseAuthException exception,
  ) {
    switch (exception.code) {
      case 'wrong-password':
        return ('Incorrect password. Please try again.', AuthErrorAction.none);
      case 'user-not-found':
        return (
          'No account was found with this email.',
          AuthErrorAction.none,
        );
      case 'invalid-email':
        return (
          'Please enter a valid email address.',
          AuthErrorAction.none,
        );
      case 'email-already-in-use':
        return (
          'An account with this email already exists.',
          AuthErrorAction.none,
        );
      case 'weak-password':
        return (
          'Password is too weak. Use at least 6 characters.',
          AuthErrorAction.none,
        );
      case 'requires-recent-login':
        return (
          'Please sign in again before changing your email address.',
          AuthErrorAction.none,
        );
      case 'network-request-failed':
        return (
          'No internet connection. Please check your network.',
          AuthErrorAction.none,
        );
      default:
        return (
          _fallbackError('Authentication failed.', exception),
          AuthErrorAction.none,
        );
    }
  }

  String _fallbackError(String message, Object error) {
    if (kDebugMode) {
      return '$message ${error.toString()}';
    }
    return message;
  }
}
