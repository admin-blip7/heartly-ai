import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/skin_metric.dart';
import 'score_bar.dart';

/// A metric display card that shows a skin metric with its score.
/// 
/// Features:
/// - Color-coded border based on score
/// - Tap to expand/collapse details
/// - Shows recommendation when expanded
/// - Animated expansion
class MetricCard extends StatefulWidget {
  /// The metric to display
  final SkinMetric metric;
  
  /// Whether the card starts expanded
  final bool initiallyExpanded;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;
  
  /// Custom icon for the metric (overrides metric-based icon)
  final IconData? customIcon;

  const MetricCard({
    super.key,
    required this.metric,
    this.initiallyExpanded = false,
    this.onTap,
    this.customIcon,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> {
  late bool _isExpanded;
  late IconData _metricIcon;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _metricIcon = _getIconForMetric(widget.metric.name);
  }

  IconData _getIconForMetric(String metricName) {
    if (widget.customIcon != null) return widget.customIcon!;
    
    switch (metricName.toLowerCase()) {
      case 'firmness':
      case 'elasticity':
        return Icons.fitness_center_rounded;
      case 'wrinkles':
        return Icons.grid_on_rounded;
      case 'spots':
      case 'pigmentation':
        return Icons.bubble_chart_rounded;
      case 'texture':
        return Icons.texture_rounded;
      case 'pores':
        return Icons.grain_rounded;
      case 'hydration':
      case 'moisture':
        return Icons.water_drop_rounded;
      case 'radiance':
      case 'glow':
        return Icons.wb_sunny_rounded;
      case 'dark_circles':
        return Icons.remove_red_eye_rounded;
      case 'acne':
        return Icons.warning_amber_rounded;
      case 'sensitivity':
        return Icons.healing_rounded;
      default:
        return Icons.analytics_rounded;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppTheme.getScoreColor(widget.metric.score);
    final severityText = _getSeverityText(widget.metric.severity);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.space2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: scoreColor.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.space2),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Icon(
                        _metricIcon,
                        size: 24,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.metric.displayName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            severityText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scoreColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Score circle
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scoreColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: scoreColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.metric.score}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: scoreColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space2),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                // Score bar
                const SizedBox(height: AppTheme.space3),
                ScoreBar(
                  score: widget.metric.score,
                  label: '',
                  barHeight: 8,
                  showScoreValue: false,
                ),
                
                // Expandable content
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.space4),
                      const Divider(),
                      const SizedBox(height: AppTheme.space3),
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 18,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: AppTheme.space2),
                          Text(
                            'Recommendation',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space2),
                      Text(
                        widget.metric.recommendation,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                  firstCurve: Curves.easeInOut,
                  secondCurve: Curves.easeInOut,
                  sizeCurve: Curves.easeInOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSeverityText(Severity severity) {
    switch (severity) {
      case Severity.low:
        return 'Low concern';
      case Severity.moderate:
        return 'Moderate concern';
      case Severity.high:
        return 'High concern';
    }
  }
}

/// A compact version of MetricCard for list views.
class CompactMetricCard extends StatelessWidget {
  final SkinMetric metric;
  final VoidCallback? onTap;

  const CompactMetricCard({
    super.key,
    required this.metric,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppTheme.getScoreColor(metric.score);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.space1),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space4,
              vertical: AppTheme.space3,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border(
                left: BorderSide(
                  color: scoreColor,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    metric.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space3,
                    vertical: AppTheme.space1,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    '${metric.score}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
