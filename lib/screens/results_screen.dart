import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'challenge_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _selectedImageIndex = 0;
  final PageController _pageController = PageController();

  // Mock data
  final int _score = 68;
  final int _realAge = 20;
  final int _apparentAge = 23;
  final int _worstCaseAge = 40;
  final int _bestCaseAge = 18;
  final int _ranking = 78;

  final List<SkinMetric> _metrics = [
    SkinMetric(name: 'Hydration', score: 75, icon: Icons.water_drop),
    SkinMetric(name: 'Elasticity', score: 62, icon: Icons.auto_fix_high),
    SkinMetric(name: 'Texture', score: 70, icon: Icons.texture),
    SkinMetric(name: 'Pore Size', score: 55, icon: Icons.grain),
    SkinMetric(name: 'Wrinkles', score: 80, icon: Icons.show_chart),
    SkinMetric(name: 'Dark Spots', score: 45, icon: Icons.dark_mode),
    SkinMetric(name: 'Acne', score: 85, icon: Icons.face_retouching_natural),
    SkinMetric(name: 'Redness', score: 72, icon: Icons.opacity),
    SkinMetric(name: 'Oiliness', score: 60, icon: Icons.bubble_chart),
    SkinMetric(name: 'Sensitivity', score: 68, icon: Icons.sensors),
    SkinMetric(name: 'UV Damage', score: 58, icon: Icons.wb_sunny),
  ];

  final List<TimelineImage> _timelineImages = [
    TimelineImage(label: 'Today', subtitle: 'Current', type: ImageType.current),
    TimelineImage(label: 'Worst Case', subtitle: 'No Care', type: ImageType.worst),
    TimelineImage(label: 'Best Case', subtitle: 'Optimal', type: ImageType.best),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimelineImages(),
            const SizedBox(height: AppTheme.space4),
            _buildImageIndicators(),
            const SizedBox(height: AppTheme.space6),
            _buildScoreSection(),
            const SizedBox(height: AppTheme.space6),
            _buildAgeComparison(),
            const SizedBox(height: AppTheme.space6),
            _buildMetricsSection(),
            const SizedBox(height: AppTheme.space6),
            _buildRankingCard(),
            const SizedBox(height: AppTheme.space6),
            _buildActionButtons(),
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
        'Your Results',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Implement share
          },
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            // TODO: Implement download
          },
        ),
      ],
    );
  }

  Widget _buildTimelineImages() {
    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedImageIndex = index;
          });
        },
        itemCount: _timelineImages.length,
        itemBuilder: (context, index) {
          final image = _timelineImages[index];
          return _buildTimelineCard(image, index);
        },
      ),
    );
  }

  Widget _buildTimelineCard(TimelineImage image, int index) {
    Color borderColor;
    Color backgroundColor;
    IconData faceIcon;

    switch (image.type) {
      case ImageType.current:
        borderColor = AppTheme.primary;
        backgroundColor = AppTheme.primary.withValues(alpha: 0.1);
        faceIcon = Icons.face;
        break;
      case ImageType.worst:
        borderColor = AppTheme.scorePoor;
        backgroundColor = AppTheme.scorePoor.withValues(alpha: 0.1);
        faceIcon = Icons.sentiment_very_dissatisfied;
        break;
      case ImageType.best:
        borderColor = AppTheme.scoreExcellent;
        backgroundColor = AppTheme.scoreExcellent.withValues(alpha: 0.1);
        faceIcon = Icons.sentiment_very_satisfied;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: borderColor,
          width: _selectedImageIndex == index ? 3 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: borderColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              faceIcon,
              size: 80,
              color: borderColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            image.label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: borderColor,
                ),
          ),
          Text(
            image.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_timelineImages.length, (index) {
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            width: _selectedImageIndex == index ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _selectedImageIndex == index
                  ? AppTheme.primary
                  : AppTheme.textHint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScoreSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space6),
          child: Column(
            children: [
              Text(
                'Your Skin Score',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: AppTheme.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_score',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getScoreColor(_score),
                          fontSize: 72,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      '/100',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textHint,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.space2),
              _buildScoreLabel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreLabel() {
    String label;
    Color color;

    if (_score >= 90) {
      label = 'Excellent! 🌟';
      color = AppTheme.scoreExcellent;
    } else if (_score >= 70) {
      label = 'Good 👍';
      color = AppTheme.scoreGood;
    } else if (_score >= 50) {
      label = 'Fair 😊';
      color = AppTheme.scoreFair;
    } else {
      label = 'Needs Improvement 💪';
      color = AppTheme.scorePoor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space4,
        vertical: AppTheme.space2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildAgeComparison() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Age Analysis',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.space3),
          Row(
            children: [
              Expanded(
                child: _buildAgeCard(
                  label: 'Real Age',
                  age: _realAge,
                  color: AppTheme.textSecondary,
                  icon: Icons.cake,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: _buildAgeCard(
                  label: 'Apparent',
                  age: _apparentAge,
                  color: AppTheme.primary,
                  icon: Icons.face,
                  highlight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
          Row(
            children: [
              Expanded(
                child: _buildAgeCard(
                  label: 'Worst Case',
                  age: _worstCaseAge,
                  color: AppTheme.scorePoor,
                  icon: Icons.warning,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: _buildAgeCard(
                  label: 'Best Case',
                  age: _bestCaseAge,
                  color: AppTheme.scoreExcellent,
                  icon: Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeCard({
    required String label,
    required int age,
    required Color color,
    required IconData icon,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: highlight
            ? Border.all(color: color, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: AppTheme.space2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                '$age yrs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skin Metrics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Show detailed metrics
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
          ...List.generate(_metrics.length, (index) {
            return _buildMetricItem(_metrics[index]);
          }),
        ],
      ),
    );
  }

  Widget _buildMetricItem(SkinMetric metric) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space3),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.getScoreColor(metric.score).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              metric.icon,
              color: AppTheme.getScoreColor(metric.score),
              size: 18,
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      metric.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      '${metric.score}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.getScoreColor(metric.score),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space1),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: metric.score / 100,
                    backgroundColor: AppTheme.textHint.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.getScoreColor(metric.score),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.space5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accent.withValues(alpha: 0.2),
              AppTheme.lavender.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.space3),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: AppTheme.accent,
                size: 32,
              ),
            ),
            const SizedBox(width: AppTheme.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Ranking',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  Text(
                    'Top $_ranking%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChallengeScreen()),
                );
              },
              child: const Text('Challenge'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChallengeScreen()),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text('Challenge Friends'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Navigate to routine
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('View Your Routine'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ImageType { current, worst, best }

class TimelineImage {
  final String label;
  final String subtitle;
  final ImageType type;

  TimelineImage({
    required this.label,
    required this.subtitle,
    required this.type,
  });
}

class SkinMetric {
  final String name;
  final int score;
  final IconData icon;

  SkinMetric({
    required this.name,
    required this.score,
    required this.icon,
  });
}
