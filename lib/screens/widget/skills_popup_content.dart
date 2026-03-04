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
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: contentOpacity,
                  child: const Text(
                    "SKILLS",
                    style: TextStyle(
                      fontSize: 52, // Slightly smaller for horizontal balance
                      fontFamily: 'gondens',
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                // Horizontal Layout Sections
                Opacity(
                  opacity: contentOpacity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- TECH SECTION ---
                      Expanded(
                        child: _buildSection(
                          "TECH STACK",
                          [
                            const _SkillCircle(title: "FLUTTER", icon: Icons.flutter_dash, percentage: 0.9),
                            const _SkillCircle(title: "DART", icon: Icons.code, percentage: 0.88),
                            const _SkillCircle(title: "PYTHON", icon: Icons.terminal, percentage: 0.8),
                            const _SkillCircle(title: "JS", icon: Icons.javascript, percentage: 0.75),
                            const _SkillCircle(title: "HTML/CSS", icon: Icons.code, percentage: 0.85),
                          ],
                        ),
                      ),
                      
                      // --- DESIGN SECTION ---
                      Expanded(
                        child: _buildSection(
                          "DESIGN",
                          [
                            const _SkillCircle(title: "FIGMA", icon: Icons.design_services, percentage: 0.7),
                          ],
                        ),
                      ),
                      
                      // --- TOOLS SECTION ---
                      Expanded(
                        child: _buildSection(
                          "TOOLS",
                          [
                            const _SkillCircle(title: "GITHUB", icon: Icons.hub, percentage: 0.85),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> skills) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            letterSpacing: 4,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: skills,
        ),
      ],
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
    required this.percentage
  });

  @override
  State<_SkillCircle> createState() => _SkillCircleState();
}

class _SkillCircleState extends State<_SkillCircle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    double baseSize = 90; // Reduced for horizontal fit
    double hoverSize = 100;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: _isHovered ? hoverSize : baseSize,
                height: _isHovered ? hoverSize : baseSize,
                child: CustomPaint(
                  painter: _PercentagePainter(
                    percentage: widget.percentage,
                    color: _isHovered ? Colors.white : Colors.white.withOpacity(0.4),
                    thickness: _isHovered ? 4 : 2,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isHovered ? (hoverSize - 12) : (baseSize - 12),
                height: _isHovered ? (hoverSize - 12) : (baseSize - 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isHovered
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.08),
                ),
                child: Center(
                  child: Icon(
                    widget.icon, 
                    size: _isHovered ? 28 : 24, 
                    color: Colors.black
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isHovered ? Colors.black : Colors.white70,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 9,
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

  _PercentagePainter({required this.percentage, required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thickness;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * percentage, false, paint);
  }

  @override
  bool shouldRepaint(covariant _PercentagePainter oldDelegate) => true;
}

class _StaticDotPainter extends CustomPainter {
  final double globalOpacity;
  _StaticDotPainter({required this.globalOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05 * globalOpacity);
    final rng = math.Random(42);
    for (int i = 0; i < 30; i++) {
      double x = rng.nextDouble() * size.width;
      double y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}