import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// User model for Heartly AI
class User {
  final String id;
  final String name;
  final String email;
  final int? age;
  final String? skinType;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.skinType,
    this.profileImageUrl,
    required this.createdAt,
    this.lastActiveAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? skinType,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      skinType: skinType ?? this.skinType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'skinType': skinType,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'],
      skinType: map['skinType'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      lastActiveAt: map['lastActiveAt'] != null
          ? DateTime.parse(map['lastActiveAt'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}

/// Provider for managing user state
class UserProvider extends ChangeNotifier {
  static const String _userKey = 'user_data';

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  /// Load user from local storage
  Future<void> loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null && userJson.isNotEmpty) {
        _currentUser = User.fromJson(userJson);
      }
    } catch (e) {
      _error = 'Failed to load user: ${e.toString()}';
      debugPrint('UserProvider.loadUser error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update or create user
  Future<void> updateUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update with lastActiveAt
      final updatedUser = user.copyWith(lastActiveAt: DateTime.now());
      
      await prefs.setString(_userKey, updatedUser.toJson());
      _currentUser = updatedUser;
    } catch (e) {
      _error = 'Failed to update user: ${e.toString()}';
      debugPrint('UserProvider.updateUser error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update specific user fields
  Future<void> updateUserFields({
    String? name,
    String? email,
    int? age,
    String? skinType,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      name: name,
      email: email,
      age: age,
      skinType: skinType,
      profileImageUrl: profileImageUrl,
    );

    await updateUser(updatedUser);
  }

  /// Logout user and clear data
  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      _currentUser = null;
    } catch (e) {
      _error = 'Failed to logout: ${e.toString()}';
      debugPrint('UserProvider.logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
