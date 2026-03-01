import 'package:flutter/material.dart';
import 'dart:math' as math;

// ══════════════════════════════════════════════════════════════════════════════
//  ABOUT SECTION  —  75% orange  |  25% black
// ══════════════════════════════════════════════════════════════════════════════

const _kOrange = Color(0xFFF26A1B);
const _kOrangeLo = Color(0xFFFF9A5C);
const _kBlack = Color(0xFF080808);
const _kCream = Color(0xFFF2F2F2);

class AboutSection extends StatefulWidget {
  final double screenHeight;

  const AboutSection({super.key, required this.screenHeight});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection>
    with TickerProviderStateMixin {
  // Reveal animation — triggers once when section enters viewport
  late AnimationController _revealCtrl;
  late AnimationController _floatCtrl; // slow floating decoration
  late AnimationController _counterCtrl; // animated stat counters

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

    // Auto-start after mount (you can replace with scroll trigger)
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
            child: _BlackPanel(revealCtrl: _revealCtrl, floatCtrl: _floatCtrl),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  ORANGE PANEL
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

          // ── Large decorative "A" watermark ───────────────────────────
          Positioned(
            right: -30,
            bottom: -40,
            child: AnimatedBuilder(
              animation: floatCtrl,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, floatCtrl.value * 12),
                child: Text(
                  'A',
                  style: TextStyle(
                    fontFamily: 'gondens',
                    fontSize: 420,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.055),
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
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section label
                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.0,
                  child: Row(
                    children: [
                      Container(width: 28, height: 1.5, color: Colors.white60),
                      const SizedBox(width: 10),
                      Text(
                        '02 / ABOUT',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10,
                          letterSpacing: 3,
                          color: Colors.white.withOpacity(0.65),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ABOUT title — split stagger
                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.08,
                  child: const Text(
                    'ABOUT',
                    style: TextStyle(
                      fontFamily: 'gondens',
                      fontSize: 88,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 0.9,
                      letterSpacing: -2,
                    ),
                  ),
                ),

                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.14,
                  child: Text(
                    'ME.',
                    style: TextStyle(
                      fontFamily: 'gondens',
                      fontSize: 88,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.22),
                      height: 0.9,
                      letterSpacing: -2,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Description
                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.22,
                  child: SizedBox(
                    width: 540,
                    child: Text(
                      "Nithesh is a visionary designer specializing in high-performance "
                      "eyewear. This collection represents a fusion of minimalist "
                      "aesthetics and structural integrity — crafted for those who "
                      "see the world differently.",
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'Courier',
                        color: Colors.white.withOpacity(0.82),
                        height: 1.75,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Stats row
                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.38,
                  child: Row(
                    children: [
                      _AnimatedStat(
                        label: 'PROJECTS',
                        targetValue:8,
                        suffix: '+',
                        controller: counterCtrl,
                      ),
                      const SizedBox(width: 48),
                      _AnimatedStat(
                        label: 'EXPERIENCE',
                        targetValue: 8,
                        suffix: ' Months',
                        controller: counterCtrl,
                        delay: 0.15,
                      ),
                     
                     
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // CTA row
                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.48,
                  child: Row(
                    children: [
                      _GhostButton(label: 'VIEW RESUME →'),
                      const SizedBox(width: 16),
                     
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
//  BLACK PANEL
// ══════════════════════════════════════════════════════════════════════════════
class _BlackPanel extends StatelessWidget {
  final AnimationController revealCtrl;
  final AnimationController floatCtrl;

  const _BlackPanel({required this.revealCtrl, required this.floatCtrl});

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

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top — floating skills tags
                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                      const SizedBox(height: 16),
                      ...[
                        
                      ].asMap().entries.map(
                        (e) => _SkillTag(
                          label: e.value,
                          index: e.key,
                          revealCtrl: revealCtrl,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Middle — floating circle graphic
                _RevealItem(
                  controller: revealCtrl,
                  delay: 0.42,
                  child: AnimatedBuilder(
                    animation: floatCtrl,
                    builder: (_, __) => Center(
                      child: Transform.translate(
                        offset: Offset(0, floatCtrl.value * 8 - 4),
                        child: _OrbitGraphic(),
                      ),
                    ),
                  ),
                ),

                const Spacer(),
              ],
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

/// Slides and fades in from below with a delay
class _RevealItem extends StatelessWidget {
  final AnimationController controller;
  final double delay; // 0..1
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
        final raw = ((controller.value - delay) / (1.0 - delay)).clamp(
          0.0,
          1.0,
        );
        final t = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 28),
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
        final raw = ((controller.value - delay) / (1.0 - delay)).clamp(
          0.0,
          1.0,
        );
        final t = Curves.easeOutCubic.transform(raw);
        final val = (targetValue * t).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$val$suffix',
              style: const TextStyle(
                fontFamily: 'gondens',
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 8.5,
                letterSpacing: 2.5,
                color: Colors.white.withOpacity(0.55),
                fontWeight: FontWeight.w600,
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
  final bool filled;
  const _GhostButton({required this.label, this.filled = false});

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: widget.filled
              ? (_hovered ? Colors.white : _kBlack)
              : (_hovered
                    ? Colors.white.withOpacity(0.12)
                    : Colors.transparent),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? 1.0 : 0.4),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
            color: widget.filled
                ? (_hovered ? _kOrange : Colors.white)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Skill tag (right panel) ───────────────────────────────────────────────────
class _SkillTag extends StatefulWidget {
  final String label;
  final int index;
  final AnimationController revealCtrl;

  const _SkillTag({
    required this.label,
    required this.index,
    required this.revealCtrl,
  });

  @override
  State<_SkillTag> createState() => _SkillTagState();
}

class _SkillTagState extends State<_SkillTag> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final delay = 0.32 + widget.index * 0.05;
    return AnimatedBuilder(
      animation: widget.revealCtrl,
      builder: (_, __) {
        final raw = ((widget.revealCtrl.value - delay) / (1.0 - delay)).clamp(
          0.0,
          1.0,
        );
        final t = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset((1 - t) * -20, 0),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _hovered
                      ? _kOrange.withOpacity(0.18)
                      : Colors.white.withOpacity(0.04),
                  border: Border.all(
                    color: _hovered
                        ? _kOrange.withOpacity(0.5)
                        : Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _hovered ? _kOrange : _kOrange.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: _hovered
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Pulsing availability dot ──────────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 12 + _c.value * 6,
            height: 12 + _c.value * 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00DD88).withOpacity((1 - _c.value) * 0.3),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF00DD88),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Orbit graphic ─────────────────────────────────────────────────────────────
class _OrbitGraphic extends StatefulWidget {
  @override
  State<_OrbitGraphic> createState() => _OrbitGraphicState();
}

class _OrbitGraphicState extends State<_OrbitGraphic>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
        size: const Size(90, 90),
        painter: _OrbitPainter(phase: _c.value * 2 * math.pi),
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
    // Flowing wavy lines for texture
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.white.withOpacity(0.05);

    for (int row = 0; row < 12; row++) {
      final y0 = row * (size.height / 11);
      final path = Path();
      path.moveTo(0, y0);
      for (double x = 0; x <= size.width; x += 4) {
        final y =
            y0 +
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
    // Single dramatic diagonal
    canvas.drawLine(
      Offset(size.width * 0.55, 0),
      Offset(size.width, size.height * 0.45),
      paint,
    );
    // Parallel offset
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

class _OrbitPainter extends CustomPainter {
  final double phase;
  _OrbitPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 32.0;

    // Orbit ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = _kOrange.withOpacity(0.25),
    );

    // Inner ring
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.55,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.white.withOpacity(0.10),
    );

    // Center dot
    canvas.drawCircle(
      Offset(cx, cy),
      5,
      Paint()..color = _kOrange.withOpacity(0.8),
    );
    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.white);

    // Orbiting particle
    final px = cx + math.cos(phase) * r;
    final py = cy + math.sin(phase) * r;

    // Trail
    for (int i = 0; i < 8; i++) {
      final trailPhase = phase - i * 0.22;
      final tx = cx + math.cos(trailPhase) * r;
      final ty = cy + math.sin(trailPhase) * r;
      canvas.drawCircle(
        Offset(tx, ty),
        2.5 - i * 0.28,
        Paint()..color = _kOrange.withOpacity((1 - i / 8) * 0.5),
      );
    }

    // Main particle
    canvas.drawCircle(
      Offset(px, py),
      3.5,
      Paint()
        ..color = _kOrange
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(Offset(px, py), 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.phase != phase;
}
