import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'analysis_loading_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _flashOn = false;
  bool _isFrontCamera = false;
  bool _isCapturing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildCameraPreview(),
                _buildGuideOverlay(),
                _buildTopControls(),
              ],
            ),
          ),
          _buildGuidelines(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Take Photo',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: const Center(
              child: Icon(
                Icons.face,
                size: 100,
                color: Colors.white24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideOverlay() {
    return Positioned.fill(
      child: Center(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            margin: const EdgeInsets.all(AppTheme.space4),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            ),
            child: Stack(
              children: [
                // Face guide oval
                Center(
                  child: Container(
                    width: 200,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Corner markers
                ..._buildCornerMarkers(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    const markerSize = 20.0;
    const markerColor = AppTheme.primary;
    const offset = 12.0;

    return [
      Positioned(
        top: offset,
        left: offset,
        child: _buildCornerMarker(markerSize, markerColor, isTopLeft: true),
      ),
      Positioned(
        top: offset,
        right: offset,
        child: _buildCornerMarker(markerSize, markerColor, isTopRight: true),
      ),
      Positioned(
        bottom: offset,
        left: offset,
        child: _buildCornerMarker(markerSize, markerColor, isBottomLeft: true),
      ),
      Positioned(
        bottom: offset,
        right: offset,
        child: _buildCornerMarker(markerSize, markerColor, isBottomRight: true),
      ),
    ];
  }

  Widget _buildCornerMarker(double size, Color color,
      {bool isTopLeft = false,
      bool isTopRight = false,
      bool isBottomLeft = false,
      bool isBottomRight = false}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          isTopLeft: isTopLeft,
          isTopRight: isTopRight,
          isBottomLeft: isBottomLeft,
          isBottomRight: isBottomRight,
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space4),
          child: Column(
            children: [
              _buildControlButton(
                icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                label: 'Flash',
                isActive: _flashOn,
                onTap: () {
                  setState(() {
                    _flashOn = !_flashOn;
                  });
                },
              ),
              const SizedBox(height: AppTheme.space3),
              _buildControlButton(
                icon: _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                label: 'Flip',
                onTap: () {
                  setState(() {
                    _isFrontCamera = !_isFrontCamera;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space3),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildGuidelines() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(AppTheme.space4),
      child: Column(
        children: [
          Text(
            'Tips for a good photo',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.space3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGuidelineItem(
                icon: Icons.wb_sunny,
                label: 'Good\nLighting',
              ),
              _buildGuidelineItem(
                icon: Icons.face,
                label: 'Face\nCentered',
              ),
              _buildGuidelineItem(
                icon: Icons.remove_red_eye,
                label: 'No\nGlasses',
              ),
              _buildGuidelineItem(
                icon: Icons.block,
                label: 'No\nFilters',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.space2),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Icon(
            icon,
            color: AppTheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(height: AppTheme.space1),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.space6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildGalleryButton(),
          _buildCaptureButton(),
          _buildGalleryButton(), // Placeholder for symmetry
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isCapturing ? null : _capturePhoto,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primary,
            width: 4,
          ),
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _isCapturing ? AppTheme.primary.withValues(alpha: 0.5) : AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: _isCapturing
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 32,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: _pickFromGallery,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.photo_library,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _capturePhoto() async {
    setState(() {
      _isCapturing = true;
    });

    // Simulate capture delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AnalysisLoadingScreen()),
      );
    }
  }

  void _pickFromGallery() {
    // TODO: Implement gallery picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery picker coming soon!'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  _CornerPainter({
    required this.color,
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    const cornerLength = 15.0;

    if (isTopLeft) {
      path.moveTo(0, cornerLength);
      path.lineTo(0, 0);
      path.lineTo(cornerLength, 0);
    } else if (isTopRight) {
      path.moveTo(size.width - cornerLength, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, cornerLength);
    } else if (isBottomLeft) {
      path.moveTo(0, size.height - cornerLength);
      path.lineTo(0, size.height);
      path.lineTo(cornerLength, size.height);
    } else if (isBottomRight) {
      path.moveTo(size.width - cornerLength, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, size.height - cornerLength);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
