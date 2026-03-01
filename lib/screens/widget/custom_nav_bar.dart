import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                        T H E   S E I S M I C                           ║
// ║                                                                          ║
// ║  The world's first EKG / oscilloscope navbar.                           ║
// ║  A glowing cyan waveform runs through the base of the bar —             ║
// ║  flat on idle items, rippling gently on hover, erupting in a            ║
// ║  seismic particle burst on tap. No pills. No backgrounds.               ║
// ║  The wave IS the indicator.                                             ║
// ╚══════════════════════════════════════════════════════════════════════════╝

// ── Accent palette ─────────────────────────────────────────────────────────
const _kCyan     = Color(0xFFF26A1B);
const _kCyanDim  = Color.fromARGB(255, 255, 186, 146);
const _kBg       = Color(0xFF070A10);
const _kSurface  = Color(0xFF0D1117);

// ───────────────────────────────────────────────────────────────────────────
//  PUBLIC WIDGET  (same API as before)
// ───────────────────────────────────────────────────────────────────────────
class CustomNavBar extends StatefulWidget {
  final int currentIndex;
  final VoidCallback onHomeTap;
  final VoidCallback onAboutTap;
  final VoidCallback onProjectsTap;
  final VoidCallback onSkillsTap;
  final VoidCallback onExperienceTap;
  final VoidCallback onContactTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onHomeTap,
    required this.onAboutTap,
    required this.onProjectsTap,
    required this.onSkillsTap,
    required this.onExperienceTap,
    required this.onContactTap,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>
    with TickerProviderStateMixin {
  // Wave phase — drives the continuous sine oscillation
  late AnimationController _phaseCtrl;
  // Burst — fires 0 → 1 on every tap
  late AnimationController _burstCtrl;
  // Smooth per-item amplitude (avoids jarring instant jumps)
  late List<AnimationController> _ampCtrls;
  late List<Animation<double>> _ampAnims;

  int _burstIndex = -1;
  int _hoveredIndex = -1;

  static const _total = 6;

  @override
  void initState() {
    super.initState();

    _phaseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    // One amplitude controller per item
    _ampCtrls = List.generate(
      _total,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );
    _ampAnims = _ampCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOutCubic))
        .toList();

