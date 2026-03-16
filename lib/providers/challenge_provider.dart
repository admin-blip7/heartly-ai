import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Challenge model for skin improvement challenges
class Challenge {
  final String id;
  final String creatorId;
  final String creatorName;
  final String title;
  final String? description;
  final int scoreA; // Creator's initial score
  final int? scoreB; // Challenger's score
  final String? challengerId;
  final String? challengerName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime expiresAt;
  final String shareLink;
  final ChallengeStatus status;

  const Challenge({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.title,
    this.description,
    required this.scoreA,
    this.scoreB,
    this.challengerId,
    this.challengerName,
    required this.createdAt,
    this.completedAt,
    required this.expiresAt,
    required this.shareLink,
    this.status = ChallengeStatus.pending,
  });

  bool get isCompleted => status == ChallengeStatus.completed;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => status == ChallengeStatus.pending && !isExpired;
  bool get hasChallenger => challengerId != null;

  Challenge copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? title,
    String? description,
    int? scoreA,
    int? scoreB,
    String? challengerId,
    String? challengerName,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? expiresAt,
    String? shareLink,
    ChallengeStatus? status,
  }) {
    return Challenge(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      title: title ?? this.title,
      description: description ?? this.description,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      challengerId: challengerId ?? this.challengerId,
      challengerName: challengerName ?? this.challengerName,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      shareLink: shareLink ?? this.shareLink,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'title': title,
      'description': description,
      'scoreA': scoreA,
      'scoreB': scoreB,
      'challengerId': challengerId,
      'challengerName': challengerName,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'shareLink': shareLink,
      'status': status.index,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] ?? '',
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? 'Anonymous',
      title: map['title'] ?? '',
      description: map['description'],
      scoreA: map['scoreA'] ?? 0,
      scoreB: map['scoreB'],
      challengerId: map['challengerId'],
      challengerName: map['challengerName'],
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      expiresAt: DateTime.parse(map['expiresAt']),
      shareLink: map['shareLink'] ?? '',
      status: ChallengeStatus.values[map['status'] ?? 0],
    );
  }

  String toJson() => json.encode(toMap());

  factory Challenge.fromJson(String source) =>
      Challenge.fromMap(json.decode(source));
}

/// Challenge status enum
enum ChallengeStatus {
  pending,
  completed,
  expired,
}

/// Challenge result data
class ChallengeResult {
  final Challenge challenge;
  final bool isWinner;
  final int scoreDifference;
  final String winnerId;
  final String winnerName;

  const ChallengeResult({
    required this.challenge,
    required this.isWinner,
    required this.scoreDifference,
    required this.winnerId,
    required this.winnerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'challenge': challenge.toMap(),
      'isWinner': isWinner,
      'scoreDifference': scoreDifference,
      'winnerId': winnerId,
      'winnerName': winnerName,
    };
  }
}

/// Provider for managing challenge state
class ChallengeProvider extends ChangeNotifier {
  static const String _activeChallengesKey = 'active_challenges';
  static const String _completedChallengesKey = 'completed_challenges';
  final Uuid _uuid = const Uuid();

  List<Challenge> _activeChallenges = [];
  List<Challenge> _completedChallenges = [];
  bool _isLoading = false;
  String? _error;
  ChallengeResult? _lastResult;

  // Getters
  List<Challenge> get activeChallenges => 
      _activeChallenges.where((c) => c.isActive).toList();
  List<Challenge> get completedChallenges => _completedChallenges;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ChallengeResult? get lastResult => _lastResult;
  bool get hasActiveChallenges => activeChallenges.isNotEmpty;

