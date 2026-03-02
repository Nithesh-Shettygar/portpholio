import 'package:flutter/material.dart';
import 'package:nithesh/screens/home_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _pulseController;

  // Per-letter staggered animations
  late List<Animation<double>> _letterOpacities;
  late List<Animation<double>> _letterSlides;

  // Shader sweep (white → black fill)
  late Animation<double> _sweepAnim;

  // Progress bar + percentage counter
  late Animation<double> _progressAnim;

  // Background rings expand outward
  late Animation<double> _ringAnim;

  // Subtle scale breathe on the whole text block
  late Animation<double> _pulseAnim;

  static const String _kText = 'NITHESH';
  static const int _kLetterCount = 7;

  @override
  void initState() {
    super.initState();

    // ── Master timeline: 3.8 s ──────────────────────────────────────────────
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..forward();

    // ── Slow pulse (looping) for a breathing glow ───────────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ── Staggered letter reveals (0 – 38 % of timeline) ────────────────────
    _letterOpacities = [];
    _letterSlides = [];
    for (int i = 0; i < _kLetterCount; i++) {
      final start = (i / _kLetterCount) * 0.32;
      final end = start + 0.14;
      _letterOpacities.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _masterController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
      _letterSlides.add(
        Tween<double>(begin: 40.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _masterController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
    }

    // ── Shader sweep (40 – 96 %) ────────────────────────────────────────────
    _sweepAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.40, 0.96, curve: Curves.easeInOut),
      ),
    );

    // ── Progress bar / percentage (0 – 95 %) ───────────────────────────────
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.95, curve: Curves.easeInOut),
      ),
    );

    // ── Background rings (0 – 100 %) ───────────────────────────────────────
    _ringAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Navigate away when done ─────────────────────────────────────────────
    _masterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LandingPage(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 900),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF5E00),
      body: Stack(
        children: [
          // 1. Background geometry
          AnimatedBuilder(
            animation: _ringAnim,
            builder: (_, __) => CustomPaint(
              painter: _BackgroundPainter(_ringAnim.value),
              child: const SizedBox.expand(),
            ),
          ),

          // 2. Corner brackets
          AnimatedBuilder(
            animation: _masterController,
            builder: (_, __) {
              final t = (_masterController.value * 4.0).clamp(0.0, 1.0);
              return Opacity(
                opacity: t,
                child: Stack(children: [
                  Positioned(
                    top: 44,
                    left: 44,
                    child: _CornerBracket(flip: false),
                  ),
                  Positioned(
                    bottom: 44,
                    right: 44,
                    child: _CornerBracket(flip: true),
                  ),
                  Positioned(
                    top: 44,
                    right: 44,
                    child: Text(
                      'v2.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.25),
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 48,
                    left: 44,
                    child: Text(
                      'PORTFOLIO',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.25),
                        fontSize: 9,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),

          // 3. Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLetterRow(),
                const SizedBox(height: 52),
                _buildProgressBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Letter row ──────────────────────────────────────────────────────────────

  Widget _buildLetterRow() {
    return AnimatedBuilder(
      animation: Listenable.merge([_masterController, _pulseController]),
      builder: (_, __) {
        return Transform.scale(
          scale: _pulseAnim.value,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              final sweep = _sweepAnim.value;
              if (sweep < 0.001) {
                return const LinearGradient(
                  colors: [Colors.white, Colors.white],
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
              }
              // Tight sweep edge for a crisp paint-fill look
              final edgeSoft = 0.04;
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [
                  Colors.white,
                  Colors.white,
                  Color(0xFF1C1C1C),
                  Color(0xFF1C1C1C),
                ],
                stops: [
                  0.0,
                  (sweep - edgeSoft).clamp(0.0, 1.0),
                  sweep.clamp(0.0, 1.0),
                  1.0,
                ],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_kLetterCount, (i) {
                return Transform.translate(
                  offset: Offset(0, _letterSlides[i].value),
                  child: Opacity(
                    opacity: _letterOpacities[i].value,
                    child: Text(
                      _kText[i],
                      style: const TextStyle(
                        fontFamily: 'gondens',
                        fontSize: 130,
                        letterSpacing: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  // ── Progress bar ────────────────────────────────────────────────────────────

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (_, __) {
        final pct = _progressAnim.value;
        return SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LOADING',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 9,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${(pct * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Track
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Stack(
                  children: [
                    Container(
                      height: 2,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    FractionallySizedBox(
                      widthFactor: pct,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.7),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Corner bracket widget ───────────────────────────────────────────────────

class _CornerBracket extends StatelessWidget {
  final bool flip;
  const _CornerBracket({required this.flip});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      scaleY: flip ? -1 : 1,
      child: CustomPaint(
        painter: _BracketPainter(),
        size: const Size(22, 22),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.40)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height)
        ..lineTo(0, 0)
        ..lineTo(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Background painter ──────────────────────────────────────────────────────

class _BackgroundPainter extends CustomPainter {
  final double progress;
  _BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.longestSide * 0.85;

    // Subtle grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5;
    const step = 56.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Expanding concentric rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final radii = [0.12, 0.30, 0.55, 0.80];
    for (int i = 0; i < radii.length; i++) {
      final delay = (i * 0.18).clamp(0.0, 1.0);
      final t = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final radius = maxR * radii[i] * t;
      final opacity = (0.12 * (1.0 - t * 0.5)).clamp(0.0, 1.0);
      ringPaint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(cx, cy), radius, ringPaint);
    }

    // Small center dot
    canvas.drawCircle(
      Offset(cx, cy),
      2.5 * progress,
      Paint()..color = Colors.white.withOpacity(0.20 * progress),
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => old.progress != progress;
}