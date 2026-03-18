import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key, this.forceDark = false});
  final bool forceDark;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.forceDark || Theme.of(context).brightness == Brightness.dark;

    final color1 = isDark ? const Color(0xFF1B5E20) : const Color(0xFFA5D6A7);
    final color2 = isDark ? const Color(0xFF004D40) : const Color(0xFF80CBC4);
    final color3 = isDark ? const Color(0xFF33691E) : const Color(0xFFC5E1A5);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              color: isDark ? const Color(0xFF0D120E) : const Color(0xFFF1F8E9),
            ),
            Positioned(
              top: -100 + (100 * math.sin(_animController.value * 2 * math.pi)),
              left: -100 + (50 * math.cos(_animController.value * 2 * math.pi)),
              child: _buildOrb(color1, 400),
            ),
            Positioned(
              bottom: -50 + (100 * math.cos(_animController.value * 2 * math.pi)),
              right: -50 + (100 * math.sin(_animController.value * 2 * math.pi)),
              child: _buildOrb(color2, 500),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 3 +
                  (100 * math.sin(_animController.value * math.pi)),
              left: MediaQuery.of(context).size.width / 3 +
                  (100 * math.cos(_animController.value * math.pi)),
              child: _buildOrb(color3, 300),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: GridPatternPainter(isDark: isDark),
              ),
            ),
            ...List.generate(8, (index) {
              final reverse = index % 2 == 0 ? 1 : -1;
              return Positioned(
                top: (MediaQuery.of(context).size.height / 2) +
                    (250 * math.sin(_animController.value * math.pi * 3 + index) * reverse),
                left: (MediaQuery.of(context).size.width / 2) +
                    (250 * math.cos(_animController.value * math.pi * 2 + index) * reverse),
                child: _buildOrb(Colors.white.withValues(alpha: 0.15), 6 + index * 4.0),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  const GridPatternPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    final Rect rect = Offset.zero & size;
    final Gradient gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.transparent,
        (isDark ? Colors.black : Colors.white).withValues(alpha: 0.6),
      ],
      stops: const [0.4, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
