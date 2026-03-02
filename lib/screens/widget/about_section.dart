import 'package:flutter/material.dart';
import 'dart:math' as math;

// ══════════════════════════════════════════════════════════════════════════════
//  ABOUT SECTION  —  75% orange  |  25% black
// ══════════════════════════════════════════════════════════════════════════════

const _kOrange = Color(0xFFF26A1B);
const _kOrangeLo = Color(0xFFFF9A5C);
const _kBlack = Color(0xFF080808);

class AboutSection extends StatefulWidget {
  final double screenHeight;

  const AboutSection({super.key, required this.screenHeight});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection>
    with TickerProviderStateMixin {
  late AnimationController _revealCtrl;
  late AnimationController _floatCtrl; 
  late AnimationController _counterCtrl; 

  bool _hasRevealed = false;

  @override
  void initState() {
    super.initState();

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _counterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && !_hasRevealed) {
        _hasRevealed = true;
        _revealCtrl.forward().then((_) => _counterCtrl.forward());
      }
    });
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    _floatCtrl.dispose();
    _counterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.screenHeight,
      child: Row(
        children: [
          // ── LEFT  75%  orange ──────────────────────────────────────────
          Expanded(
            flex: 75,
            child: _OrangePanel(
              revealCtrl: _revealCtrl,
              floatCtrl: _floatCtrl,
              counterCtrl: _counterCtrl,
            ),
          ),

          // ── RIGHT  25%  black ──────────────────────────────────────────
          Expanded(
            flex: 25,
            child: _BlackPanel(revealCtrl: _revealCtrl),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  ORANGE PANEL (CONTENT)
// ══════════════════════════════════════════════════════════════════════════════
class _OrangePanel extends StatelessWidget {
  final AnimationController revealCtrl;
  final AnimationController floatCtrl;
  final AnimationController counterCtrl;

  const _OrangePanel({
    required this.revealCtrl,
    required this.floatCtrl,
    required this.counterCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kOrange,
      child: Stack(
        children: [
          // ── Background noise texture ─────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: floatCtrl,
              builder: (_, __) => CustomPaint(
                painter: _OrangeTexturePainter(phase: floatCtrl.value),
              ),
            ),
          ),

          // ── Large decorative "N" watermark ───────────────────────────
          Positioned(
            right: -30,
            bottom: -80,
            child: AnimatedBuilder(
              animation: floatCtrl,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, floatCtrl.value * 12),
                child: Text(
                  'N',
                  style: TextStyle(
                    fontFamily: 'gondens',
                    fontSize: 500,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.04),
                    height: 1,
                  ),
                ),
              ),
            ),
          ),

          // ── Diagonal accent line ──────────────────────────────────────
          Positioned.fill(child: CustomPaint(painter: _DiagonalLinePainter())),

          // ── Main content ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section label
                // _RevealItem(
                //   controller: revealCtrl,
                //   delay: 0.0,
                //   child: Row(
                //     children: [
                //       Container(width: 30, height: 2, color: Colors.white),
                //       const SizedBox(width: 12),
                //       Text(
                //         '02 / ABOUT',
                //         style: TextStyle(
                //           fontFamily: 'Courier',
                //           fontSize: 12,
                //           letterSpacing: 4,
                //           color: Colors.white.withOpacity(0.8),
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                const SizedBox(height: 20),

                // ABOUT title — split stagger
                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.08,
                  child: const Text(
                    'ABOUT ME.',
                    style: TextStyle(
                      fontFamily: 'gondens',
                      fontSize: 100,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 0.9,
                      letterSpacing: -2,
                    ),
                  ),
                ),

                // _RevealItem(
                //   controller: revealCtrl,
                //   delay: 0.14,
                //   child: Text(
                //     'ME.',
                //     style: TextStyle(
                //       fontFamily: 'gondens',
                //       fontSize: 100,
                //       fontWeight: FontWeight.w900,
                //       color: Colors.white.withOpacity(0.25),
                //       height: 0.9,
                //       letterSpacing: -2,
                //     ),
                //   ),
                // ),

                const SizedBox(height: 40),

                // Updated Professional Description
                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.22,
                  child: SizedBox(
                    width: 600,
                    child: Text(
                      "I am a creative frontend developer passionate about crafting immersive, "
                      "high-performance digital experiences. Bridging the gap between sleek "
                      "design and robust engineering, I build pixel-perfect interfaces that "
                      "feel alive and intuitive.",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Courier',
                        color: Colors.white.withOpacity(0.85),
                        height: 1.8,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Improved Stats row with vertical dividers
                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.38,
                  child: Row(
                    children: [
                      _AnimatedStat(
                        label: 'PROJECTS',
                        targetValue: 8,
                        suffix: '+',
                        controller: counterCtrl,
                      ),
                      const SizedBox(width: 40),
                      Container(width: 1, height: 50, color: Colors.white30), // Vertical Divider
                      const SizedBox(width: 40),
                      _AnimatedStat(
                        label: 'MONTHS EXPERIENCE',
                        targetValue: 8,
                        suffix: '',
                        controller: counterCtrl,
                        delay: 0.15,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // CTA row
                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.48,
                  child: Row(
                    children: [
                      const _GhostButton(label: 'VIEW RESUME →'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  BLACK PANEL (IMAGE)
// ══════════════════════════════════════════════════════════════════════════════
class _BlackPanel extends StatelessWidget {
  final AnimationController revealCtrl;

  const _BlackPanel({required this.revealCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBlack,
      child: Stack(
        children: [
          // Vertical orange accent stripe
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _kOrange.withOpacity(0.7),
                    _kOrangeLo.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Subtle dot pattern
          Positioned.fill(child: CustomPaint(painter: _BlackPanelDots())),

          // Image Reveal
          Center(
            child: _RevealItem(
              controller: revealCtrl,
              delay: 0.4, // delayed so it appears after the text
              child: const _HoverImageProfile(),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  SMALL COMPONENTS
// ══════════════════════════════════════════════════════════════════════════════

/// Profile Image with B&W to Color hover effect
class _HoverImageProfile extends StatefulWidget {
  const _HoverImageProfile();

  @override
  State<_HoverImageProfile> createState() => _HoverImageProfileState();
}

class _HoverImageProfileState extends State<_HoverImageProfile> {
  bool _isHovered = false;

  static const _greyscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  static const _colorMatrix = <double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        width: 280,
        height: 420,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isHovered ? _kOrange : Colors.white24,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? _kOrange.withOpacity(0.3) : Colors.black45,
              blurRadius: _isHovered ? 30 : 15,
              spreadRadius: 2,
            )
          ],
        ),
        // Clip to ensure the image doesn't overflow the sharp borders
        child: ClipRect(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            // Slight zoom-in effect on hover
            transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
            transformAlignment: Alignment.center,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: _isHovered ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, child) {
                // Interpolate between greyscale and full color matrices
                List<double> currentMatrix = List.generate(20, (index) {
                  return _greyscaleMatrix[index] + 
                        (_colorMatrix[index] - _greyscaleMatrix[index]) * value;
                });

                return ColorFiltered(
                  colorFilter: ColorFilter.matrix(currentMatrix),
                  child: Image.asset(
                    'assets/images/nithesh1.png',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Slides and fades in from below with a delay
class _RevealItem extends StatelessWidget {
  final AnimationController controller;
  final double delay; 
  final Widget child;

  const _RevealItem({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final raw = ((controller.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
        final t = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 30),
            child: child,
          ),
        );
      },
    );
  }
}

// ── Animated counter stat ─────────────────────────────────────────────────────
class _AnimatedStat extends StatelessWidget {
  final String label;
  final int targetValue;
  final String suffix;
  final AnimationController controller;
  final double delay;

  const _AnimatedStat({
    required this.label,
    required this.targetValue,
    required this.suffix,
    required this.controller,
    this.delay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final raw = ((controller.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
        final t = Curves.easeOutCubic.transform(raw);
        final val = (targetValue * t).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$val$suffix',
              style: const TextStyle(
                fontFamily: 'gondens',
                fontSize: 60, // Made stats larger
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 10,
                letterSpacing: 2.5,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Ghost button ──────────────────────────────────────────────────────────────
class _GhostButton extends StatefulWidget {
  final String label;
  const _GhostButton({required this.label});
  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Made button larger
        decoration: BoxDecoration(
          color: _hovered ? Colors.white : Colors.black,
          border: Border.all(
            color: _hovered ? Colors.white : Colors.black,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w900,
            color: _hovered ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  PAINTERS
// ══════════════════════════════════════════════════════════════════════════════

class _OrangeTexturePainter extends CustomPainter {
  final double phase;
  _OrangeTexturePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.white.withOpacity(0.05);

    for (int row = 0; row < 12; row++) {
      final y0 = row * (size.height / 11);
      final path = Path();
      path.moveTo(0, y0);
      for (double x = 0; x <= size.width; x += 4) {
        final y = y0 +
            math.sin(
                  (x / size.width) * 4 * math.pi + phase * math.pi * 2 + row,
                ) *
                14;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_OrangeTexturePainter old) => old.phase != phase;
}

class _DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.55, 0),
      Offset(size.width, size.height * 0.45),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.60, 0),
      Offset(size.width, size.height * 0.38),
      Paint()
        ..color = Colors.white.withOpacity(0.03)
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _BlackPanelDots extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.04);
    const spacing = 22.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}