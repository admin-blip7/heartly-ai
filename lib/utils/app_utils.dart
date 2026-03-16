import 'package:flutter/material.dart';
import '../config/theme.dart';

class AppUtils {
  // Score color helper
  static Color getScoreColor(int score) {
    return AppTheme.getScoreColor(score);
  }
  
  // Score text helper
  static String getScoreText(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs Improvement';
  }
  
  // Age exaggeration calculator
  static Map<String, int> calculateExaggeratedAges(int realAge, int skinScore) {
    int apparentAge;
    
    if (skinScore >= 80) {
      apparentAge = realAge - 2;
    } else if (skinScore >= 60) {
      apparentAge = realAge + 1;
    } else if (skinScore >= 40) {
      apparentAge = realAge + 3;
    } else {
      apparentAge = realAge + 5;
    }
    
    // Worst case: exageración para urgencia
    int worstCaseAge = realAge + (realAge - apparentAge).abs() * 2 + 10;
    
    // Best case: optimismo realista
    int bestCaseAge = realAge - 2;
    
    return {
      'realAge': realAge,
      'apparentAge': apparentAge,
      'worstCaseAge': worstCaseAge + 5, // +5 years in future
      'bestCaseAge': bestCaseAge + 5,  // +5 years in future
    };
  }
  
  // Ranking calculator
  static int calculateRankingPercentage(int userScore, int userAge) {
    // Placeholder: in real app, query database
    // For now, use simple formula
    if (userScore >= 90) return 95;
    if (userScore >= 80) return 85;
    if (userScore >= 70) return 70;
    if (userScore >= 60) return 55;
    if (userScore >= 50) return 40;
    return 25;
  }
  
  // Format date
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  // Format time ago
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
  
  // Generate share text
  static String generateShareText(int score, int apparentAge, int realAge) {
    final ageDiff = apparentAge - realAge;
    final ageText = ageDiff > 0 
      ? 'I look $ageDiff years older than I am!'
      : ageDiff < 0 
        ? 'I look ${ageDiff.abs()} years younger than I am!'
        : 'I look my actual age!';
    
    return 'My skin score is $score/100 on Heartly AI! $ageText What\'s your score? 📱';
  }
  
  // Generate challenge text
  static String generateChallengeText(int score, int apparentAge, int realAge) {
    return 'I scored $score/100 and look $apparentAge years (I\'m $realAge). Can you beat me? 😏 Challenge me on Heartly AI!';
  }
}
