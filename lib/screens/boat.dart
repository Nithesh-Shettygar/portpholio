// hackfest_timeline.dart
// Flutter implementation of Hackfest '26 Timeline — Ocean Sailing Experience
// Requires: flutter/material.dart (no external packages)
// Add to pubspec.yaml:
//   google_fonts: ^6.1.0   (optional — fallback to serif if absent)
//
// Run: flutter run -t lib/hackfest_timeline.dart

import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const HackfestApp());
}

// ──────────────────────────────────────────────────────────── palette
class C {
  static const bg = Color(0xFF04090F);
  static const ocean = Color(0xFF041828);
  static const amber = Color(0xFFF59E0B);
  static const amberDim = Color(0xFFB45309);
  static const amberPale = Color(0xFFF8F1E0);
  static const border = Color(0xFF8B4513);
  static const borderDim = Color(0xFF3D1F09);
  static const text = Color(0xFFE8D5B0);
  static const textDim = Color(0xFF9A7C58);
  static const surface = Color(0xFF0D1520);
  static const moonGlow = Color(0xFF4477BB);
  static const wakeBlue = Color(0xFF5599CC);
}

// ──────────────────────────────────────────────────────────── event data
class HackEvent {
  final String time, title, desc, icon, badge, badgeType;
  const HackEvent({
    required this.time,
    required this.title,
    required this.desc,
    required this.icon,
    required this.badge,
    required this.badgeType, // 'amber'|'red'|'green'|'blue'
  });
}

const events = [
  HackEvent(time: "09:00 AM", title: "Gates Open",       desc: "Check in, collect your hacker kit and get settled in.",          icon: "🚢", badge: "Registration", badgeType: "green"),
  HackEvent(time: "10:30 AM", title: "Inauguration",     desc: "Welcome address and keynote from industry leaders.",             icon: "🎯", badge: "Keynote",       badgeType: "amber"),
  HackEvent(time: "11:00 AM", title: "Hacking Begins",   desc: "36-hour clock starts. Problem statements revealed. Code flows.", icon: "⚡", badge: "Live",          badgeType: "red"),
  HackEvent(time: "01:00 PM", title: "Lunch Break",      desc: "Recharge over a catered lunch with fellow hackers.",            icon: "🍖", badge: "Break",         badgeType: "green"),
  HackEvent(time: "04:00 PM", title: "Workshop #1",      desc: "Hands-on: cloud, AI integrations, rapid prototyping.",          icon: "🔧", badge: "Workshop",      badgeType: "blue"),
  HackEvent(time: "08:00 PM", title: "Mentor Rounds",    desc: "One-on-one with industry mentors. Get direction.",              icon: "🧭", badge: "Mentorship",    badgeType: "amber"),
  HackEvent(time: "10:00 PM", title: "Night Fuel",       desc: "Dinner served. Snacks and energy drinks all night.",            icon: "🌙", badge: "Break",         badgeType: "green"),
  HackEvent(time: "07:00 AM", title: "Morning Recharge", desc: "Rise and shine. Breakfast served. Day 2 begins.",              icon: "🌅", badge: "Day 2",          badgeType: "amber"),
  HackEvent(time: "09:00 AM", title: "Workshop #2",      desc: "Advanced demos and showcases from sponsor companies.",          icon: "💡", badge: "Workshop",      badgeType: "blue"),
  HackEvent(time: "11:00 AM", title: "Project Freeze",   desc: "All submissions locked in. Final presentations begin.",        icon: "🔒", badge: "Deadline",      badgeType: "red"),
  HackEvent(time: "12:00 PM", title: "Judging Rounds",   desc: "Present your project to the panel. Make every second count.", icon: "⚖️", badge: "Judging",       badgeType: "amber"),
  HackEvent(time: "03:00 PM", title: "Prize Distribution", desc: "Winners announced. 36 extraordinary hours complete.",        icon: "🏆", badge: "Ceremony",      badgeType: "amber"),
];

