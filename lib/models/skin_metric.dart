/// Severity level for skin metrics
enum Severity {
  low,
  moderate,
  high;

  static Severity fromString(String value) {
    return Severity.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Severity.low,
    );
  }
}

/// SkinMetric model for individual skin analysis metrics
class SkinMetric {
  final String id;
  final String name; // firmness, wrinkles, spots, texture, pores, etc.
  final String displayName;
  final int score; // 0-100
  final Severity severity;
  final String recommendation;

  SkinMetric({
    required this.id,
    required this.name,
    required this.displayName,
    required this.score,
    required this.severity,
    required this.recommendation,
  });

  factory SkinMetric.fromJson(Map<String, dynamic> json) {
    return SkinMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      score: json['score'] as int,
      severity: Severity.fromString(json['severity'] as String),
      recommendation: json['recommendation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'score': score,
      'severity': severity.name,
      'recommendation': recommendation,
    };
  }

  /// Determines severity based on score
  static Severity calculateSeverity(int score) {
    if (score >= 70) return Severity.low;
    if (score >= 40) return Severity.moderate;
    return Severity.high;
  }

  SkinMetric copyWith({
    String? id,
    String? name,
    String? displayName,
    int? score,
    Severity? severity,
    String? recommendation,
  }) {
    return SkinMetric(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      score: score ?? this.score,
      severity: severity ?? this.severity,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  @override
  String toString() {
    return 'SkinMetric(id: $id, name: $name, displayName: $displayName, score: $score, severity: $severity, recommendation: $recommendation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkinMetric && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
