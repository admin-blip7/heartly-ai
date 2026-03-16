import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A badge displaying the user's ranking compared to others their age.
/// 
/// Features:
/// - Shows percentage (e.g., "Better than 85% of people your age")
/// - Trophy icon for top 20%
/// - Tap to see full ranking details
class RankingBadge extends StatelessWidget {
  /// The percentage (0-100) - represents "better than X%"
  final int percentage;
  
  /// Whether to show the trophy icon for top performers
  final bool showTrophy;
  
  /// Size variant of the badge
  final RankingBadgeSize size;
  
  /// Callback when tapped
  final VoidCallback? onTap;
  
  /// Custom label (overrides default "Better than X%...")
  final String? customLabel;

  const RankingBadge({
    super.key,
    required this.percentage,
    this.showTrophy = true,
    this.size = RankingBadgeSize.medium,
    this.onTap,
    this.customLabel,
  });

  /// Returns true if the user is in the top 20%
  bool get isTopPerformer => percentage >= 80;
  
  /// Returns the color based on ranking tier
  Color get _tierColor {
    if (percentage >= 90) return AppTheme.scoreExcellent;
    if (percentage >= 70) return AppTheme.scoreGood;
    if (percentage >= 50) return AppTheme.scoreFair;
    return AppTheme.scorePoor;
  }

  @override
  Widget build(BuildContext context) {
    final label = customLabel ?? 'Better than $percentage% of people your age';
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: Container(
          padding: _getPadding(),
          decoration: BoxDecoration(
            gradient: isTopPerformer && showTrophy
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _tierColor,
                      _tierColor.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            color: isTopPerformer && showTrophy ? null : _tierColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            border: Border.all(
              color: _tierColor.withValues(alpha: isTopPerformer ? 1 : 0.5),
              width: isTopPerformer ? 2 : 1,
            ),
            boxShadow: isTopPerformer && showTrophy
                ? [
                    BoxShadow(
                      color: _tierColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: _buildContent(context, label),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String label) {
    final isLarge = size == RankingBadgeSize.large;
    final textColor = isTopPerformer && showTrophy ? Colors.white : _tierColor;

    if (size == RankingBadgeSize.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTopPerformer && showTrophy) ...[
            Icon(
              Icons.emoji_events_rounded,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: AppTheme.space1),
          ],
          Text(
            'Top ${100 - percentage}%',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isTopPerformer && showTrophy) ...[
          Icon(
            Icons.emoji_events_rounded,
            size: isLarge ? 28 : 22,
            color: textColor,
          ),
          const SizedBox(width: AppTheme.space2),
        ] else ...[
          Icon(
            Icons.bar_chart_rounded,
            size: isLarge ? 24 : 18,
            color: textColor,
          ),
          const SizedBox(width: AppTheme.space2),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLarge) ...[
                Text(
                  'Your Ranking',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: textColor.withValues(alpha: 0.8),
                      ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                isLarge ? label : 'Top ${100 - percentage}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: isLarge ? 14 : 12,
                    ),
              ),
              if (isLarge) ...[
                const SizedBox(height: 2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ],
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: AppTheme.space2),
          Icon(
            Icons.chevron_right_rounded,
            size: isLarge ? 20 : 16,
            color: textColor.withValues(alpha: 0.7),
          ),
        ],
      ],
    );
  }

  double _getBorderRadius() {
    switch (size) {
      case RankingBadgeSize.compact:
        return AppTheme.radiusSm;
      case RankingBadgeSize.medium:
        return AppTheme.radiusMd;
      case RankingBadgeSize.large:
        return AppTheme.radiusLg;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case RankingBadgeSize.compact:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.space2,
          vertical: AppTheme.space1,
        );
      case RankingBadgeSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.space3,
          vertical: AppTheme.space2,
        );
      case RankingBadgeSize.large:
        return const EdgeInsets.all(AppTheme.space4);
    }
  }
}

/// Size variants for RankingBadge
enum RankingBadgeSize {
  compact,
  medium,
  large,
}

/// A circular ranking badge for compact displays.
class CircularRankingBadge extends StatelessWidget {
  final int percentage;
  final double size;
  final VoidCallback? onTap;

  const CircularRankingBadge({
    super.key,
    required this.percentage,
    this.size = 60,
    this.onTap,
  });

  bool get isTopPerformer => percentage >= 80;
  Color get _tierColor => AppTheme.getScoreColor(percentage);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 4,
                backgroundColor: _tierColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(_tierColor),
              ),
            ),
            // Center content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isTopPerformer)
                  Icon(
                    Icons.emoji_events_rounded,
                    size: size * 0.25,
                    color: _tierColor,
                  )
                else
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _tierColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A full ranking card with detailed information.
class RankingDetailCard extends StatelessWidget {
  final int percentage;
  final int totalUsers;
  final int userRank;
  final String? category;
  final VoidCallback? onTap;

  const RankingDetailCard({
    super.key,
    required this.percentage,
    required this.totalUsers,
    required this.userRank,
    this.category,
    this.onTap,
  });

  Color get _tierColor => AppTheme.getScoreColor(percentage);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.space2),
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _tierColor.withValues(alpha: 0.1),
            _tierColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: _tierColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircularRankingBadge(
                percentage: percentage,
                size: 70,
              ),
              const SizedBox(width: AppTheme.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category != null) ...[
                      Text(
                        category!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      'Better than $percentage%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rank #$userRank of $totalUsers',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (percentage >= 80)
                Icon(
                  Icons.emoji_events_rounded,
                  color: AppTheme.accent,
                  size: 32,
                ),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
          // Ranking bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: _tierColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(_tierColor),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(height: AppTheme.space3),
            TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.leaderboard_rounded, size: 18),
              label: const Text('View Full Leaderboard'),
              style: TextButton.styleFrom(
                foregroundColor: _tierColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
