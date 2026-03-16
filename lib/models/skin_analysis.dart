import 'skin_metric.dart';

/// SkinAnalysis model for complete skin analysis results
class SkinAnalysis {
  final String id;
  final String userId;
  final DateTime analyzedAt;
  final String imageUrl;
  final int overallScore; // 0-100
  final int apparentAge;
  final int realAge;
  final List<SkinMetric> metrics;
  final Map<String, dynamic> recommendations;

  SkinAnalysis({
    required this.id,
    required this.userId,
    required this.analyzedAt,
    required this.imageUrl,
    required this.overallScore,
    required this.apparentAge,
    required this.realAge,
    required this.metrics,
    required this.recommendations,
  });

  factory SkinAnalysis.fromJson(Map<String, dynamic> json) {
    return SkinAnalysis(
      id: json['id'] as String,
      userId: json['userId'] as String,
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      imageUrl: json['imageUrl'] as String,
      overallScore: json['overallScore'] as int,
      apparentAge: json['apparentAge'] as int,
      realAge: json['realAge'] as int,
      metrics: (json['metrics'] as List<dynamic>)
          .map((m) => SkinMetric.fromJson(m as Map<String, dynamic>))
          .toList(),
      recommendations: json['recommendations'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'analyzedAt': analyzedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'overallScore': overallScore,
      'apparentAge': apparentAge,
      'realAge': realAge,
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'recommendations': recommendations,
    };
  }

  /// Returns the age difference (positive means you look younger)
  int get ageDifference => realAge - apparentAge;

  /// Returns whether the user looks younger than their real age
  bool get looksYounger => ageDifference > 0;

  /// Gets a specific metric by name
  SkinMetric? getMetric(String name) {
    try {
      return metrics.firstWhere((m) => m.name == name);
    } catch (_) {
      return null;
    }
  }

  SkinAnalysis copyWith({
    String? id,
    String? userId,
    DateTime? analyzedAt,
    String? imageUrl,
    int? overallScore,
    int? apparentAge,
    int? realAge,
    List<SkinMetric>? metrics,
    Map<String, dynamic>? recommendations,
  }) {
    return SkinAnalysis(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      overallScore: overallScore ?? this.overallScore,
      apparentAge: apparentAge ?? this.apparentAge,
      realAge: realAge ?? this.realAge,
      metrics: metrics ?? this.metrics,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  @override
  String toString() {
    return 'SkinAnalysis(id: $id, userId: $userId, overallScore: $overallScore, apparentAge: $apparentAge, realAge: $realAge, metrics: ${metrics.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkinAnalysis && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
