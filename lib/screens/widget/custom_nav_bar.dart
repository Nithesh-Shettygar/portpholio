import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                            T H E   S E I S M I C                           ║
// ║              Ultra-thin vertical — wave behind centered icons              ║
// ╚══════════════════════════════════════════════════════════════════════════╝

const _kCyan    = Color(0xFFF26A1B);
const _kCyanDim = Color(0xFFFFBA92);
const _kBg      = Color(0xFF070A10);

// ───────────────────────────────────────────────────────────────────────────
//  PUBLIC WIDGET
// ───────────────────────────────────────────────────────────────────────────
class CustomNavBar extends StatefulWidget {
  final int currentIndex;
  final VoidCallback onHomeTap;
  final VoidCallback onAboutTap;
  final VoidCallback onProjectsTap;
  final VoidCallback onSkillsTap;
  final VoidCallback onExperienceTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onPlayTap;
  final VoidCallback onContactTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onHomeTap,
    required this.onAboutTap,
    required this.onProjectsTap,
    required this.onSkillsTap,
    required this.onExperienceTap,
    required this.onGalleryTap,
    required this.onPlayTap,
    required this.onContactTap,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _phaseCtrl;
  late AnimationController _burstCtrl;
  late List<AnimationController> _ampCtrls;
  late List<Animation<double>> _ampAnims;

  int _burstIndex = -1;
  int _hoveredIndex = -1;

  static const _total = 8;

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

