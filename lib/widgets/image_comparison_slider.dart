import 'package:flutter/material.dart';
import '../config/theme.dart';

/// An interactive image comparison slider widget.
/// 
/// Features:
/// - Shows worst case image on the left
/// - Shows best case image on the right
/// - Draggable slider in the middle
/// - Labels for each side
class ImageComparisonSlider extends StatefulWidget {
  /// URL or path for the worst case image (left side)
  final String worstCaseImage;
  
  /// URL or path for the best case image (right side)
  final String bestCaseImage;
  
  /// Label for the worst case side
  final String worstCaseLabel;
  
  /// Label for the best case side
  final String bestCaseLabel;
  
  /// Height of the comparison widget
  final double height;
  
  /// Initial slider position (0.0 to 1.0, where 0.5 is center)
  final double initialPosition;
  
  /// Color of the slider handle
  final Color sliderColor;
  
  /// Width of the slider line
  final double sliderWidth;

  const ImageComparisonSlider({
    super.key,
    required this.worstCaseImage,
    required this.bestCaseImage,
    this.worstCaseLabel = "If you don't care",
    this.bestCaseLabel = "If you care",
    this.height = 300,
    this.initialPosition = 0.5,
    this.sliderColor = Colors.white,
    this.sliderWidth = 3,
  });

  @override
  State<ImageComparisonSlider> createState() => _ImageComparisonSliderState();
}

