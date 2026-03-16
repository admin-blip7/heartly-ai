import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A side-by-side comparison widget for challenge results.
/// 
/// Features:
/// - Two user photos with scores and apparent ages
/// - Winner highlight with visual effects
/// - Share button for social sharing
class ChallengeComparison extends StatelessWidget {
  /// First user's data
  final ChallengeUser user1;
  
  /// Second user's data
  final ChallengeUser user2;
  
  /// Callback when share button is pressed
  final VoidCallback? onShare;
  
  /// Callback when a user card is tapped
  final void Function(ChallengeUser user)? onUserTap;
  
  /// Whether to show the share button
  final bool showShareButton;
  
  /// Custom label for the comparison
  final String? titleLabel;

  const ChallengeComparison({
    super.key,
    required this.user1,
    required this.user2,
    this.onShare,
    this.onUserTap,
    this.showShareButton = true,
    this.titleLabel,
  });

  /// Determines the winner based on score
  ChallengeUser? get winner {
    if (user1.score > user2.score) return user1;
    if (user2.score > user1.score) return user2;
    return null; // Tie
  }

  bool _isWinner(ChallengeUser user) => winner?.id == user.id;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.space2),
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          if (titleLabel != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.compare_arrows_rounded,
                  size: 20,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: AppTheme.space2),
                Text(
                  titleLabel!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space4),
          ],
          
          // VS Label
          if (titleLabel == null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space4,
                vertical: AppTheme.space2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_alt_rounded,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: AppTheme.space2),
                  Text(
                    'Skin Challenge',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.space4),
          ],
          
          // User comparison row
          Row(
            children: [
              // User 1
              Expanded(
                child: _UserCard(
                  user: user1,
                  isWinner: _isWinner(user1),
                  onTap: onUserTap != null ? () => onUserTap!(user1) : null,
                ),
              ),
              
              // VS divider
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.space2),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                          color: AppTheme.textHint.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'VS',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // User 2
              Expanded(
                child: _UserCard(
                  user: user2,
                  isWinner: _isWinner(user2),
                  onTap: onUserTap != null ? () => onUserTap!(user2) : null,
                ),
              ),
            ],
          ),
          
          // Winner announcement
          if (winner != null) ...[
            const SizedBox(height: AppTheme.space4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space4,
                vertical: AppTheme.space3,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accent.withValues(alpha: 0.2),
                    AppTheme.primary.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: AppTheme.accent,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.space2),
                  Text(
                    '${winner!.name} wins!',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: AppTheme.space4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space4,
                vertical: AppTheme.space2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.scoreFair.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.handshake_rounded,
                    color: AppTheme.scoreFair,
                    size: 18,
                  ),
                  const SizedBox(width: AppTheme.space2),
                  Text(
                    "It's a tie!",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.scoreFair,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
          
          // Share button
          if (showShareButton) ...[
            const SizedBox(height: AppTheme.space4),
            OutlinedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share Results'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space6,
                  vertical: AppTheme.space3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Data model for a challenge user
class ChallengeUser {
  final String id;
  final String name;
  final String photoUrl;
  final int score;
  final int apparentAge;

  const ChallengeUser({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.score,
    required this.apparentAge,
  });
}

class _UserCard extends StatelessWidget {
  final ChallengeUser user;
  final bool isWinner;
  final VoidCallback? onTap;

  const _UserCard({
    required this.user,
    required this.isWinner,
    this.onTap,
  });

  Color get _scoreColor => AppTheme.getScoreColor(user.score);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppTheme.space3),
        decoration: BoxDecoration(
          gradient: isWinner
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _scoreColor.withValues(alpha: 0.15),
                    _scoreColor.withValues(alpha: 0.05),
                  ],
                )
              : null,
          color: isWinner ? null : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isWinner
                ? _scoreColor.withValues(alpha: 0.8)
                : AppTheme.textHint.withValues(alpha: 0.2),
            width: isWinner ? 2 : 1,
          ),
          boxShadow: isWinner
              ? [
                  BoxShadow(
                    color: _scoreColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Winner crown
            if (isWinner) ...[
              Icon(
                Icons.emoji_events_rounded,
                color: AppTheme.accent,
                size: 24,
              ),
              const SizedBox(height: AppTheme.space1),
            ],
            
            // Photo
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _scoreColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _scoreColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  user.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.textHint.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person_rounded,
                        size: 32,
                        color: AppTheme.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppTheme.space2),
            
            // Name
            Text(
              user.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space2),
            
            // Score
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space3,
                vertical: AppTheme.space1,
              ),
              decoration: BoxDecoration(
                color: _scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: _scoreColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${user.score}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.space1),
            
            // Apparent age
            Text(
              'Looks ${user.apparentAge}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact version of ChallengeComparison for list views.
class CompactChallengeComparison extends StatelessWidget {
  final ChallengeUser user1;
  final ChallengeUser user2;
  final VoidCallback? onTap;

  const CompactChallengeComparison({
    super.key,
    required this.user1,
    required this.user2,
    this.onTap,
  });

  ChallengeUser? get winner {
    if (user1.score > user2.score) return user1;
    if (user2.score > user1.score) return user2;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppTheme.space1),
        padding: const EdgeInsets.all(AppTheme.space3),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: [
            // User 1 avatar
            _CompactUserAvatar(
              user: user1,
              isWinner: winner?.id == user1.id,
            ),
            const SizedBox(width: AppTheme.space2),
            Expanded(
              child: Text(
                user1.name,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // VS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space2),
              child: Text(
                'vs',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textHint,
                    ),
              ),
            ),
            
            Expanded(
              child: Text(
                user2.name,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppTheme.space2),
            
            // User 2 avatar
            _CompactUserAvatar(
              user: user2,
              isWinner: winner?.id == user2.id,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactUserAvatar extends StatelessWidget {
  final ChallengeUser user;
  final bool isWinner;

  const _CompactUserAvatar({
    required this.user,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppTheme.getScoreColor(user.score);
    
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isWinner ? scoreColor : AppTheme.textHint.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              user.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.textHint.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
        if (isWinner)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
