/// Challenge model for friend skin analysis challenges
class Challenge {
  final String id;
  final String userAId;
  final String userBId;
  final int scoreA;
  final int scoreB;
  final String? winner; // null if tie or pending
  final DateTime createdAt;

  Challenge({
    required this.id,
    required this.userAId,
    required this.userBId,
    required this.scoreA,
    required this.scoreB,
    this.winner,
    required this.createdAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      userAId: json['userAId'] as String,
      userBId: json['userBId'] as String,
      scoreA: json['scoreA'] as int,
      scoreB: json['scoreB'] as int,
      winner: json['winner'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userAId': userAId,
      'userBId': userBId,
      'scoreA': scoreA,
      'scoreB': scoreB,
      'winner': winner,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Determines the winner based on scores (higher score wins)
  String? determineWinner() {
    if (scoreA > scoreB) return userAId;
    if (scoreB > scoreA) return userBId;
    return null; // Tie
  }

  /// Returns whether the challenge is a tie
  bool get isTie => scoreA == scoreB;

  /// Returns whether the challenge has a winner
  bool get hasWinner => winner != null;

  /// Gets the score for a specific user
  int? getScoreForUser(String userId) {
    if (userId == userAId) return scoreA;
    if (userId == userBId) return scoreB;
    return null;
  }

  /// Checks if a user is part of this challenge
  bool hasParticipant(String userId) {
    return userId == userAId || userId == userBId;
  }

  /// Gets the opponent's ID for a given user
  String? getOpponentId(String userId) {
    if (userId == userAId) return userBId;
    if (userId == userBId) return userAId;
    return null;
  }

  Challenge copyWith({
    String? id,
    String? userAId,
    String? userBId,
    int? scoreA,
    int? scoreB,
    String? winner,
    DateTime? createdAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      userAId: userAId ?? this.userAId,
      userBId: userBId ?? this.userBId,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      winner: winner ?? this.winner,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Challenge(id: $id, userAId: $userAId, userBId: $userBId, scoreA: $scoreA, scoreB: $scoreB, winner: $winner, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Challenge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
