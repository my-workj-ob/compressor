import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:compressor/core/theme/app_colors.dart';

/// Polished 3D-styled compression hero illustration matching Screen 2 of reference design.
class HeroCompressionIllustration extends StatefulWidget {
  final double size;

  const HeroCompressionIllustration({super.key, this.size = 180});

  @override
  State<HeroCompressionIllustration> createState() =>
      _HeroCompressionIllustrationState();
}

class _HeroCompressionIllustrationState
    extends State<HeroCompressionIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final float = math.sin(_controller.value * math.pi) * 3.5;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radial soft cyan-blue glow
              Container(
                width: widget.size * 0.9,
                height: widget.size * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.18),
                      AppColors.primaryLight.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),

              // Background purple sheet
              Transform.translate(
                offset: Offset(widget.size * 0.18, -widget.size * 0.12 - float * 0.5),
                child: Transform.rotate(
                  angle: 0.18,
                  child: Container(
                    width: widget.size * 0.38,
                    height: widget.size * 0.48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Red PDF document card
              Transform.translate(
                offset: Offset(-widget.size * 0.18, -widget.size * 0.08 + float * 0.6),
                child: Transform.rotate(
                  angle: -0.16,
                  child: Container(
                    width: widget.size * 0.44,
                    height: widget.size * 0.54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF87171), Color(0xFFDC2626)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pdfRed.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Center Foreground 3D blue download block
              Transform.translate(
                offset: Offset(widget.size * 0.08, widget.size * 0.08 - float),
                child: Container(
                  width: widget.size * 0.44,
                  height: widget.size * 0.48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.38),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),

              // Floating subtle sparkle top-left
              Positioned(
                top: widget.size * 0.15 - float * 0.4,
                left: widget.size * 0.12,
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFFBBF24),
                  size: 16,
                ),
              ),

              // Floating subtle sparkle bottom-right
              Positioned(
                bottom: widget.size * 0.14 + float * 0.4,
                right: widget.size * 0.12,
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF60A5FA),
                  size: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