    _ampCtrls[widget.currentIndex].value = 1.0;
  }

  @override
  void didUpdateWidget(CustomNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
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
        widget.onGalleryTap,
        widget.onPlayTap,
        widget.onContactTap,
      ];

  static const _icons = [
    Icons.home_rounded,
    Icons.person_rounded,
    Icons.grid_view_rounded,
    Icons.bolt_rounded,
    Icons.work_rounded,
    Icons.photo_library_rounded,
    Icons.videogame_asset_rounded,
    Icons.mail_rounded,
  ];

  void _onItemTap(int i) => _cbs[i]();

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
      animation: Listenable.merge([_phaseCtrl, _burstCtrl, ..._ampAnims]),
      builder: (context, _) {
        final amps = List.generate(_total, (i) => _ampAnims[i].value);

        return Container(
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(32),
          ),
          child: ClipRRect(
            // borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                width: 30,          // ← ultra-thin
                decoration: BoxDecoration(
                  color: Colors.black,
                  // borderRadius: BorderRadius.circular(32),
                  border: const Border(
                    left: BorderSide(color: Colors.white, width: 1),
                    right: BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                child: CustomPaint(
                  painter: _SeismicPainter(
                    phase: _phaseCtrl.value * 2 * math.pi,
                    amplitudes: amps,
                    burstProgress: _burstCtrl.value,
                    burstIndex: _burstIndex,
                    totalItems: _total,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_total * 2 - 1, (i) {
                        if (i.isOdd) {
                          return const SizedBox(height: 16);
                        }
                        final itemIndex = i ~/ 2;
                        return _SeismicItem(
                          icon: _icons[itemIndex],
                          isSelected: widget.currentIndex == itemIndex,
                          isHovered: _hoveredIndex == itemIndex,
                          ampValue: amps[itemIndex],
                          onTap: () => _onItemTap(itemIndex),
                          onHover: (h) => _onHover(itemIndex, h),
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
//  SEISMIC PAINTER  — vertical wave through centre of the bar
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
    const maxAmp  = 9.0;
    const steps   = 600;

    // The wave spine runs down the horizontal centre of the bar
    final double baseX = size.width * 0.5;
    final double ih    = size.height / totalItems;

    // ── Build vertical wave path ──────────────────────────────────────────
    final path = Path();
    for (int s = 0; s <= steps; s++) {
      final t = s / steps;
      final y = t * size.height;
      double dx = 0;

      for (int i = 0; i < totalItems; i++) {
        final amp = amplitudes[i];
        if (amp < 0.005) continue;
        final cy    = (i + 0.5) * ih;
        final sigma = ih * 0.38;
        final norm  = (y - cy) / sigma;
        final gauss = math.exp(-norm * norm * 0.5);
        final wavePhase = phase + (y - cy) / ih * 2.0 * math.pi;
        dx -= amp * maxAmp * gauss * math.sin(wavePhase);
      }

      // Burst ripple
      if (burstIndex >= 0 && burstProgress > 0 && burstProgress < 1.0) {
        final cy    = (burstIndex + 0.5) * ih;
        final sigma = ih * 0.30;
        final norm  = (y - cy) / sigma;
        final spike = math.exp(-norm * norm * 1.2);
        final decay  = math.pow(1 - burstProgress, 1.8).toDouble();
        final ripple = math.sin(phase * 5 + (y - cy) / ih * 10 * math.pi);
        dx -= decay * 16 * spike * ripple;
      }

      final x = baseX + dx;
      s == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }

    // ── Outer glow ────────────────────────────────────────────────────────
    canvas.drawPath(
      path,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color       = _kCyan.withOpacity(0.10)
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // ── Mid glow ──────────────────────────────────────────────────────────
    canvas.drawPath(
      path,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color       = _kCyan.withOpacity(0.32)
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // ── Core line (gradient top → bottom) ────────────────────────────────
    canvas.drawPath(
      path,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader      = ui.Gradient.linear(
          Offset(baseX, 0),
          Offset(baseX, size.height),
          [
            _kCyan.withOpacity(0.20),
            _kCyan.withOpacity(1.0),
            _kCyanDim.withOpacity(0.80),
            _kCyan.withOpacity(1.0),
            _kCyan.withOpacity(0.20),
          ],
          [0.0, 0.2, 0.5, 0.8, 1.0],
        ),
    );

    // ── Burst particles ───────────────────────────────────────────────────
    if (burstIndex >= 0 && burstProgress > 0.0 && burstProgress < 1.0) {
      final cx  = baseX;
      final cy  = (burstIndex + 0.5) * ih;
      final rng = math.Random(burstIndex * 13 + 77);
      const numP = 12;

      for (int p = 0; p < numP; p++) {
        final angle   = p * (2 * math.pi / numP) + rng.nextDouble() * 0.5;
        final speed   = 18.0 + rng.nextDouble() * 18.0;
        final ease    = _easeOutCubic(burstProgress);
        final px      = cx + math.cos(angle) * speed * ease;
        final py      = cy + math.sin(angle) * speed * ease;
        final opacity = math.pow(1 - burstProgress, 1.4).toDouble() * 0.85;
        final radius  = 2.2 * (1 - burstProgress * 0.6);

        canvas.drawCircle(
          Offset(px, py),
          radius,
          Paint()
            ..color      = _kCyan.withOpacity(opacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
        );
      }

      // Shockwave ring
      final ringR       = _easeOutCubic(burstProgress) * ih * 0.45;
      final ringOpacity = math.pow(1 - burstProgress, 2.0).toDouble() * 0.5;
      canvas.drawCircle(
        Offset(cx, cy),
        ringR,
        Paint()
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color       = _kCyan.withOpacity(ringOpacity),
      );

      // Central flash
      final flashOpacity = math.max(0.0, 0.55 - burstProgress * 1.0);
      if (flashOpacity > 0) {
        canvas.drawCircle(
          Offset(cx, cy),
          13 * burstProgress,
          Paint()
            ..color      = Colors.white.withOpacity(flashOpacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
        );
      }
    }

    // ── Subtle CRT scanlines along the wave strip ─────────────────────────
    final scanPaint = Paint()
      ..color       = Colors.white.withOpacity(0.016)
      ..strokeWidth = 0.5;
    for (double sx = baseX - 16; sx < size.width; sx += 3) {
      canvas.drawLine(Offset(sx, 0), Offset(sx, size.height), scanPaint);
    }
  }

  static double _easeOutCubic(double t) =>
      1 - math.pow(1 - t, 3).toDouble();

  @override
  bool shouldRepaint(_SeismicPainter old) => true;
}

// ───────────────────────────────────────────────────────────────────────────
//  SEISMIC ITEM  — icon only, centred in the thin bar
// ───────────────────────────────────────────────────────────────────────────
class _SeismicItem extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final bool isHovered;
  final double ampValue;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  const _SeismicItem({
    required this.icon,
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
  late Animation<double>    _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amp = widget.ampValue;
    final iconColor = widget.isSelected ? _kCyan : Colors.white;

    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit:  (_) => widget.onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown:  (_) => _pressCtrl.forward(),
        onTapUp:    (_) { _pressCtrl.reverse(); widget.onTap(); },
        onTapCancel: () => _pressCtrl.reverse(),
        child: AnimatedBuilder(
          animation: _pressAnim,
          builder: (context, _) {
            return Transform.scale(
              scale: _pressAnim.value,
              child: SizedBox(
                width: 30,
                height: 80,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutBack,
                    transform: amp > 0.05
                        ? (Matrix4.identity()..translate(-2.5 * amp, 0.0))
                        : Matrix4.identity(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft halo
                        if (amp > 0.05)
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _kCyan.withOpacity(amp * 0.28),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        Icon(widget.icon, color: iconColor, size: 18),
                      ],
                    ),
                  ),
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
//  DEMO
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
      body: Row(
        children: [
          // ── The navbar on the left ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
            child: CustomNavBar(
              currentIndex: _index,
              onHomeTap:         () => setState(() => _index = 0),
              onAboutTap:        () => setState(() => _index = 1),
              onProjectsTap:     () => setState(() => _index = 2),
              onSkillsTap:       () => setState(() => _index = 3),
              onExperienceTap:   () => setState(() => _index = 4),
              onContactTap:      () => setState(() => _index = 5), onGalleryTap: () {  }, onPlayTap: () {  },
            ),
          ),

          // ── Page content ───────────────────────────────────────────────
          Expanded(
            child: Center(
              child: Text(
                ['Home', 'About', 'Projects', 'Skills', 'Experience', 'Contact'][_index],
                style: const TextStyle(
                  fontFamily: 'Courier',
                  color: Color(0xFFF26A1B),
                  fontSize: 11,
                  letterSpacing: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: _SeismicNavDemo(),
));