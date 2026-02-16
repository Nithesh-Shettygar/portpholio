import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui'; // Required for lerpDouble

void main() {
  runApp(
    const MaterialApp(home: LandingPage(), debugShowCheckedModeBanner: false),
  );
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    double scrollProgress = (offset / screenHeight).clamp(0.0, 1.0);

    // --- MOVEMENT LOGIC ---
    // Horizontal: Start Center (0.0), end Right (0.8)
    double horizontalShift = 0.0 + (0.8 * scrollProgress);
    
    // Vertical: Start "Little Upper" (-0.3), end Center (0.0)
    double verticalShift = -0.2 + (0.3 * scrollProgress);
    
    // Rotation: 0 to 90 degrees
    double targetRotation = (math.pi / 2) * scrollProgress;

    // --- DYNAMIC SIZE LOGIC ---
    // Width starts at 200 in Section 1 and grows to 500 in Section 2
    double dynamicWidth = lerpDouble(200, 500, scrollProgress)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        children: [
          // 1. SCROLLABLE CONTENT LAYER
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // SECTION 1: Intro
              SliverToBoxAdapter(
                child: Container(
                  height: screenHeight,
                  width: double.infinity,
                  color: const Color(0xFFF2F2F2),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: (1 - scrollProgress).clamp(0.0, 1.0),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.asset(
                            'assets/images/nithesh.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 100,
                        child: Opacity(
                          opacity: (1 - scrollProgress * 2).clamp(0.0, 1.0),
                          child: const Text(
                            "Nithesh",
                            style: TextStyle(
                              fontSize: 24,
                              letterSpacing: 8,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // SECTION 2: Details
              SliverToBoxAdapter(
                child: Container(
                  height: screenHeight,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Opacity(
                          opacity: scrollProgress,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "90° Perspective",
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Engineering meets elegance. Our frames are designed to look stunning from every angle.",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(flex: 2, child: SizedBox()),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 200)),
            ],
          ),

          // 2. FLOATING GLASSES LAYER (Dynamic Size & Position)
          IgnorePointer(
            child: Align(
              alignment: Alignment(horizontalShift, verticalShift),
              child: SizedBox(
                width: dynamicWidth, // Transitions from 200 to 500
                child: HeroSpecsImage(
                  rotation: targetRotation,
                  scale: 1.0, // Scale is handled by the dynamicWidth now
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeroSpecsImage extends StatelessWidget {
  final double rotation;
  final double scale;
  const HeroSpecsImage({
    super.key,
    required this.rotation,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        decoration: BoxDecoration(
         
        ),
        child: Image.asset(
          'assets/images/glass.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.call_end, size: 100, color: Colors.black26),
        ),
      ),
    );
  }
}