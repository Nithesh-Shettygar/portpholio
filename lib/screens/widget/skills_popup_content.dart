import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class SkillsPopupContent extends StatelessWidget {
  final double progress;

  const SkillsPopupContent({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    // Global opacity for the header and background dots
    double contentOpacity = math
        .max(0, (progress - 0.3) / 0.7)
        .toDouble()
        .clamp(0.0, 1.0);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _StaticDotPainter(globalOpacity: contentOpacity),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- Updated Title ---
                  Opacity(
                    opacity: contentOpacity,
                    child: Column(
                      children: [
                        Text(
                          "SKILLS",
                          style: TextStyle(
                            fontSize: isMobile ? 38 : 52,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: isMobile ? 8 : 12,
                            fontFamily: 'gondens',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(height: 2, width: 60, color: Colors.white24),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 30 : 60),

                  // --- Animated Cards Grid ---
                  Wrap(
                    spacing: isMobile ? 16 : 40,
                    runSpacing: isMobile ? 16 : 40,
                    alignment: WrapAlignment.center,
                    children: [
                      _EntranceAnimation(
                        delay: 0.4,
                        progress: progress,
                        child: _HoverAnimatedCard(
                          title: "DEVELOPMENT",
                          baseAngle: -8 * (math.pi / 180),
                          skills: const [
                            _SkillCircle(
                              title: "FLUTTER",
                              icon: Icons.flutter_dash,
                              percentage: 0.9,
                            ),
                            _SkillCircle(
                              title: "DART",
                              icon: Icons.code,
                              percentage: 0.88,
                            ),
                            _SkillCircle(
                              title: "PYTHON",
                              icon: Icons.terminal,
                              percentage: 0.8,
                            ),
                            _SkillCircle(
                              title: "JS",
                              icon: Icons.javascript,
                              percentage: 0.75,
                            ),
                          ],
                        ),
                      ),
                      _EntranceAnimation(
                        delay: 0.55,
                        progress: progress,
                        child: _HoverAnimatedCard(
                          title: "DESIGN",
                          baseAngle: 4 * (math.pi / 180),
                          skills: const [
                            _SkillCircle(
                              title: "FIGMA",
                              icon: Icons.design_services,
                              percentage: 0.75,
                            ),
                            _SkillCircle(
                              title: "ADOBE PS",
                              icon: Icons.brush,
                              percentage: 0.65,
                            ),
                            _SkillCircle(
                              title: "UI/UX",
                              icon: Icons.auto_awesome,
                              percentage: 0.8,
                            ),
                          ],
                        ),
                      ),
                      _EntranceAnimation(
                        delay: 0.7,
                        progress: progress,
                        child: _HoverAnimatedCard(
                          title: "INFRA",
                          baseAngle: -12 * (math.pi / 180),
                          skills: const [
                            _SkillCircle(
                              title: "GITHUB",
                              icon: Icons.hub,
                              percentage: 0.85,
                            ),
                            _SkillCircle(
                              title: "FIREBASE",
                              icon: Icons.cloud,
                              percentage: 0.8,
                            ),
                            _SkillCircle(
                              title: "AWS",
                              icon: Icons.storage,
                              percentage: 0.5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Entrance Animation Wrapper ---
class _EntranceAnimation extends StatelessWidget {
  final Widget child;
  final double delay;
  final double progress;

  const _EntranceAnimation({
    required this.child,
    required this.delay,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate local animation progress based on the global progress scroll
    double localProgress = math
        .max(0, (progress - delay) / 0.3)
        .toDouble()
        .clamp(0.0, 1.0);

    // Curving the animation for a "pop in" feel
    double curve = Curves.easeOutBack.transform(localProgress);

    return Opacity(
      opacity: localProgress,
      child: Transform.translate(
        offset: Offset(0, 100 * (1 - curve)), // Slides from 100px down to 0
        child: child,
      ),
    );
  }
}

class _HoverAnimatedCard extends StatefulWidget {
  final String title;
  final List<Widget> skills;
  final double baseAngle;

  const _HoverAnimatedCard({
    required this.title,
    required this.skills,
    required this.baseAngle,
  });

  @override
  State<_HoverAnimatedCard> createState() => _HoverAnimatedCardState();
}

class _HoverAnimatedCardState extends State<_HoverAnimatedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(isMobile ? 0.0 : (_isHovered ? 0.0 : widget.baseAngle))
          ..scale(_isHovered ? 1.05 : 1.0),
        child: Container(
          width: isMobile ? 290 : 320,
          height: isMobile ? 300 : 420,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    fontFamily: 'gondens',
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 25,
                      alignment: WrapAlignment.center,
                      children: widget.skills,
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

class _SkillCircle extends StatefulWidget {
  final String title;
  final IconData icon;
  final double percentage;

  const _SkillCircle({
    required this.title,
    required this.icon,
    required this.percentage,
  });

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CustomPaint(
                  painter: _PercentagePainter(
                    percentage: widget.percentage,
                    color: _isHovered
                        ? const Color(0xFFF26A1B)
                        : const Color(0xFFF26A1B),
                    thickness: 3,
                  ),
                ),
              ),
              Icon(
                widget.icon,
                size: 20,
                color: _isHovered ? Colors.white : Colors.white60,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: TextStyle(
              color: const Color(0xFFF26A1B),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PercentagePainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double thickness;

  _PercentagePainter({
    required this.percentage,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thickness;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percentage,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StaticDotPainter extends CustomPainter {
  final double globalOpacity;
  _StaticDotPainter({required this.globalOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05 * globalOpacity);
    final rng = math.Random(42);
    for (int i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        0.8,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
