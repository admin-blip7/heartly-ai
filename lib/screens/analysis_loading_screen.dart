import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'results_screen.dart';

class AnalysisLoadingScreen extends StatefulWidget {
  const AnalysisLoadingScreen({super.key});

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  
  int _currentStepIndex = 0;
  double _progress = 0.0;

  final List<AnalysisStep> _steps = [
    AnalysisStep(
      icon: Icons.face_retouching_natural,
      title: 'Detecting patterns',
      description: 'Identifying skin patterns and features...',
    ),
    AnalysisStep(
      icon: Icons.analytics,
      title: 'Analyzing metrics',
      description: 'Measuring 11 key skin health indicators...',
    ),
    AnalysisStep(
      icon: Icons.auto_awesome,
      title: 'Generating predictions',
      description: 'Creating your personalized skin timeline...',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnalysis();
  }

  void _initAnimations() {
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _progressAnimation = Tween<double>(begin: 0, end: 100).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {
          _progress = _progressAnimation.value;
          _updateCurrentStep();
        });
      });

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _updateCurrentStep() {
    if (_progress < 33) {
      _currentStepIndex = 0;
    } else if (_progress < 66) {
      _currentStepIndex = 1;
    } else {
      _currentStepIndex = 2;
    }
  }

  void _startAnalysis() async {
    _progressController.forward();
    
    await Future.delayed(const Duration(seconds: 5));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultsScreen()),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.background,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space6),
            child: Column(
              children: [
                const Spacer(flex: 1),
                _buildAnimatedHeart(),
                const SizedBox(height: AppTheme.space8),
                _buildTitle(),
                const SizedBox(height: AppTheme.space4),
                _buildProgressIndicator(),
                const SizedBox(height: AppTheme.space6),
                _buildProgressPercent(),
                const SizedBox(height: AppTheme.space8),
                _buildStepsList(),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeart() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              AppTheme.primaryLight,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating ring
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * 3.14159,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                        style: BorderStyle.none,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _DashedCirclePainter(
                        color: Colors.white.withValues(alpha: 0.5),
                        strokeWidth: 2,
                        dashCount: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Heart icon
            const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 48,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Analyzing your skin...',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        color: AppTheme.textHint.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: constraints.maxWidth * (_progress / 100),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressPercent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${_progress.toInt()}',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '%',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepsList() {
    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isActive = index == _currentStepIndex;
        final isCompleted = index < _currentStepIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: AppTheme.space3),
          child: _buildStepItem(
            step: step,
            isActive: isActive,
            isCompleted: isCompleted,
          ),
        );
      }),
    );
  }

  Widget _buildStepItem({
    required AnalysisStep step,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color backgroundColor;
    Color iconColor;
    Color textColor;
    IconData iconData = step.icon;

    if (isCompleted) {
      backgroundColor = AppTheme.mint.withValues(alpha: 0.2);
      iconColor = AppTheme.mint;
      textColor = AppTheme.textPrimary;
      iconData = Icons.check_circle;
    } else if (isActive) {
      backgroundColor = AppTheme.primary.withValues(alpha: 0.1);
      iconColor = AppTheme.primary;
      textColor = AppTheme.textPrimary;
    } else {
      backgroundColor = Colors.grey.withValues(alpha: 0.1);
      iconColor = AppTheme.textHint;
      textColor = AppTheme.textHint;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: isActive
            ? Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(AppTheme.space3),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: isActive
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  )
                : Icon(
                    iconData,
                    color: iconColor,
                    size: 20,
                  ),
          ),
          const SizedBox(width: AppTheme.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                ),
                if (isActive) ...[
                  const SizedBox(height: AppTheme.space1),
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnalysisStep {
  final IconData icon;
  final String title;
  final String description;

  AnalysisStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final sweepAngle = 2 * 3.14159 / (dashCount * 2);

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * 2 * sweepAngle;
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper widget to avoid deprecated AnimatedBuilder
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}
