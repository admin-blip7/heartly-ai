import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Service for local storage operations using Hive
class StorageService {
  static const String _analysisBoxName = 'skin_analyses';
  static const String _userBoxName = 'user_data';
  static const String _settingsBoxName = 'app_settings';
  
  late Box<Map> _analysisBox;
  late Box<Map> _userBox;
  late Box<dynamic> _settingsBox;
  
  bool _initialized = false;
  
  /// Singleton instance
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  
  StorageService._internal();
  
  /// Initialize Hive and open boxes
  Future<void> init() async {
    if (_initialized) return;
    
    await Hive.initFlutter();
    
    // Open boxes
    _analysisBox = await Hive.openBox<Map>(_analysisBoxName);
    _userBox = await Hive.openBox<Map>(_userBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
    
    _initialized = true;
  }
  
  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }
  
  // ==================== SKIN ANALYSIS ====================
  
  /// Save a skin analysis to local storage
  Future<void> saveAnalysis(SkinAnalysis analysis) async {
    await _ensureInitialized();
    await _analysisBox.put(analysis.id, analysis.toJson());
  }
  
  /// Get a single analysis by ID
  Future<SkinAnalysis?> getAnalysis(String id) async {
    await _ensureInitialized();
    final json = _analysisBox.get(id);
    if (json == null) return null;
    return SkinAnalysis.fromJson(Map<String, dynamic>.from(json));
  }
  
  /// Get all stored analyses, sorted by date (newest first)
  Future<List<SkinAnalysis>> getAnalysisHistory() async {
    await _ensureInitialized();
    final analyses = _analysisBox.values
        .map((json) => SkinAnalysis.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    
    // Sort by date, newest first
    analyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return analyses;
  }
  
  /// Get recent analyses (limited count)
  Future<List<SkinAnalysis>> getRecentAnalyses({int limit = 10}) async {
    final all = await getAnalysisHistory();
    return all.take(limit).toList();
  }
  
  /// Delete an analysis
  Future<void> deleteAnalysis(String id) async {
    await _ensureInitialized();
    await _analysisBox.delete(id);
  }
  
  /// Clear all analyses
  Future<void> clearAllAnalyses() async {
    await _ensureInitialized();
    await _analysisBox.clear();
  }
  
  /// Get analysis count
  Future<int> getAnalysisCount() async {
    await _ensureInitialized();
    return _analysisBox.length;
  }
  
  // ==================== USER DATA ====================
  
  /// Save user data
  Future<void> saveUser(User user) async {
    await _ensureInitialized();
    await _userBox.put('current_user', user.toJson());
  }
  
  /// Get the current user
  Future<User?> getUser() async {
    await _ensureInitialized();
    final json = _userBox.get('current_user');
    if (json == null) return null;
    return User.fromJson(Map<String, dynamic>.from(json));
  }
  
  /// Update specific user fields
  Future<void> updateUserFields(Map<String, dynamic> fields) async {
    final user = await getUser();
    if (user == null) return;
    
    final updatedJson = user.toJson()..addAll(fields);
    await _userBox.put('current_user', updatedJson);
  }
  
  /// Delete user data (logout)
  Future<void> deleteUser() async {
    await _ensureInitialized();
    await _userBox.delete('current_user');
  }
  
  // ==================== APP SETTINGS ====================
  
  /// Save a setting
  Future<void> setSetting(String key, dynamic value) async {
    await _ensureInitialized();
    await _settingsBox.put(key, value);
  }
  
  /// Get a setting
  Future<T?> getSetting<T>(String key) async {
    await _ensureInitialized();
    return _settingsBox.get(key) as T?;
  }
  
  /// Get a setting with default value
  Future<T> getSettingOrDefault<T>(String key, T defaultValue) async {
    await _ensureInitialized();
    final value = _settingsBox.get(key);
    return value != null ? value as T : defaultValue;
  }
  
  /// Remove a setting
  Future<void> removeSetting(String key) async {
    await _ensureInitialized();
    await _settingsBox.delete(key);
  }
  
  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    return getSettingOrDefault('onboarding_complete', false);
  }
  
  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await setSetting('onboarding_complete', true);
  }
  
  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final timestamp = await getSetting<String>('last_sync_time');
    return timestamp != null ? DateTime.tryParse(timestamp) : null;
  }
  
  /// Set last sync timestamp
  Future<void> setLastSyncTime(DateTime time) async {
    await setSetting('last_sync_time', time.toIso8601String());
  }
  
  // ==================== CLEANUP ====================
  
  /// Clear all stored data
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _analysisBox.clear();
    await _userBox.clear();
    await _settingsBox.clear();
  }
  
  /// Close all boxes (call when app is closing)
  Future<void> close() async {
    await _analysisBox.close();
    await _userBox.close();
    await _settingsBox.close();
    _initialized = false;
  }
}