// ──────────────────────────────────────────────────────────── app root
class HackfestApp extends StatelessWidget {
  const HackfestApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "Hackfest '26",
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const TimelinePage(),
      );
}

// ──────────────────────────────────────────────────────────── main page
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});
  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage>
    with TickerProviderStateMixin {
  // scroll progress 0→1
  double _progress = 0;
  double _targetProgress = 0;

  // which island popup is visible (-1 = none)
  int _popupIndex = -1;
  bool _popupVisible = false;
  bool _paused = false; // ship pauses near island

  // visited set
  final Set<int> _visited = {};

  // toggle 3D / 2D
  bool _is3D = true;

  // animation controllers
  late final AnimationController _waveCtrl;
  late final AnimationController _shipCtrl;
  late final AnimationController _progressCtrl;
  late final AnimationController _popupCtrl;
  late final AnimationController _beaconCtrl;
  late final AnimationController _hintCtrl;

  // smooth ship progress (lerped)
  double _smoothProgress = 0;

  // drag tracking
  double? _dragStartY;
  double _dragStartProgress = 0;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _shipCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _beaconCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _hintCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _popupCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 16));

    // tick: lerp smoothProgress toward _targetProgress
    _waveCtrl.addListener(_tick);
  }

  void _tick() {
    if (!mounted) return;
    if (!_paused) {
      final diff = _targetProgress - _smoothProgress;
      if (diff.abs() > 0.0001) {
        _smoothProgress += diff * 0.055;
        _checkIslandProximity();
      }
    }
    if (mounted) setState(() {});
  }

  void _checkIslandProximity() {
    for (int i = 0; i < events.length; i++) {
      final islandT = (i + 0.5) / events.length;
      final dist = (_smoothProgress - islandT).abs();
      if (dist < 0.012 && !_visited.contains(i) && !_paused) {
        _visited.add(i);
        _pauseAndShowPopup(i);
        break;
      }
    }
  }

  Future<void> _pauseAndShowPopup(int idx) async {
    setState(() {
      _paused = true;
      _popupIndex = idx;
      _popupVisible = true;
      _targetProgress = _smoothProgress; // freeze scroll
    });
    await _popupCtrl.forward(from: 0);
  }

  void _closePopup() {
    _popupCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _popupVisible = false;
        _paused = false;
      });
    });
  }

  void _onScroll(double delta) {
    if (_paused) return;
    _targetProgress = (_targetProgress + delta).clamp(0.0, 1.0);
    // auto-close popup when scrolling forward
    if (_popupVisible) _closePopup();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _shipCtrl.dispose();
    _beaconCtrl.dispose();
    _hintCtrl.dispose();
    _popupCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(
        children: [
          // ── OCEAN / 3D view ──────────────────────────────────
          if (_is3D)
            GestureDetector(
              onVerticalDragStart: (d) {
                _dragStartY = d.localPosition.dy;
                _dragStartProgress = _targetProgress;
              },
              onVerticalDragUpdate: (d) {
                if (_dragStartY == null) return;
                final dy = d.localPosition.dy - _dragStartY!;
                _onScroll(-dy * 0.0018);
              },
              onVerticalDragEnd: (_) => _dragStartY = null,
              child: Listener(
                onPointerSignal: (e) {
                  if (e is PointerScrollEvent) _onScroll(e.scrollDelta.dy * 0.0006);
                },
                behavior: HitTestBehavior.opaque,
                child: _OceanScene(
                  progress: _smoothProgress,
                  waveAnim: _waveCtrl,
                  shipAnim: _shipCtrl,
                  beaconAnim: _beaconCtrl,
                  visited: _visited,
                  events: events,
                ),
              ),
            ),

          // ── 2D timeline ──────────────────────────────────────
          if (!_is3D)
            const _TimelineView(),

          // ── top nav ─────────────────────────────────────────
          _TopNav(
            is3D: _is3D,
            onToggle: () => setState(() {
              _is3D = !_is3D;
              if (_popupVisible) _closePopup();
            }),
          ),

          // ── hint ────────────────────────────────────────────
          if (_is3D && _smoothProgress < 0.03)
            _ScrollHint(anim: _hintCtrl),

          // ── progress bar ─────────────────────────────────────
          if (_is3D)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _ProgressBar(progress: _smoothProgress),
            ),

          // ── island counter ───────────────────────────────────
          if (_is3D)
            Positioned(
              bottom: 16, right: 18,
              child: Text(
                "Island ${((_smoothProgress * events.length).clamp(1, events.length)).floor()} / ${events.length}",
                style: const TextStyle(
                  color: C.textDim,
                  fontSize: 13,
                  fontFamily: 'serif',
                  letterSpacing: 1.2,
                ),
              ),
            ),

          // ── popup overlay ────────────────────────────────────
          if (_popupVisible && _popupIndex >= 0)
            _EventPopup(
              event: events[_popupIndex],
              animation: _popupCtrl,
              onClose: _closePopup,
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────── ocean scene
class _OceanScene extends StatelessWidget {
  final double progress;
  final Animation<double> waveAnim, shipAnim, beaconAnim;
  final Set<int> visited;
  final List<HackEvent> events;

  const _OceanScene({
    required this.progress,
    required this.waveAnim,
    required this.shipAnim,
    required this.beaconAnim,
    required this.visited,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([waveAnim, shipAnim, beaconAnim]),
      builder: (_, __) => CustomPaint(
        size: Size.infinite,
        painter: _OceanPainter(
          progress: progress,
          t: waveAnim.value,
          st: shipAnim.value,
          bt: beaconAnim.value,
          visited: visited,
          events: events,
        ),
      ),
    );
  }
}

class _OceanPainter extends CustomPainter {
  final double progress, t, st, bt;
  final Set<int> visited;
  final List<HackEvent> events;
  final _rand = math.Random(42);

  _OceanPainter({
    required this.progress,
    required this.t,
    required this.st,
    required this.bt,
    required this.visited,
    required this.events,
  });

  // S-curve path: x oscillates, y goes top→bottom based on progress
  Offset _pathAt(double p, Size sz) {
    final clampedP = p.clamp(0.0, 1.0);
    final x = sz.width / 2 + math.sin(clampedP * math.pi * 2.5) * sz.width * 0.22;
    final y = sz.height * 0.1 + clampedP * sz.height * 0.8;
    return Offset(x, y);
  }

  Offset _tangentAt(double p, Size sz) {
    final a = _pathAt(p - 0.005, sz);
    final b = _pathAt(p + 0.005, sz);
    final dx = b.dx - a.dx, dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    return Offset(dx / len, dy / len);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawStars(canvas, size);
    _drawMoon(canvas, size);
    _drawOcean(canvas, size);
    _drawPathDashes(canvas, size);
    _drawIslands(canvas, size);
    _drawShip(canvas, size);
    _drawWake(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF020A14), Color(0xFF041828), Color(0xFF030D1A)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  final _starRects = <Rect>[];
  void _drawStars(Canvas canvas, Size size) {
    if (_starRects.isEmpty) {
      final rng = math.Random(99);
      for (int i = 0; i < 200; i++) {
        _starRects.add(Rect.fromCircle(
          center: Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height * 0.5),
          radius: rng.nextDouble() * 1.2 + 0.3,
        ));
      }
    }
    final paint = Paint()
      ..color = const Color(0xFFFFF8E0).withOpacity(0.7 + math.sin(t * math.pi * 2) * 0.15);
    for (final r in _starRects) canvas.drawOval(r, paint);
  }

  void _drawMoon(Canvas canvas, Size size) {
    final cx = size.width * 0.12, cy = size.height * 0.1;
    // glow
    canvas.drawCircle(Offset(cx, cy), 22,
        Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
          ..color = const Color(0xFFF0CC44).withOpacity(0.25));
    canvas.drawCircle(Offset(cx, cy), 14, Paint()..color = const Color(0xFFEEEEBB));
    canvas.drawCircle(Offset(cx, cy), 14,
        Paint()..color = const Color(0xFFFFFFDD).withOpacity(0.4));
  }

  void _drawOcean(Canvas canvas, Size size) {
    final waveHeight = size.height * 0.52;
    final path = Path();
    path.moveTo(0, waveHeight);

    for (double x = 0; x <= size.width; x += 4) {
      final wave = math.sin(x * 0.015 + t * math.pi * 2) * 8 +
          math.sin(x * 0.023 + t * math.pi * 2 * 1.3 + 1.2) * 5;
      path.lineTo(x, waveHeight + wave);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF062035), Color(0xFF020C16)],
        ).createShader(Rect.fromLTWH(0, waveHeight, size.width, size.height - waveHeight)),
    );

    // shimmer lines
    final shimmerPaint = Paint()
      ..color = const Color(0xFF1A4A7A).withOpacity(0.35)
      ..strokeWidth = 1.2;
    for (double x = -size.width; x < size.width * 2; x += 28) {
      final offset = (t * 80) % 28;
      final sx = x + offset;
      canvas.drawLine(Offset(sx, waveHeight + 6), Offset(sx + 14, waveHeight + 18), shimmerPaint);
    }
  }

  void _drawPathDashes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A4A6A).withOpacity(0.55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    bool first = true;
    for (int i = 0; i <= 200; i++) {
      final p = i / 200.0;
      final pos = _pathAt(p, size);
      if (first) { path.moveTo(pos.dx, pos.dy); first = false; }
      else path.lineTo(pos.dx, pos.dy);
    }
    canvas.drawPath(path,
        Paint()
          ..color = const Color(0xFF2A4A6A).withOpacity(0.3)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke);

    // draw dashes manually for dash effect
    const dashLen = 8.0, gapLen = 10.0;
    double accumulated = 0;
    bool drawing = true;
    for (int i = 1; i <= 200; i++) {
      final a = _pathAt((i - 1) / 200.0, size);
      final b = _pathAt(i / 200.0, size);
      final dx = b.dx - a.dx, dy = b.dy - a.dy;
      final segLen = math.sqrt(dx * dx + dy * dy);
      if (drawing && accumulated + segLen >= dashLen) {
        final f = (dashLen - accumulated) / segLen;
        if (drawing) {
          canvas.drawLine(a, Offset(a.dx + dx * f, a.dy + dy * f), paint);
        }
        accumulated = segLen * (1 - f);
        drawing = !drawing;
      } else {
        accumulated += segLen;
        if (drawing) canvas.drawLine(a, b, paint);
      }
      if (accumulated >= (drawing ? dashLen : gapLen)) {
        accumulated = 0;
        drawing = !drawing;
      }
    }
  }

  void _drawIslands(Canvas canvas, Size size) {
    for (int i = 0; i < events.length; i++) {
      final islandT = (i + 0.5) / events.length;
      final base = _pathAt(islandT, size);
      final side = (i % 2 == 0 ? 1 : -1) * (size.width * 0.14 + (i % 3) * 12);

      // scale: final island is bigger; near-ship islands pop
      final distToShip = (islandT - progress).abs();
      final proximity = (1 - distToShip / 0.12).clamp(0.0, 1.0);
      final isFinal = i == events.length - 1;
      final baseScale = isFinal ? 1.5 : 1.0;
      final scale = (baseScale + proximity * 0.22) *
          (size.width / 420).clamp(0.5, 1.5);

      final center = Offset(base.dx + side, base.dy);
      _drawIsland(canvas, center, scale, i, visited.contains(i));
    }
  }

  void _drawIsland(Canvas canvas, Offset center, double scale, int idx, bool wasVisited) {
    final s = scale;

    // rock shadow
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, 2 * s), width: 38 * s, height: 8 * s),
      Paint()..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // rock base
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 34 * s, height: 16 * s),
      Paint()..color = const Color(0xFF2A3020),
    );

    // sand dome
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, -6 * s), width: 28 * s, height: 16 * s),
      Paint()..color = const Color(0xFFC8A055),
    );

    // palm trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF4A2E10)
      ..strokeWidth = 3 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center.translate(3 * s, -10 * s),
      center.translate(5 * s, -24 * s),
      trunkPaint,
    );

    // leaves
    final leafPaint = Paint()..color = const Color(0xFF2D6E18);
    for (int l = 0; l < 6; l++) {
      final ang = (l / 6) * math.pi * 2;
      final tip = center.translate(
        5 * s + math.cos(ang) * 10 * s,
        -24 * s + math.sin(ang) * 5 * s - 2 * s,
      );
      canvas.drawLine(
        center.translate(5 * s, -24 * s),
        tip,
        Paint()
          ..color = const Color(0xFF2D6E18)
          ..strokeWidth = 2.5 * s
          ..strokeCap = StrokeCap.round,
      );
    }

    // beacon glow
    final beaconColor = wasVisited ? const Color(0xFF00FF88) : C.amber;
    final glowIntensity = 0.3 + bt * 0.7;
    canvas.drawCircle(
      center.translate(-8 * s, -26 * s),
      8 * s * glowIntensity,
      Paint()
        ..color = beaconColor.withOpacity(0.2 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      center.translate(-8 * s, -26 * s),
      3.5 * s,
      Paint()..color = beaconColor,
    );

    // island number badge
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${idx + 1}',
        style: TextStyle(
          color: C.amberPale,
          fontSize: 8 * s,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, center.translate(-textPainter.width / 2, 2 * s));
  }

  void _drawShip(Canvas canvas, Size size) {
    final shipPos = _pathAt(progress, size);
    final tang = _tangentAt(progress, size);
    final angle = math.atan2(tang.dx, -tang.dy);

    final bob = math.sin(st * math.pi * 2 * 0.75) * 3;
    final roll = math.sin(st * math.pi * 2 * 1.15) * 0.03;

    canvas.save();
    canvas.translate(shipPos.dx, shipPos.dy + bob);
    canvas.rotate(angle + roll);

    final sc = (size.width / 420).clamp(0.5, 1.4);
    canvas.scale(sc, sc);

    _drawShipSprite(canvas);
    canvas.restore();
  }

  void _drawShipSprite(Canvas canvas) {
    final darkWood = Paint()..color = const Color(0xFF2A1608);
    final lightWood = Paint()..color = const Color(0xFF5C3A1E);
    final sailPaint = Paint()
      ..color = const Color(0xFFECE0C4).withOpacity(0.92);
    final ropePaint = Paint()
      ..color = const Color(0xFF8A7450)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // hull
    final hull = Path()
      ..moveTo(-18, -4)
      ..cubicTo(-20, 0, -20, 8, -10, 10)
      ..lineTo(10, 10)
      ..cubicTo(20, 8, 20, 0, 18, -4)
      ..lineTo(14, -8)
      ..lineTo(-14, -8)
      ..close();
    canvas.drawPath(hull, darkWood);

    // deck
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-17, -10, 34, 5), const Radius.circular(2)),
      lightWood,
    );

    // cabin
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-8, -22, 16, 12), const Radius.circular(2)),
      darkWood,
    );

    // cabin windows (glowing)
    final winMat = Paint()
      ..color = const Color(0xFFFFCC44)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawRect(const Rect.fromLTWH(-7, -20, 4, 3), winMat);
    canvas.drawRect(const Rect.fromLTWH(3, -20, 4, 3), winMat);

    // main mast
    canvas.drawLine(const Offset(0, -10), const Offset(0, -55), ropePaint..strokeWidth = 2);
    // yard arm
    canvas.drawLine(const Offset(-18, -48), const Offset(18, -48), ropePaint..strokeWidth = 1.5);

    // main sail (billowing)
    final sailOff = math.sin(st * math.pi * 2 * 1.2) * 2;
    final sail = Path()
      ..moveTo(-16, -46)
      ..quadraticBezierTo(sailOff + 6, -34, -14, -22)
      ..lineTo(14, -22)
      ..quadraticBezierTo(sailOff + 6, -34, 16, -46)
      ..close();
    canvas.drawPath(sail, sailPaint);

    // top sail
    final topSail = Path()
      ..moveTo(-9, -53)
      ..quadraticBezierTo(sailOff * 0.5, -49, -8, -46)
      ..lineTo(8, -46)
      ..quadraticBezierTo(sailOff * 0.5, -49, 9, -53)
      ..close();
    canvas.drawPath(topSail, sailPaint);

    // fore mast
    canvas.drawLine(
      const Offset(-8, -8),
      const Offset(-20, -40),
      ropePaint..strokeWidth = 1.5,
    );

    // flag
    final flagPaint = Paint()..color = C.amber;
    final flagWave = math.sin(st * math.pi * 2 * 2.8) * 3;
    final flag = Path()
      ..moveTo(0, -55)
      ..lineTo(flagWave + 10, -52)
      ..lineTo(flagWave + 10, -58)
      ..close();
    canvas.drawPath(flag, flagPaint);

    // lantern glow at top
    canvas.drawCircle(
      const Offset(0, -55),
      4,
      Paint()
        ..color = const Color(0xFFFFAA00)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(const Offset(0, -55), 2, Paint()..color = const Color(0xFFFFCC44));

    // bow (figurehead)
    canvas.drawLine(
      const Offset(0, -10),
      const Offset(28, -16),
      ropePaint..strokeWidth = 2,
    );
  }

  void _drawWake(Canvas canvas, Size size) {
    final shipPos = _pathAt(progress, size);
    final tang = _tangentAt(progress, size);
    final back = Offset(-tang.dx, -tang.dy);

    for (int i = 1; i <= 6; i++) {
      final dist = i * 14.0;
      final spread = i * 5.0;
      final opacity = (1 - i / 7.0) * 0.45;
      final wakePos = shipPos + back * dist;

      final left = wakePos + Offset(-tang.dy, tang.dx) * spread;
      final right = wakePos + Offset(tang.dy, -tang.dx) * spread;

      canvas.drawLine(
        shipPos,
        left,
        Paint()
          ..color = C.wakeBlue.withOpacity(opacity)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        shipPos,
        right,
        Paint()
          ..color = C.wakeBlue.withOpacity(opacity)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_OceanPainter old) =>
      old.progress != progress || old.t != t || old.st != st || old.bt != bt;
}

// ──────────────────────────────────────────────────────────── top nav
class _TopNav extends StatelessWidget {
  final bool is3D;
  final VoidCallback onToggle;
  const _TopNav({required this.is3D, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // home button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A0D03),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: C.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black54, blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_rounded, color: C.amberPale, size: 16),
                    SizedBox(width: 6),
                    Text("Home",
                        style: TextStyle(
                          color: C.amberPale,
                          fontFamily: 'serif',
                          fontSize: 14,
                          letterSpacing: 0.5,
                        )),
                  ],
                ),
              ),

              // 3D/2D toggle
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 110, height: 40,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0D03),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: C.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black54, blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("3D",
                                style: TextStyle(
                                  color: is3D ? C.amberDim : C.borderDim,
                                  fontFamily: 'serif', fontSize: 13)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text("2D",
                                style: TextStyle(
                                  color: !is3D ? C.amberDim : C.borderDim,
                                  fontFamily: 'serif', fontSize: 13)),
                          ),
                        ],
                      ),
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        alignment: is3D ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          width: 50, height: 34,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFF8F1E0), Color(0xFFE0D0B0)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: C.border),
                            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                          ),
                          alignment: Alignment.center,
                          child: Text(is3D ? "3D" : "2D",
                              style: const TextStyle(
                                color: Color(0xFF2A1A0A),
                                fontFamily: 'serif',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────── scroll hint
class _ScrollHint extends StatelessWidget {
  final Animation<double> anim;
  const _ScrollHint({required this.anim});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 48, left: 0, right: 0,
      child: AnimatedBuilder(
        animation: anim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, -anim.value * 6),
          child: Column(
            children: [
              const Text(
                "SCROLL TO SAIL",
                style: TextStyle(
                  color: C.textDim,
                  fontSize: 11,
                  fontFamily: 'serif',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: C.textDim.withOpacity(0.7 + anim.value * 0.3), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────── progress bar
class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      color: C.borderDim,
      child: FractionallySizedBox(
        widthFactor: progress,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [C.amberDim, C.amber]),
            boxShadow: [BoxShadow(color: C.amber, blurRadius: 6)],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────── popup
class _EventPopup extends StatelessWidget {
  final HackEvent event;
  final Animation<double> animation;
  final VoidCallback onClose;

  const _EventPopup({
    required this.event,
    required this.animation,
    required this.onClose,
  });

  Color get _badgeColor => switch (event.badgeType) {
        'red' => const Color(0xFFF87171),
        'green' => const Color(0xFF4ADE80),
        'blue' => const Color(0xFF60A5FA),
        _ => C.amber,
      };

  Color get _badgeBg => switch (event.badgeType) {
        'red' => const Color(0x26DC2626),
        'green' => const Color(0x2622C55E),
        'blue' => const Color(0x263B82F6),
        _ => const Color(0x26F59E0B),
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) {
        final cv = CurvedAnimation(parent: animation, curve: Curves.easeOutBack).value;
        return Stack(
          children: [
            // backdrop
            Opacity(
              opacity: animation.value * 0.7,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  color: const Color(0xFF04090F),
                ),
              ),
            ),
            // card
            Center(
              child: Transform.scale(
                scale: 0.85 + cv * 0.15,
                child: Opacity(
                  opacity: animation.value,
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1A2E), Color(0xFF091320)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.border, width: 1.5),
          boxShadow: [
            BoxShadow(color: C.border.withOpacity(0.4), blurRadius: 40, spreadRadius: 2),
            const BoxShadow(color: Colors.black, blurRadius: 50, offset: Offset(0, 20)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // top amber line
              Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, C.amber, Colors.transparent],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                child: Column(
                  children: [
                    // icon
                    Text(event.icon,
                        style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 4),

                    // time
                    Text(
                      event.time.toUpperCase(),
                      style: const TextStyle(
                        color: C.amberDim,
                        fontSize: 11,
                        letterSpacing: 2.5,
                        fontFamily: 'serif',
                      ),
                    ),

                    // title
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: C.amber,
                        fontSize: 26,
                        fontFamily: 'serif',
                        letterSpacing: 0.5,
                        shadows: [Shadow(color: C.amber, blurRadius: 18)],
                      ),
                    ),

                    // desc
                    const SizedBox(height: 8),
                    Text(
                      event.desc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: C.textDim,
                        fontSize: 14,
                        fontFamily: 'serif',
                        height: 1.5,
                      ),
                    ),

                    // badge
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _badgeBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _badgeColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        event.badge.toUpperCase(),
                        style: TextStyle(
                          color: _badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // close button
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: C.borderDim.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: C.borderDim),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "CONTINUE SAILING  ⚓",
                          style: TextStyle(
                            color: C.textDim,
                            fontSize: 12,
                            fontFamily: 'serif',
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────── 2D timeline
class _TimelineView extends StatelessWidget {
  const _TimelineView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
        child: Column(
          children: [
            // header
            const Text(
              "Timeline",
              style: TextStyle(
                color: C.amber,
                fontSize: 52,
                fontFamily: 'serif',
                letterSpacing: 2,
                shadows: [Shadow(color: C.amber, blurRadius: 28)],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "HACKFEST '26 — 36 HOURS OF INNOVATION",
              style: TextStyle(color: C.textDim, fontSize: 12, letterSpacing: 2.5, fontFamily: 'serif'),
            ),

            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: Container(height: 1,
                  decoration: const BoxDecoration(gradient: LinearGradient(
                      colors: [Colors.transparent, C.amberDim])))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("⚓", style: TextStyle(color: C.amber, fontSize: 18)),
              ),
              Expanded(child: Container(height: 1,
                  decoration: const BoxDecoration(gradient: LinearGradient(
                      colors: [C.amberDim, Colors.transparent])))),
            ]),
            const SizedBox(height: 24),

            // Day 1 header
            _DaySeparator(label: "⚔  Day One"),

            // Day 1 events
            ...events.take(7).map((e) => _TLCard(event: e)),

            _DaySeparator(label: "🌅  Day Two"),

            // Day 2 events
            ...events.skip(7).map((e) => _TLCard(event: e)),
          ],
        ),
      ),
    );
  }
}

class _DaySeparator extends StatelessWidget {
  final String label;
  const _DaySeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: C.borderDim)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label,
                style: const TextStyle(
                  color: C.amberDim,
                  fontFamily: 'serif',
                  fontSize: 15,
                  letterSpacing: 1.5,
                )),
          ),
          Expanded(child: Container(height: 1, color: C.borderDim)),
        ],
      ),
    );
  }
}

