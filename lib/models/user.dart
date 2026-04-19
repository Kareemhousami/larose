import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// Represents an authenticated Firebase user profile.
class User {
  /// Unique user identifier.
  final String id;

  /// User's username.
  final String username;

  /// User's email address.
  final String email;

  /// User's first name.
  final String firstName;

  /// User's last name.
  final String lastName;

  /// User's profile image URL.
  final String image;

  /// Whether the user has admin access in the app.
  final bool isAdmin;

  /// User's avatar URL as stored in Firestore.
  final String? avatarUrl;

  /// When the user document was created.
  final DateTime? createdAt;

  /// When the user document was last updated.
  final DateTime? updatedAt;

  /// Saved notification preferences for the user.
  final Map<String, bool> notificationPreferences;

  /// Saved privacy and security preferences for the user.
  final Map<String, bool> privacySettings;

  /// Creates a [User] instance.
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.isAdmin = false,
    this.image = '',
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.notificationPreferences = const {},
    this.privacySettings = const {},
  });

  /// User's full display name.
  String get fullName => '$firstName $lastName';

  /// Creates a [User] from a Firebase profile document.
  factory User.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final username = json['username'] as String?;
    final resolvedAvatarUrl =
        json['avatarUrl'] as String? ?? json['image'] as String?;
    return User(
      id: json['id'] as String? ?? '',
      username: username ?? _buildUsername(firstName, lastName),
      email: json['email'] as String? ?? '',
      firstName: firstName,
      lastName: lastName,
      isAdmin: json['isAdmin'] == true || json['role'] == 'admin',
      image: resolvedAvatarUrl ?? '',
      avatarUrl: resolvedAvatarUrl,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      notificationPreferences:
          _parseBoolMap(json['notificationPreferences']),
      privacySettings: _parseBoolMap(json['privacySettings']),
    );
  }

  /// Converts this user to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'isAdmin': isAdmin,
      'image': image,
      'avatarUrl': avatarUrl ?? image,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notificationPreferences': notificationPreferences,
      'privacySettings': privacySettings,
    };
  }

  static String _buildUsername(String firstName, String lastName) {
    final base = '$firstName $lastName'.trim();
    if (base.isEmpty) {
      return 'la_rose_user';
    }
    return base.toLowerCase().replaceAll(' ', '.');
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static Map<String, bool> _parseBoolMap(dynamic value) {
    if (value is! Map) {
      return const {};
    }
    return value.map(
      (key, entry) => MapEntry(key.toString(), entry == true),
    );
  }
}