/// User Model
class User {
  final String id;
  final String? email;
  final String? name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic> preferences;
  
  User({
    String? id,
    this.email,
    this.name,
    this.photoUrl,
    DateTime? createdAt,
    this.lastLoginAt,
    Map<String, dynamic>? preferences,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        preferences = preferences ?? {};
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photo_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.tryParse(json['last_login_at']) 
          : null,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'photo_url': photoUrl,
    'created_at': createdAt.toIso8601String(),
    'last_login_at': lastLoginAt?.toIso8601String(),
    'preferences': preferences,
  };
  
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }
}

/// Skin Analysis Model (referenced from skin_api_service.dart)
/// This is a duplicate for storage purposes - consider creating a shared models file
class SkinAnalysis {
  final String id;
  final DateTime createdAt;
  final String imageUrl;
  final int overallScore;
  final Map<String, SkinDefect> defects;
  final List<String> recommendations;
  final String? worstCaseImageUrl;
  final String? bestCaseImageUrl;
  
  SkinAnalysis({
    String? id,
    DateTime? createdAt,
    required this.imageUrl,
    required this.overallScore,
    required this.defects,
    required this.recommendations,
    this.worstCaseImageUrl,
    this.bestCaseImageUrl,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
  
  factory SkinAnalysis.fromJson(Map<String, dynamic> json) {
    final defectsMap = <String, SkinDefect>{};
    if (json['defects'] != null && json['defects'] is Map) {
      (json['defects'] as Map).forEach((key, value) {
        defectsMap[key.toString()] = SkinDefect.fromJson(value);
      });
    }
    
    return SkinAnalysis(
      id: json['id'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      imageUrl: json['image_url'] ?? '',
      overallScore: json['overall_score'] ?? 0,
      defects: defectsMap,
      recommendations: List<String>.from(json['recommendations'] ?? []),
      worstCaseImageUrl: json['worst_case_image_url'],
      bestCaseImageUrl: json['best_case_image_url'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'image_url': imageUrl,
    'overall_score': overallScore,
    'defects': defects.map((key, value) => MapEntry(key, value.toJson())),
    'recommendations': recommendations,
    'worst_case_image_url': worstCaseImageUrl,
    'best_case_image_url': bestCaseImageUrl,
  };
}

/// Skin Defect Model
class SkinDefect {
  final String name;
  final double severity;
  final double confidence;
  final String? description;
  final String? location;
  
  SkinDefect({
    required this.name,
    required this.severity,
    required this.confidence,
    this.description,
    this.location,
  });
  
  factory SkinDefect.fromJson(Map<String, dynamic> json) {
    return SkinDefect(
      name: json['name'] ?? '',
      severity: (json['severity'] ?? 0).toDouble(),
      confidence: (json['confidence'] ?? 0).toDouble(),
      description: json['description'],
      location: json['location'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'severity': severity,
    'confidence': confidence,
    'description': description,
    'location': location,
  };
}
