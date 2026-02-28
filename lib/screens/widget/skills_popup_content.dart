import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class SkillsPopupContent extends StatelessWidget {
  final double progress;

  const SkillsPopupContent({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    double contentOpacity = math
        .max(0, (progress - 0.4) / 0.6)
        .toDouble()
        .clamp(0.0, 1.0);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _StaticDotPainter(globalOpacity: contentOpacity),
          ),
        ),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: contentOpacity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          "SKILLS",
                          style: TextStyle(
                            fontSize: 84,
                            fontFamily: 'gondens',
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 52),
                  Opacity(
                    opacity: contentOpacity,
                    child: const Text(
                      "TECH STACK & CORE COMPETENCIES",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        letterSpacing: 4,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Opacity(
                    opacity: contentOpacity,
                    child: Wrap(
                      spacing: 40,
                      runSpacing: 40,
                      alignment: WrapAlignment.center,
                      children: const [
                        _SkillCircle(
                          title: "FLUTTER",
                          icon: Icons.flutter_dash,
                        ),
                        _SkillCircle(title: "HTML/CSS", icon: Icons.code),
                        _SkillCircle(title: "JS", icon: Icons.javascript),
                        _SkillCircle(
                          title: "FIGMA",
                          icon: Icons.design_services,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SkillCircle extends StatefulWidget {
  final String title;
  final IconData icon;

  const _SkillCircle({required this.title, required this.icon});

  @override
  State<_SkillCircle> createState() => _SkillCircleState();
}

class _SkillCircleState extends State<_SkillCircle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            width: _isHovered ? 175 : 160,
            height: _isHovered ? 175 : 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // White tint gets stronger on hover
              color: _isHovered
                  ? Colors.white.withOpacity(0.25)
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white,
                width: _isHovered ? 4 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.15),
                  blurRadius: _isHovered ? 40 : 20,
                  spreadRadius: _isHovered ? 10 : 5,
                ),
              ],
            ),
            child: Center(
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 500),
                turns: _isHovered ? 0.02 : 0, // Subtle tilt
                curve: Curves.easeOutCubic,
                child: Icon(widget.icon, size: 60, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Title text also responds to hover
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: _isHovered ? Colors.black : Colors.white,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
              letterSpacing: _isHovered ? 4 : 2,
              fontSize: 14,
            ),
            child: Text(widget.title),
          ),
        ],
      ),
    );
  }
}

class _StaticDotPainter extends CustomPainter {
  final double globalOpacity;
  _StaticDotPainter({required this.globalOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1 * globalOpacity);
    final rng = math.Random(42);
    for (int i = 0; i < 50; i++) {
      double x = rng.nextDouble() * size.width;
      double y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