  /// Create a new challenge and return the share link
  Future<String> createChallenge({
    required String creatorId,
    required String creatorName,
    required String title,
    String? description,
    required int scoreA,
    Duration expiration = const Duration(days: 7),
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final challengeId = _uuid.v4();
      final shareLink = 'heartly://challenge/$challengeId';

      final challenge = Challenge(
        id: challengeId,
        creatorId: creatorId,
        creatorName: creatorName,
        title: title,
        description: description,
        scoreA: scoreA,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(expiration),
        shareLink: shareLink,
        status: ChallengeStatus.pending,
      );

      _activeChallenges.insert(0, challenge);
      await _saveChallenges();

      return shareLink;
    } catch (e) {
      _error = 'Failed to create challenge: ${e.toString()}';
      debugPrint('ChallengeProvider.createChallenge error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Complete a challenge with the challenger's score
  Future<ChallengeResult?> completeChallenge(
    String challengeId, 
    int scoreB, {
    String? challengerId,
    String? challengerName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final challengeIndex = _activeChallenges.indexWhere(
        (c) => c.id == challengeId,
      );

      if (challengeIndex == -1) {
        _error = 'Challenge not found';
        return null;
      }

      final challenge = _activeChallenges[challengeIndex];

      if (!challenge.isActive) {
        _error = 'Challenge is no longer active';
        return null;
      }

      // Update challenge with challenger's score
      final completedChallenge = challenge.copyWith(
        scoreB: scoreB,
        challengerId: challengerId,
        challengerName: challengerName ?? 'Anonymous',
        completedAt: DateTime.now(),
        status: ChallengeStatus.completed,
      );

      // Move from active to completed
      _activeChallenges.removeAt(challengeIndex);
      _completedChallenges.insert(0, completedChallenge);

      // Calculate result
      final isCreatorWin = completedChallenge.scoreA >= scoreB;
      final scoreDiff = (completedChallenge.scoreA - scoreB).abs();

      final result = ChallengeResult(
        challenge: completedChallenge,
        isWinner: isCreatorWin
            ? completedChallenge.creatorId == challengerId
            : completedChallenge.creatorId != challengerId,
        scoreDifference: scoreDiff,
        winnerId: isCreatorWin ? completedChallenge.creatorId : challengerId ?? '',
        winnerName: isCreatorWin
            ? completedChallenge.creatorName
            : challengerName ?? 'Anonymous',
      );

      _lastResult = result;
      await _saveChallenges();

      return result;
    } catch (e) {
      _error = 'Failed to complete challenge: ${e.toString()}';
      debugPrint('ChallengeProvider.completeChallenge error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get challenge result as a map
  Map<String, dynamic>? getChallengeResult() {
    if (_lastResult == null) return null;
    return _lastResult!.toMap();
  }

  /// Get challenge by ID
  Challenge? getChallengeById(String challengeId) {
    try {
      return _activeChallenges.firstWhere((c) => c.id == challengeId);
    } catch (_) {
      try {
        return _completedChallenges.firstWhere((c) => c.id == challengeId);
      } catch (_) {
        return null;
      }
    }
  }

  /// Get challenge by share link
  Challenge? getChallengeByShareLink(String shareLink) {
    try {
      return _activeChallenges.firstWhere((c) => c.shareLink == shareLink);
    } catch (_) {
      return null;
    }
  }

  /// Load challenges from storage
  Future<void> loadChallenges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load active challenges
      final activeJson = prefs.getStringList(_activeChallengesKey);
      if (activeJson != null) {
        _activeChallenges = activeJson
            .map((json) => Challenge.fromJson(json))
            .toList();
      }

      // Load completed challenges
      final completedJson = prefs.getStringList(_completedChallengesKey);
      if (completedJson != null) {
        _completedChallenges = completedJson
            .map((json) => Challenge.fromJson(json))
            .toList();
      }

      // Check for expired challenges
      _checkExpiredChallenges();
    } catch (e) {
      _error = 'Failed to load challenges: ${e.toString()}';
      debugPrint('ChallengeProvider.loadChallenges error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a challenge
  Future<void> deleteChallenge(String challengeId) async {
    try {
      _activeChallenges.removeWhere((c) => c.id == challengeId);
      _completedChallenges.removeWhere((c) => c.id == challengeId);
      await _saveChallenges();
      notifyListeners();
    } catch (e) {
      debugPrint('ChallengeProvider.deleteChallenge error: $e');
    }
  }

  /// Clear all challenges
  Future<void> clearAllChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeChallengesKey);
      await prefs.remove(_completedChallengesKey);
      _activeChallenges = [];
      _completedChallenges = [];
      notifyListeners();
    } catch (e) {
      debugPrint('ChallengeProvider.clearAllChallenges error: $e');
    }
  }

  /// Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear last result
  void clearLastResult() {
    _lastResult = null;
    notifyListeners();
  }

  /// Save challenges to storage
  Future<void> _saveChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save active challenges (limit to 50)
      final activeJson = _activeChallenges
          .take(50)
          .map((c) => c.toJson())
          .toList();
      await prefs.setStringList(_activeChallengesKey, activeJson);

      // Save completed challenges (limit to 100)
      final completedJson = _completedChallenges
          .take(100)
          .map((c) => c.toJson())
          .toList();
      await prefs.setStringList(_completedChallengesKey, completedJson);
    } catch (e) {
      debugPrint('ChallengeProvider._saveChallenges error: $e');
    }
  }

  /// Check and move expired challenges
  void _checkExpiredChallenges() {
    final now = DateTime.now();
    final expiredChallenges = <Challenge>[];

    _activeChallenges = _activeChallenges.where((challenge) {
      if (challenge.isExpired && !challenge.isCompleted) {
        expiredChallenges.add(challenge.copyWith(
          status: ChallengeStatus.expired,
        ));
        return false;
      }
      return true;
    }).toList();

    if (expiredChallenges.isNotEmpty) {
      _completedChallenges.addAll(expiredChallenges);
      _completedChallenges.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
    }
  }
}
