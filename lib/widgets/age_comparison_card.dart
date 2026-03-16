import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A card that displays age comparison with visual indicators.
/// 
/// Shows:
/// - Real age vs apparent age
/// - Worst case age (if you don't care)
/// - Best case age (if you care)
/// - Visual arrows and color coding
class AgeComparisonCard extends StatelessWidget {
  /// User's real age
  final int realAge;
  
  /// Age the user appears based on skin analysis
  final int apparentAge;
  
  /// Worst case age projection
  final int worstCaseAge;
  
  /// Best case age projection
  final int bestCaseAge;
  
  /// Whether to show the projections section
  final bool showProjections;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;

  const AgeComparisonCard({
    super.key,
    required this.realAge,
    required this.apparentAge,
    required this.worstCaseAge,
    required this.bestCaseAge,
    this.showProjections = true,
    this.onTap,
  });

  /// Returns the age difference (positive means looking younger)
  int get ageDifference => realAge - apparentAge;
  
  /// Returns whether user looks younger than their real age
  bool get looksYounger => ageDifference > 0;
  
  /// Returns whether user looks their exact age
  bool get looksSame => ageDifference == 0;

  Color get _comparisonColor {
    if (looksSame) return AppTheme.scoreFair;
    return looksYounger ? AppTheme.scoreExcellent : AppTheme.scorePoor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.space2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).cardColor,
            Theme.of(context).cardColor.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space5),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cake_rounded,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.space2),
                    Text(
                      'Age Analysis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space5),
                
                // Main age comparison
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Real Age
                    _AgeColumn(
                      label: 'Your Age',
                      age: realAge,
                      color: AppTheme.textSecondary,
                      icon: Icons.person_rounded,
                    ),
                    
                    // Arrow with difference
                    Column(
                      children: [
                        Icon(
                          looksSame
                              ? Icons.arrow_forward_rounded
                              : looksYounger
                                  ? Icons.arrow_back_rounded
                                  : Icons.arrow_forward_rounded,
                          color: _comparisonColor,
                          size: 32,
                        ),
                        const SizedBox(height: AppTheme.space1),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.space2,
                            vertical: AppTheme.space1,
                          ),
                          decoration: BoxDecoration(
                            color: _comparisonColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Text(
                            looksSame
                                ? 'Same'
                                : looksYounger
                                    ? '-$ageDifference yrs'
                                    : '+${ageDifference.abs()} yrs',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: _comparisonColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Apparent Age
                    _AgeColumn(
                      label: 'You Look',
                      age: apparentAge,
                      color: _comparisonColor,
                      icon: looksSame
                          ? Icons.face_rounded
                          : looksYounger
                              ? Icons.sentiment_very_satisfied_rounded
                              : Icons.sentiment_dissatisfied_rounded,
                      highlight: true,
                    ),
                  ],
                ),
                
                // Projections section
                if (showProjections) ...[
                  const SizedBox(height: AppTheme.space5),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timeline_rounded,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: AppTheme.space2),
                            Text(
                              'Future Projection',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.space4),
                        Row(
                          children: [
                            // Worst case
                            Expanded(
                              child: _ProjectionCard(
                                label: "If you don't care",
                                age: worstCaseAge,
                                color: AppTheme.scorePoor,
                                icon: Icons.trending_up_rounded,
                              ),
                            ),
                            const SizedBox(width: AppTheme.space3),
                            // Best case
                            Expanded(
                              child: _ProjectionCard(
                                label: "If you care",
                                age: bestCaseAge,
                                color: AppTheme.scoreExcellent,
                                icon: Icons.trending_down_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Message
                const SizedBox(height: AppTheme.space4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space4,
                    vertical: AppTheme.space2,
                  ),
                  decoration: BoxDecoration(
                    color: _comparisonColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        looksSame
                            ? Icons.info_outline_rounded
                            : looksYounger
                                ? Icons.celebration_rounded
                                : Icons.tips_and_updates_rounded,
                        size: 18,
                        color: _comparisonColor,
                      ),
                      const SizedBox(width: AppTheme.space2),
                      Flexible(
                        child: Text(
                          _getMessage(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _comparisonColor,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMessage() {
    if (looksSame) {
      return 'Your skin matches your age. Keep maintaining!';
    } else if (looksYounger) {
      if (ageDifference >= 5) {
        return 'Amazing! You look significantly younger!';
      }
      return 'Great! You look younger than your age!';
    } else {
      if (ageDifference.abs() >= 5) {
        return "There's room for improvement. Start caring today!";
      }
      return 'Small changes can make a big difference!';
    }
  }
}

class _AgeColumn extends StatelessWidget {
  final String label;
  final int age;
  final Color color;
  final IconData icon;
  final bool highlight;

  const _AgeColumn({
    required this.label,
    required this.age,
    required this.color,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: highlight ? 80 : 70,
          height: highlight ? 80 : 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(
              color: color,
              width: highlight ? 3 : 2,
            ),
            boxShadow: highlight
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: highlight ? 22 : 18,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(
                '$age',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: highlight ? 24 : 20,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _ProjectionCard extends StatelessWidget {
  final String label;
  final int age;
  final Color color;
  final IconData icon;

  const _ProjectionCard({
    required this.label,
    required this.age,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: AppTheme.space1),
          Text(
            '$age',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
