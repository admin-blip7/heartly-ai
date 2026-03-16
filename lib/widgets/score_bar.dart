import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A reusable score progress bar with animated width and color-coded fill.
/// 
/// The bar color changes based on the score:
/// - 90+ : Excellent (teal)
/// - 70+ : Good (green)
/// - 50+ : Fair (orange)
/// - <50 : Poor (red)
class ScoreBar extends StatefulWidget {
  /// The score value (0-100)
  final int score;
  
  /// Label text displayed above the bar
  final String label;
  
  /// Optional icon to display next to the label
  final IconData? icon;
  
  /// Height of the progress bar
  final double barHeight;
  
  /// Whether to show the score value on the right side
  final bool showScoreValue;
  
  /// Duration for the width animation
  final Duration animationDuration;
  
  /// Custom curve for the animation
  final Curve animationCurve;

  const ScoreBar({
    super.key,
    required this.score,
    required this.label,
    this.icon,
    this.barHeight = 12.0,
    this.showScoreValue = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  State<ScoreBar> createState() => _ScoreBarState();
}

class _ScoreBarState extends State<ScoreBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.animationCurve),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ScoreBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = AppTheme.getScoreColor(widget.score);
    final clampedScore = widget.score.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 18,
                color: scoreColor,
              ),
              const SizedBox(width: AppTheme.space2),
            ],
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            if (widget.showScoreValue)
              Text(
                '$clampedScore',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.space2),
        // Progress bar
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: widget.barHeight,
              decoration: BoxDecoration(
                color: AppTheme.textHint.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(widget.barHeight / 2),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        width: constraints.maxWidth * (clampedScore / 100) * _animation.value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              scoreColor,
                              scoreColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(widget.barHeight / 2),
                          boxShadow: [
                            BoxShadow(
                              color: scoreColor.withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

/// A simplified version of ScoreBar without animation for static use.
class StaticScoreBar extends StatelessWidget {
  final int score;
  final String label;
  final IconData? icon;
  final double barHeight;
  final bool showScoreValue;

  const StaticScoreBar({
    super.key,
    required this.score,
    required this.label,
    this.icon,
    this.barHeight = 12.0,
    this.showScoreValue = true,
  });

  @override
  Widget build(BuildContext context) {
    return ScoreBar(
      score: score,
      label: label,
      icon: icon,
      barHeight: barHeight,
      showScoreValue: showScoreValue,
      animationDuration: Duration.zero,
    );
  }
}