class _TLCard extends StatefulWidget {
  final HackEvent event;
  const _TLCard({required this.event});
  @override
  State<_TLCard> createState() => _TLCardState();
}

class _TLCardState extends State<_TLCard> {
  bool _hovered = false;

  Color get _badgeColor => switch (widget.event.badgeType) {
        'red' => const Color(0xFFF87171),
        'green' => const Color(0xFF4ADE80),
        'blue' => const Color(0xFF60A5FA),
        _ => C.amber,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // dot and line
          Column(
            children: [
              const SizedBox(height: 14),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 12, height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hovered ? C.amber : C.surface,
                  border: Border.all(color: C.border, width: 2),
                  boxShadow: _hovered
                      ? [const BoxShadow(color: C.amber, blurRadius: 8)]
                      : [],
                ),
              ),
              Container(width: 2, height: 60, color: C.borderDim),
            ],
          ),
          const SizedBox(width: 16),

          // card
          Expanded(
            child: MouseRegion(
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(_hovered ? 4 : 0, 0, 0),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _hovered ? C.border : C.borderDim,
                    width: 1,
                  ),
                  boxShadow: _hovered
                      ? [BoxShadow(color: C.border.withOpacity(0.3), blurRadius: 16)]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_hovered)
                        Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, C.amberDim, Colors.transparent],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.event.time.toUpperCase()} — ${widget.event.badge.toUpperCase()}",
                              style: const TextStyle(
                                color: C.amberDim,
                                fontSize: 11,
                                letterSpacing: 1.8,
                                fontFamily: 'serif',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.event.title,
                              style: const TextStyle(
                                color: C.amberPale,
                                fontSize: 18,
                                fontFamily: 'serif',
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.event.desc,
                              style: const TextStyle(
                                color: C.textDim,
                                fontSize: 13,
                                fontFamily: 'serif',
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: _badgeColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _badgeColor.withOpacity(0.35)),
                              ),
                              child: Text(
                                widget.event.badge.toUpperCase(),
                                style: TextStyle(
                                  color: _badgeColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}