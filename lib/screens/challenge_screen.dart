import 'package:flutter/material.dart';
import '../config/theme.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final String _shareLink = 'https://heartly.ai/challenge/abc123';
  bool _linkCopied = false;
  
  // Mock challenge data
  final ChallengeResult _myResult = ChallengeResult(
    name: 'You',
    score: 72,
    apparentAge: 23,
    ranking: 78,
  );
  
  final ChallengeResult _friendResult = ChallengeResult(
    name: 'Alex',
    score: 68,
    apparentAge: 25,
    ranking: 72,
  );

  bool get _iWon => _myResult.score > _friendResult.score;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppTheme.space6),
            _buildShareSection(),
            const SizedBox(height: AppTheme.space6),
            _buildSocialButtons(),
            const SizedBox(height: AppTheme.space8),
            _buildComparisonTitle(),
            const SizedBox(height: AppTheme.space4),
            _buildComparisonCards(),
            const SizedBox(height: AppTheme.space6),
            _buildWinnerAnnouncement(),
            const SizedBox(height: AppTheme.space8),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Challenge Friends',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            _showInfoDialog();
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.secondary,
                AppTheme.secondaryLight,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        Text(
          'Challenge Your Friends!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.space2),
        Text(
          'Share your results and see who has better skin health',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildShareSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Link',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.space3),
            Container(
              padding: const EdgeInsets.all(AppTheme.space3),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.textHint.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _shareLink,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space2),
                  InkWell(
                    onTap: _copyLink,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.space2),
                      decoration: BoxDecoration(
                        color: _linkCopied
                            ? AppTheme.scoreGood.withValues(alpha: 0.1)
                            : AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Icon(
                        _linkCopied ? Icons.check : Icons.copy,
                        color: _linkCopied
                            ? AppTheme.scoreGood
                            : AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyLink() {
    // In real app, use clipboard package
    setState(() {
      _linkCopied = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard!'),
        backgroundColor: AppTheme.scoreGood,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Reset after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _linkCopied = false;
        });
      }
    });
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: Icons.chat,
            label: 'WhatsApp',
            color: const Color(0xFF25D366),
            onTap: () {
              _shareToWhatsApp();
            },
          ),
        ),
        const SizedBox(width: AppTheme.space3),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.camera_alt,
            label: 'Instagram',
            color: const Color(0xFFE1306C),
            onTap: () {
              _shareToInstagram();
            },
          ),
        ),
        const SizedBox(width: AppTheme.space3),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.share,
            label: 'More',
            color: AppTheme.textSecondary,
            onTap: () {
              _showShareSheet();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppTheme.space2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTitle() {
    return Text(
      'Challenge Result',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildComparisonCards() {
    return Row(
      children: [
        Expanded(
          child: _buildPlayerCard(
            result: _myResult,
            isWinner: _iWon,
            isMe: true,
          ),
        ),
        const SizedBox(width: AppTheme.space3),
        _buildVSBadge(),
        const SizedBox(width: AppTheme.space3),
        Expanded(
          child: _buildPlayerCard(
            result: _friendResult,
            isWinner: !_iWon,
            isMe: false,
          ),
        ),
      ],
    );
  }

  Widget _buildVSBadge() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.textHint.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.textHint.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Text(
          'VS',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard({
    required ChallengeResult result,
    required bool isWinner,
    required bool isMe,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        gradient: isWinner
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.scoreExcellent.withValues(alpha: 0.1),
                  AppTheme.primaryLight.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isWinner ? null : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isWinner
              ? AppTheme.scoreExcellent.withValues(alpha: 0.5)
              : AppTheme.textHint.withValues(alpha: 0.2),
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMe
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : AppTheme.lavender.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    result.name[0],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isMe ? AppTheme.primary : AppTheme.lavender,
                        ),
                  ),
                ),
              ),
              if (isWinner)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            result.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.space4),
          _buildStatRow('Score', '${result.score}', AppTheme.getScoreColor(result.score)),
          const SizedBox(height: AppTheme.space2),
          _buildStatRow('Age', '${result.apparentAge} yrs', AppTheme.textSecondary),
          const SizedBox(height: AppTheme.space2),
          _buildStatRow('Rank', 'Top ${result.ranking}%', AppTheme.accent),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }

  Widget _buildWinnerAnnouncement() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.space5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _iWon ? AppTheme.scoreExcellent : AppTheme.secondary,
            _iWon ? AppTheme.primaryLight : AppTheme.secondaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          Icon(
            _iWon ? Icons.celebration : Icons.sentiment_satisfied,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            _iWon ? 'You Won! 🎉' : 'Better luck next time!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            _iWon
                ? 'Your skin health score is higher than ${_friendResult.name}\'s!'
                : '${_friendResult.name} has a slightly higher score. Keep improving!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How Challenges Work'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Share your unique link with friends'),
            SizedBox(height: 8),
            Text('2. They take the skin analysis'),
            SizedBox(height: 8),
            Text('3. Compare scores and see who wins!'),
            SizedBox(height: 16),
            Text(
              'Note: Challenges are friendly competitions to encourage better skin care habits.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _shareToWhatsApp() {
    // TODO: Implement WhatsApp sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening WhatsApp...'),
        backgroundColor: Color(0xFF25D366),
      ),
    );
  }

  void _shareToInstagram() {
    // TODO: Implement Instagram sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Instagram...'),
        backgroundColor: Color(0xFFE1306C),
      ),
    );
  }

  void _showShareSheet() {
    // TODO: Implement native share sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening share sheet...'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }
}

class ChallengeResult {
  final String name;
  final int score;
  final int apparentAge;
  final int ranking;

  ChallengeResult({
    required this.name,
    required this.score,
    required this.apparentAge,
    required this.ranking,
  });
}