class _ImageComparisonSliderState extends State<ImageComparisonSlider> {
  late double _sliderPosition;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _sliderPosition = widget.initialPosition.clamp(0.0, 1.0);
  }

  void _updatePosition(Offset localX, double width) {
    setState(() {
      _sliderPosition = (localX.dx / width).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.space2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            
            return Stack(
              children: [
                // Bottom layer: Worst case (full width)
                Positioned.fill(
                  child: _buildImage(widget.worstCaseImage),
                ),
                
                // Top layer: Best case (clipped)
                Positioned.fill(
                  child: ClipPath(
                    clipper: _RightSideClipper(_sliderPosition),
                    child: _buildImage(widget.bestCaseImage),
                  ),
                ),
                
                // Slider handle
                Positioned(
                  left: width * _sliderPosition - 24,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onHorizontalDragStart: (_) => setState(() => _isDragging = true),
                    onHorizontalDragUpdate: (details) {
                      _updatePosition(
                        Offset(details.localPosition.dx + width * _sliderPosition - 24, 0),
                        width,
                      );
                    },
                    onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
                    child: _SliderHandle(
                      isDragging: _isDragging,
                      color: widget.sliderColor,
                    ),
                  ),
                ),
                
                // Touch area for entire widget
                Positioned.fill(
                  child: GestureDetector(
                    onHorizontalDragStart: (_) => setState(() => _isDragging = true),
                    onHorizontalDragUpdate: (details) {
                      _updatePosition(details.localPosition, width);
                    },
                    onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
                    onTapDown: (details) {
                      _updatePosition(details.localPosition, width);
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                
                // Labels
                Positioned(
                  left: AppTheme.space3,
                  bottom: AppTheme.space3,
                  child: _ImageLabel(
                    label: widget.worstCaseLabel,
                    backgroundColor: AppTheme.scorePoor,
                  ),
                ),
                Positioned(
                  right: AppTheme.space3,
                  bottom: AppTheme.space3,
                  child: _ImageLabel(
                    label: widget.bestCaseLabel,
                    backgroundColor: AppTheme.scoreExcellent,
                  ),
                ),
                
                // Slider line
                Positioned(
                  left: width * _sliderPosition - widget.sliderWidth / 2,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: widget.sliderWidth,
                    color: widget.sliderColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage(String source) {
    final image = source.startsWith('http')
        ? Image.network(
            source,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          )
        : Image.asset(
            source,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
    
    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.textHint.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 48,
          color: AppTheme.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _RightSideClipper extends CustomClipper<Path> {
  final double position;

  _RightSideClipper(this.position);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * position, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * position, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_RightSideClipper oldClipper) {
    return oldClipper.position != position;
  }
}

class _SliderHandle extends StatelessWidget {
  final bool isDragging;
  final Color color;

  const _SliderHandle({
    required this.isDragging,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: isDragging ? 52 : 48,
        height: isDragging ? 52 : 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.unfold_more_rounded,
              size: 20,
              color: Colors.grey[700],
            ),
            Icon(
              Icons.unfold_less_rounded,
              size: 20,
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageLabel extends StatelessWidget {
  final String label;
  final Color backgroundColor;

  const _ImageLabel({
    required this.label,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space3,
        vertical: AppTheme.space2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            backgroundColor == AppTheme.scoreExcellent
                ? Icons.check_circle_rounded
                : Icons.warning_rounded,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: AppTheme.space1),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// A simpler before/after image comparison without interaction.
class StaticImageComparison extends StatelessWidget {
  final String beforeImage;
  final String afterImage;
  final String beforeLabel;
  final String afterLabel;
  final double height;

  const StaticImageComparison({
    super.key,
    required this.beforeImage,
    required this.afterImage,
    this.beforeLabel = 'Before',
    this.afterLabel = 'After',
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.space2),
      child: Row(
        children: [
          // Before
          Expanded(
            child: _StaticImageCard(
              image: beforeImage,
              label: beforeLabel,
              color: AppTheme.scoreFair,
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          // Arrow
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          // After
          Expanded(
            child: _StaticImageCard(
              image: afterImage,
              label: afterLabel,
              color: AppTheme.scoreExcellent,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticImageCard extends StatelessWidget {
  final String image;
  final String label;
  final Color color;

  const _StaticImageCard({
    required this.image,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd - 2),
            child: image.startsWith('http')
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : Image.asset(
                    image,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  ),
          ),
        ),
        Positioned(
          bottom: AppTheme.space2,
          left: AppTheme.space2,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space2,
              vertical: AppTheme.space1,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.textHint.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          Icons.image_rounded,
          color: AppTheme.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// A vertical image comparison slider (top to bottom).
class VerticalImageComparisonSlider extends StatefulWidget {
  final String topImage;
  final String bottomImage;
  final String topLabel;
  final String bottomLabel;
  final double height;
  final double initialPosition;

  const VerticalImageComparisonSlider({
    super.key,
    required this.topImage,
    required this.bottomImage,
    this.topLabel = 'Before',
    this.bottomLabel = 'After',
    this.height = 400,
    this.initialPosition = 0.5,
  });

  @override
  State<VerticalImageComparisonSlider> createState() => _VerticalImageComparisonSliderState();
}

class _VerticalImageComparisonSliderState extends State<VerticalImageComparisonSlider> {
  late double _sliderPosition;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _sliderPosition = widget.initialPosition.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: AppTheme.space2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            
            return Stack(
              children: [
                // Top layer (full)
                Positioned.fill(
                  child: _buildImage(widget.topImage),
                ),
                
                // Bottom layer (clipped from top)
                Positioned.fill(
                  child: ClipPath(
                    clipper: _BottomClipper(_sliderPosition),
                    child: _buildImage(widget.bottomImage),
                  ),
                ),
                
                // Horizontal slider line
                Positioned(
                  left: 0,
                  right: 0,
                  top: height * _sliderPosition - 1.5,
                  child: Container(
                    height: 3,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                
                // Slider handle
                Positioned(
                  left: 0,
                  right: 0,
                  top: height * _sliderPosition - 24,
                  child: Center(
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          _sliderPosition = (details.localPosition.dy / height).clamp(0.0, 1.0);
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.swap_vert_rounded,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Labels
                Positioned(
                  top: AppTheme.space3,
                  left: AppTheme.space3,
                  child: _ImageLabel(
                    label: widget.topLabel,
                    backgroundColor: AppTheme.scoreFair,
                  ),
                ),
                Positioned(
                  bottom: AppTheme.space3,
                  left: AppTheme.space3,
                  child: _ImageLabel(
                    label: widget.bottomLabel,
                    backgroundColor: AppTheme.scoreExcellent,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage(String source) {
    return source.startsWith('http')
        ? Image.network(
            source,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          )
        : Image.asset(
            source,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.textHint.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 48,
          color: AppTheme.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _BottomClipper extends CustomClipper<Path> {
  final double position;

  _BottomClipper(this.position);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * position);
    path.lineTo(size.width, size.height * position);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BottomClipper oldClipper) {
    return oldClipper.position != position;
  }
}
