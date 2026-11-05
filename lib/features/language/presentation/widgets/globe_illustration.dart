import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:compressor/core/theme/app_colors.dart';

/// Clean, polished 3D-styled Globe illustration with chat bubbles matching Screen 1.
class GlobeIllustration extends StatefulWidget {
  final double size;

  const GlobeIllustration({super.key, this.size = 190});

  @override
  State<GlobeIllustration> createState() => _GlobeIllustrationState();
}

class _GlobeIllustrationState extends State<GlobeIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final floatOffset = math.sin(_animController.value * math.pi) * 4.0;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft background glow
              Container(
                width: widget.size * 0.85,
                height: widget.size * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 36,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),

              // Shaded 3D Globe with lines
              Transform.translate(
                offset: Offset(0, floatOffset),
                child: CustomPaint(
                  size: Size(widget.size * 0.72, widget.size * 0.72),
                  painter: _GlobePainter(),
                ),
              ),

              // Top-left Chat bubble with text lines
              Positioned(
                top: widget.size * 0.14 - floatOffset * 0.5,
                left: widget.size * 0.10,
                child: _buildChatBubble(
                  width: 44,
                  height: 32,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 14,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top-right Chat bubble with dots
              Positioned(
                top: widget.size * 0.22 + floatOffset * 0.7,
                right: widget.size * 0.08,
                child: _buildChatBubble(
                  width: 48,
                  height: 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom subtle speech bubble
              Positioned(
                bottom: widget.size * 0.12 - floatOffset * 0.3,
                right: widget.size * 0.22,
                child: Container(
                  width: 28,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.imageBlue.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatBubble({
    required double width,
    required double height,
    required Widget child,
  }) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

class _GlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 3D Sphere gradient background
    final spherePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.4),
        radius: 0.9,
        colors: [
          Color(0xFF93C5FD), // Light highlight
          Color(0xFF3B82F6), // Mid blue
          Color(0xFF1D4ED8), // Deep shadow
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, spherePaint);

    // Grid lines clip
    canvas.save();
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Longitude curves
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 0.75, height: radius * 2),
      linePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 1.45, height: radius * 2),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      linePaint,
    );

    // Latitude curves
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 0.8),
      linePaint,
    );
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      linePaint,
    );

    // Top glossy reflection
    final glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.45));

    canvas.drawOval(
      Rect.fromLTWH(radius * 0.25, radius * 0.1, radius * 1.5, radius * 0.8),
      glossPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
