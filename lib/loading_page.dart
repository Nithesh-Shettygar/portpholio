import 'package:flutter/material.dart';
// Make sure this points to your actual LandingPage file
import 'package:nithesh/screens/home_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with TickerProviderStateMixin {
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
  
  // Refined Color Palette
  static const Color _kOrange = Color(0xFFFF5E00);
  static const Color _kDarkFill = Color(0xFF111111); // Deep richer black for the text fill

  @override
  void initState() {
    super.initState();

    // ── Master timeline: 4.2 s (Slightly longer for a more cinematic feel) ──
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..forward();

    // ── Slow pulse (looping) for a breathing glow ───────────────────────────
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // ── Staggered letter reveals (0 – 30 % of timeline) ────────────────────
    _letterOpacities = [];
    _letterSlides = [];
    for (int i = 0; i < _kLetterCount; i++) {
      // Tighter stagger interval
      final start = (i / _kLetterCount) * 0.20; 
      final end = start + 0.15;
      
      _letterOpacities.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _masterController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
      
      _letterSlides.add(
        Tween<double>(begin: 50.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _masterController,
            curve: Interval(start, end, curve: Curves.easeOutExpo), // Snappier drop
          ),
        ),
      );
    }

    // ── Shader sweep (35 – 90 %) ────────────────────────────────────────────
    _sweepAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.35, 0.90, curve: Curves.easeInOutCubic),
      ),
    );

    // ── Progress bar / percentage (10 – 95 %) ───────────────────────────────
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        // Easing mimics real-world loading (fast start, slow middle, fast end)
        curve: const Interval(0.10, 0.95, curve: Curves.easeInOutQuart), 
      ),
    );

    // ── Background rings (0 – 100 %) ───────────────────────────────────────
    _ringAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutQuart),
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
            transitionDuration: const Duration(milliseconds: 1000), // Smoother fade out
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
      backgroundColor: _kOrange,
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

          // 2. Corner brackets & HUD Elements
          AnimatedBuilder(
            animation: _masterController,
            builder: (_, __) {
              final t = (_masterController.value * 5.0).clamp(0.0, 1.0);
              return Opacity(
                opacity: t,
                child: Stack(children: [
                  const Positioned(
                    top: 40,
                    left: 40,
                    child: _CornerBracket(flip: false),
                  ),
                  const Positioned(
                    bottom: 40,
                    right: 40,
                    child: _CornerBracket(flip: true),
                  ),
                  Positioned(
                    top: 44,
                    right: 44,
                    child: Text(
                      'v2.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 10,
                        fontFamily: 'Courier',
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 44,
                    left: 44,
                    child: Text(
                      'PORTFOLIO INIT',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 9,
                        fontFamily: 'Courier',
                        letterSpacing: 4,
                        fontWeight: FontWeight.w700,
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
                const SizedBox(height: 60),
                _buildProgressBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Letter row ──────────────────────────────────────────────────────────────

  // ── Letter row ──────────────────────────────────────────────────────────────

  Widget _buildLetterRow() {
    return AnimatedBuilder(
      animation: Listenable.merge([_masterController, _pulseController]),
      builder: (_, __) {
        return Transform.scale(
          scale: _pulseAnim.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0), 
            child: FittedBox( 
              fit: BoxFit.scaleDown,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  final sweep = _sweepAnim.value;
                  if (sweep < 0.001) {
                    return const LinearGradient(
                      colors: [Colors.white, Colors.white],
                    ).createShader(bounds);
                  }
                  
                  final safeSweep = sweep.clamp(0.0, 1.0);
                  
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      _kDarkFill, 
                      _kDarkFill,
                      Colors.white, 
                      Colors.white,
                    ],
                    stops: [
                      0.0,
                      safeSweep,
                      safeSweep, 
                      1.0,
                    ],
                  ).createShader(bounds);
                },
                // THE FIX: Massive vertical padding expands the ShaderMask bounds
                // so the text doesn't escape the gradient when it bounces!
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0), 
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
                              fontSize: 140, 
                              letterSpacing: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0, // Normalizes custom font heights
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
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
          width: 240, // Slightly wider for elegance
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LOADING ASSETS',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Courier',
                      fontSize: 9,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(pct * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Courier',
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Track
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Stack(
                  children: [
                    // Base empty track
                    Container(
                      height: 2,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    // Filled track with subtle glow
                    FractionallySizedBox(
                      widthFactor: pct,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.8),
                              blurRadius: 8,
                              spreadRadius: 1,
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
        size: const Size(24, 24),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.0
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
    final maxR = size.longestSide * 0.9; // Ensures rings span the whole screen

    // Subtle grid, dynamically spaced based on screen width
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;
    final double step = size.width > 600 ? 80.0 : 50.0;
    
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Expanding concentric rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final radii = [0.15, 0.35, 0.60, 0.85];
    for (int i = 0; i < radii.length; i++) {
      final delay = (i * 0.15).clamp(0.0, 1.0);
      final t = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final radius = maxR * radii[i] * t;
      // Fades out as it expands outward
      final opacity = (0.15 * (1.0 - t * 0.7)).clamp(0.0, 1.0);
      ringPaint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(cx, cy), radius, ringPaint);
    }

    // Small center dot expanding
    canvas.drawCircle(
      Offset(cx, cy),
      3.0 * progress,
      Paint()..color = Colors.white.withOpacity(0.30 * progress),
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => old.progress != progress;
}