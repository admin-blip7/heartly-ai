import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Skin analysis result model
class SkinAnalysis {
  final String id;
  final String userId;
  final int score; // 0-100 skin health score
  final String imageUrl;
  final String? thumbnailUrl;
  final Map<String, dynamic> analysisData;
  final List<String> concerns;
  final List<String> recommendations;
  final DateTime createdAt;
  final int? ageAtAnalysis;

  const SkinAnalysis({
    required this.id,
    required this.userId,
    required this.score,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.analysisData,
    this.concerns = const [],
    this.recommendations = const [],
    required this.createdAt,
    this.ageAtAnalysis,
  });

  SkinAnalysis copyWith({
    String? id,
    String? userId,
    int? score,
    String? imageUrl,
    String? thumbnailUrl,
    Map<String, dynamic>? analysisData,
    List<String>? concerns,
    List<String>? recommendations,
    DateTime? createdAt,
    int? ageAtAnalysis,
  }) {
    return SkinAnalysis(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      analysisData: analysisData ?? this.analysisData,
      concerns: concerns ?? this.concerns,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
      ageAtAnalysis: ageAtAnalysis ?? this.ageAtAnalysis,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'score': score,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'analysisData': analysisData,
      'concerns': concerns,
      'recommendations': recommendations,
      'createdAt': createdAt.toIso8601String(),
      'ageAtAnalysis': ageAtAnalysis,
    };
  }