    // Initialise the active item's amp to full
    _ampCtrls[widget.currentIndex].value = 1.0;
  }

  @override
  void didUpdateWidget(CustomNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      // Fade out old, fade in new, fire burst
      _ampCtrls[old.currentIndex].reverse();
      _ampCtrls[widget.currentIndex].forward();
      _burstIndex = widget.currentIndex;
      _burstCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _phaseCtrl.dispose();
    _burstCtrl.dispose();
    for (final c in _ampCtrls) c.dispose();
    super.dispose();
  }

  List<VoidCallback> get _cbs => [
        widget.onHomeTap,
        widget.onAboutTap,
        widget.onProjectsTap,
        widget.onSkillsTap,
        widget.onExperienceTap,
        widget.onContactTap,
      ];

  static const _labels = [
    'Home', 'About', 'Projects', 'Skills', 'Experience', 'Contact'
  ];
  static const _icons = [
    Icons.home_rounded,
    Icons.person_rounded,
    Icons.grid_view_rounded,
    Icons.bolt_rounded,
    Icons.work_rounded,
    Icons.mail_rounded,
  ];

  void _onItemTap(int i) {
    _cbs[i]();
  }

  void _onHover(int i, bool entering) {
    setState(() => _hoveredIndex = entering ? i : -1);
    if (i != widget.currentIndex) {
      entering
          ? _ampCtrls[i].animateTo(0.45,
              duration: const Duration(milliseconds: 250))
          : _ampCtrls[i].animateTo(0.0,
              duration: const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _phaseCtrl,
        _burstCtrl,
        ..._ampAnims,
      ]),
      builder: (context, _) {
        final amps = List.generate(_total, (i) => _ampAnims[i].value);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              // Deep float shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 60,
                spreadRadius: -10,
                offset: const Offset(0, 20),
              ),
              // Cyan ambient halo (breathes with active amp)
              BoxShadow(
                color: _kCyan.withOpacity(amps[widget.currentIndex] * 0.07),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: _kBg.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.055),
                    width: 1,
                  ),
                ),
                // CustomPaint sizes to its child (the Row)
                child: CustomPaint(
                  painter: _SeismicPainter(
                    phase: _phaseCtrl.value * 2 * math.pi,
                    amplitudes: amps,
                    burstProgress: _burstCtrl.value,
                    burstIndex: _burstIndex,
                    totalItems: _total,
                  ),
                  child: SizedBox(
                    height: 52,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_total, (i) {
                        return _SeismicItem(
                          icon: _icons[i],
                          label: _labels[i],
                          isSelected: widget.currentIndex == i,
                          isHovered: _hoveredIndex == i,
                          ampValue: amps[i],
                          onTap: () => _onItemTap(i),
                          onHover: (h) => _onHover(i, h),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  SEISMIC PAINTER  — draws the EKG wave, glow, particles, scanlines
// ───────────────────────────────────────────────────────────────────────────
class _SeismicPainter extends CustomPainter {
  final double phase;
  final List<double> amplitudes;
  final double burstProgress;
  final int burstIndex;
  final int totalItems;

  const _SeismicPainter({
    required this.phase,
    required this.amplitudes,
    required this.burstProgress,
    required this.burstIndex,
    required this.totalItems,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final iw = size.width / totalItems;
    // Wave centerline — sits in the lower fifth of the slim bar
    final baseY = size.height * 0.82;
    const maxAmp = 10.0;
    const steps = 500;

    // ── Build wave path ───────────────────────────────────────────────────
    final path = Path();
    for (int s = 0; s <= steps; s++) {
      final t = s / steps;
      final x = t * size.width;
      double dy = 0;

      for (int i = 0; i < totalItems; i++) {
        final amp = amplitudes[i];
        if (amp < 0.005) continue;
        final cx = (i + 0.5) * iw;
        final sigma = iw * 0.40;
        final norm = (x - cx) / sigma;
        final gauss = math.exp(-norm * norm * 0.5);
        // wave travels rightward from the center of each item
        final wavePhase = phase + (x - cx) / iw * 2.0 * math.pi;
        dy -= amp * maxAmp * gauss * math.sin(wavePhase);
      }

      // Burst spike — sharp gaussian with high-frequency ripple
      if (burstIndex >= 0 && burstProgress > 0 && burstProgress < 1.0) {
        final cx = (burstIndex + 0.5) * iw;
        final sigma = iw * 0.32;
        final norm = (x - cx) / sigma;
        final spike = math.exp(-norm * norm * 1.2);
        final decay = math.pow(1 - burstProgress, 1.8).toDouble();
        final ripple = math.sin(phase * 5 + (x - cx) / iw * 10 * math.pi);
        dy -= decay * 18 * spike * ripple;
      }

      final y = baseY + dy;
      if (s == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }

    // ── Outer glow (wide, soft) ───────────────────────────────────────────
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = _kCyan.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // ── Mid glow ─────────────────────────────────────────────────────────
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _kCyan.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // ── Core line (gradient) ──────────────────────────────────────────────
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = ui.Gradient.linear(
          Offset(0, baseY),
          Offset(size.width, baseY),
          [
            _kCyan.withOpacity(0.25),
            _kCyan.withOpacity(1.0),
            _kCyanDim.withOpacity(0.85),
            _kCyan.withOpacity(1.0),
            _kCyan.withOpacity(0.25),
          ],
          [0.0, 0.2, 0.5, 0.8, 1.0],
        ),
    );

    // ── Tiny bright dot at active item peak ──────────────────────────────
    for (int i = 0; i < totalItems; i++) {
      if (amplitudes[i] < 0.1) continue;
      final cx = (i + 0.5) * iw;
      final dotY = baseY - amplitudes[i] * maxAmp;
      canvas.drawCircle(
        Offset(cx, dotY),
        2.5,
        Paint()
          ..color = Colors.white.withOpacity(amplitudes[i] * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        Offset(cx, dotY),
        1.2,
        Paint()..color = Colors.white,
      );
    }

    // ── Burst particles ───────────────────────────────────────────────────
    if (burstIndex >= 0 && burstProgress > 0.0 && burstProgress < 1.0) {
      final cx = (burstIndex + 0.5) * iw;
      final rng = math.Random(burstIndex * 13 + 77); // deterministic seed
      const numP = 14;

      for (int p = 0; p < numP; p++) {
        final angle = p * (2 * math.pi / numP) + rng.nextDouble() * 0.5;
        final speed = 22.0 + rng.nextDouble() * 22.0;
        final ease = _easeOutCubic(burstProgress);
        final px = cx + math.cos(angle) * speed * ease;
        final py = baseY + math.sin(angle) * speed * ease;
        final opacity = math.pow(1 - burstProgress, 1.4).toDouble() * 0.85;
        final radius = 2.5 * (1 - burstProgress * 0.6);

        canvas.drawCircle(
          Offset(px, py),
          radius,
          Paint()
            ..color = _kCyan.withOpacity(opacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
        );
      }

      // Shockwave ring
      final ringRadius = _easeOutCubic(burstProgress) * iw * 0.55;
      final ringOpacity = math.pow(1 - burstProgress, 2.0).toDouble() * 0.5;
      canvas.drawCircle(
        Offset(cx, baseY),
        ringRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _kCyan.withOpacity(ringOpacity),
      );

      // Central flash
      final flashOpacity = math.max(0.0, 0.6 - burstProgress * 1.1);
      if (flashOpacity > 0) {
        canvas.drawCircle(
          Offset(cx, baseY),
          14 * burstProgress,
          Paint()
            ..color = Colors.white.withOpacity(flashOpacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }
    }

    // ── Subtle CRT scanlines (just on the lower strip) ────────────────────
    final scanPaint = Paint()
      ..color = Colors.white.withOpacity(0.018)
      ..strokeWidth = 0.5;
    for (double y = baseY - 14; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanPaint);
    }

    // ── Corner bracket decorations (PCB-style) ────────────────────────────
    _drawCornerBrackets(canvas, size);
  }

  void _drawCornerBrackets(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _kCyan.withOpacity(0.18);
    const len = 7.0;
    const inset = 5.0;

    // Top-left
    canvas.drawLine(Offset(inset, inset + len), Offset(inset, inset), p);
    canvas.drawLine(Offset(inset, inset), Offset(inset + len, inset), p);
    // Top-right
    canvas.drawLine(Offset(size.width - inset - len, inset), Offset(size.width - inset, inset), p);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset, inset + len), p);
    // Bottom-left
    canvas.drawLine(Offset(inset, size.height - inset - len), Offset(inset, size.height - inset), p);
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset + len, size.height - inset), p);
    // Bottom-right
    canvas.drawLine(Offset(size.width - inset - len, size.height - inset), Offset(size.width - inset, size.height - inset), p);
    canvas.drawLine(Offset(size.width - inset, size.height - inset - len), Offset(size.width - inset, size.height - inset), p);
  }

  static double _easeOutCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();

  @override
  bool shouldRepaint(_SeismicPainter old) => true;
}

// ───────────────────────────────────────────────────────────────────────────
//  SEISMIC ITEM  — the individual nav button
// ───────────────────────────────────────────────────────────────────────────
class _SeismicItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isHovered;
  final double ampValue; // 0..1 smoothed amplitude
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  const _SeismicItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isHovered,
    required this.ampValue,
    required this.onTap,
    required this.onHover,
  });

  @override
  State<_SeismicItem> createState() => _SeismicItemState();
}

class _SeismicItemState extends State<_SeismicItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amp = widget.ampValue;
    // Icon colour fades from dim white → bright cyan as amp increases
    final iconColor = Color.lerp(
      Colors.white.withOpacity(0.22),
    const Color(0xFFF26A1B),
      amp,
    )!;

    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) { _pressCtrl.reverse(); widget.onTap(); },
        onTapCancel: () => _pressCtrl.reverse(),
        child: AnimatedBuilder(
          animation: _pressAnim,
          builder: (context, _) {
            return Transform.scale(
              scale: _pressAnim.value,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isSelected ? 18 : 13,
                  vertical: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Icon with lift + glow ──────────────────────────
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutBack,
                      transform: amp > 0.05
                          ? (Matrix4.identity()..translate(0.0, -2.5 * amp))
                          : Matrix4.identity(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft halo behind icon
                          if (amp > 0.05)
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                   const Color(0xFFF26A1B),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          Icon(
                            widget.icon,
                            color: iconColor,
                            size: 18,
                          ),
                        ],
                      ),
                    ),

                    // ── Label — expands horizontally beside icon ───────
                    ClipRect(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutExpo,
                        child: SizedBox(
                          width: widget.isSelected ? null : 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 220),
                            opacity: widget.isSelected ? 1.0 : 0.0,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 7),
                              child: Text(
                                widget.label.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  color:const Color(0xFFF26A1B),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  DEMO — standalone preview
// ═══════════════════════════════════════════════════════════════════════════
class _SeismicNavDemo extends StatefulWidget {
  const _SeismicNavDemo();
  @override
  State<_SeismicNavDemo> createState() => _SeismicNavDemoState();
}

class _SeismicNavDemoState extends State<_SeismicNavDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050709),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '── THE SEISMIC ──',
              style: TextStyle(
                fontFamily: 'Courier',
                color: const Color(0xFFF26A1B),
                fontSize: 10,
                letterSpacing: 5,
              ),
            ),
            const SizedBox(height: 48),
            CustomNavBar(
              currentIndex: _index,
              onHomeTap: () => setState(() => _index = 0),
              onAboutTap: () => setState(() => _index = 1),
              onProjectsTap: () => setState(() => _index = 2),
              onSkillsTap: () => setState(() => _index = 3),
              onExperienceTap: () => setState(() => _index = 4),
              onContactTap: () => setState(() => _index = 5),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: _SeismicNavDemo(),
));