  factory SkinAnalysis.fromMap(Map<String, dynamic> map) {
    return SkinAnalysis(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      score: map['score'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      analysisData: Map<String, dynamic>.from(map['analysisData'] ?? {}),
      concerns: List<String>.from(map['concerns'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      ageAtAnalysis: map['ageAtAnalysis'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SkinAnalysis.fromJson(String source) =>
      SkinAnalysis.fromMap(json.decode(source));
}

/// Provider for managing skin analysis state
class SkinAnalysisProvider extends ChangeNotifier {
  static const String _historyKey = 'skin_analysis_history';
  final Uuid _uuid = const Uuid();

  SkinAnalysis? _currentAnalysis;
  List<SkinAnalysis> _analysisHistory = [];
  bool _isAnalyzing = false;
  double _analysisProgress = 0.0;
  String? _error;
  String? _worstCaseImageUrl;
  String? _bestCaseImageUrl;

  // Getters
  SkinAnalysis? get currentAnalysis => _currentAnalysis;
  List<SkinAnalysis> get analysisHistory => _analysisHistory;
  bool get isAnalyzing => _isAnalyzing;
  double get analysisProgress => _analysisProgress;
  String? get error => _error;
  String? get worstCaseImageUrl => _worstCaseImageUrl;
  String? get bestCaseImageUrl => _bestCaseImageUrl;
  bool get hasHistory => _analysisHistory.isNotEmpty;

  /// Analyze skin from an image file
  Future<SkinAnalysis?> analyzeSkin(File image, {String? userId, int? age}) async {
    _isAnalyzing = true;
    _analysisProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      // Simulate analysis progress (replace with actual API call)
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        _analysisProgress = i / 100.0;
        notifyListeners();
      }

      // TODO: Replace with actual API call to skin analysis service
      // For now, create a mock analysis
      final analysis = SkinAnalysis(
        id: _uuid.v4(),
        userId: userId ?? 'anonymous',
        score: _generateMockScore(),
        imageUrl: image.path,
        thumbnailUrl: image.path,
        analysisData: {
          'hydration': 0.75,
          'elasticity': 0.82,
          'texture': 0.68,
          'pigmentation': 0.90,
        },
        concerns: ['Dryness', 'Fine lines'],
        recommendations: [
          'Use a hydrating serum daily',
          'Apply sunscreen every morning',
          'Consider retinol for fine lines',
        ],
        createdAt: DateTime.now(),
        ageAtAnalysis: age,
      );

      _currentAnalysis = analysis;
      _analysisHistory.insert(0, analysis);
      
      // Save to history
      await _saveHistory();
      
      // Generate comparison images
      await generateComparisonImages();

      return analysis;
    } catch (e) {
      _error = 'Failed to analyze skin: ${e.toString()}';
      debugPrint('SkinAnalysisProvider.analyzeSkin error: $e');
      return null;
    } finally {
      _isAnalyzing = false;
      _analysisProgress = 0.0;
      notifyListeners();
    }
  }

  /// Generate worst-case and best-case comparison images
  Future<void> generateComparisonImages() async {
    if (_currentAnalysis == null) return;

    try {
      // TODO: Replace with actual API call to generate comparison images
      // For now, these would be generated by an AI service
      _worstCaseImageUrl = null; // Would be set by API
      _bestCaseImageUrl = null; // Would be set by API
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      notifyListeners();
    } catch (e) {
      debugPrint('SkinAnalysisProvider.generateComparisonImages error: $e');
    }
  }

  /// Load analysis history from storage
  Future<void> loadHistory() async {
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey);

      if (historyJson != null) {
        _analysisHistory = historyJson
            .map((json) => SkinAnalysis.fromJson(json))
            .toList();
        
        // Sort by date, newest first
        _analysisHistory.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
      }
    } catch (e) {
      _error = 'Failed to load history: ${e.toString()}';
      debugPrint('SkinAnalysisProvider.loadHistory error: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Get ranking percentage based on score and age
  /// Returns a percentage (0-100) indicating how the user ranks
  /// compared to others in their age group
  int getRankingPercentage(int score, int age) {
    // Age-adjusted baseline scores (higher age = lower baseline)
    // These baselines represent the "average" score for each age group
    final ageBaselines = {
      18: 85,
      25: 80,
      30: 75,
      35: 70,
      40: 65,
      45: 60,
      50: 55,
      55: 50,
      60: 45,
      65: 40,
      70: 35,
    };

    // Find the appropriate baseline for the age
    int baselineScore;
    if (age <= 18) {
      baselineScore = ageBaselines[18]!;
    } else if (age >= 70) {
      baselineScore = ageBaselines[70]!;
    } else {
      // Interpolate between age brackets
      final lowerAge = (age / 5).floor() * 5;
      final upperAge = lowerAge + 5;
      final lowerBaseline = ageBaselines[lowerAge] ?? 70;
      final upperBaseline = ageBaselines[upperAge] ?? 70;
      
      final ratio = (age - lowerAge) / 5.0;
      baselineScore = (lowerBaseline * (1 - ratio) + upperBaseline * ratio).round();
    }

    // Calculate how far above/below baseline the score is
    final scoreDiff = score - baselineScore;
    
    // Convert to percentage ranking
    // If score equals baseline, ranking is 50%
    // Maximum deviation is +/- 25 points for full scale
    final maxDeviation = 25.0;
    final normalizedDiff = (scoreDiff / maxDeviation).clamp(-1.0, 1.0);
    
    // Map to 0-100 range with 50% at baseline
    final percentage = ((normalizedDiff + 1) * 50).round();
    
    return percentage.clamp(0, 100);
  }

  /// Clear current analysis
  void clearCurrentAnalysis() {
    _currentAnalysis = null;
    _worstCaseImageUrl = null;
    _bestCaseImageUrl = null;
    notifyListeners();
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      _analysisHistory = [];
      notifyListeners();
    } catch (e) {
      debugPrint('SkinAnalysisProvider.clearHistory error: $e');
    }
  }

  /// Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Save history to storage
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _analysisHistory
          .take(50) // Keep only last 50 analyses
          .map((analysis) => analysis.toJson())
          .toList();
      
      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      debugPrint('SkinAnalysisProvider._saveHistory error: $e');
    }
  }

  /// Generate a mock score for development
  int _generateMockScore() {
    // Generate a score between 45 and 95
    return 45 + (DateTime.now().millisecondsSinceEpoch % 50);
  }
}
