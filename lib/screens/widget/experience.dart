import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';

class ExperienceSection extends StatefulWidget {
  final double screenWidth;
  const ExperienceSection({super.key, required this.screenWidth});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  
  // 3D Tilt Variables
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Continuous smooth pulse for the timeline dot
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Calculates the tilt based on mouse position relative to the center of the card
  void _onHover(PointerHoverEvent event, BoxConstraints constraints) {
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;
    
    setState(() {
      // Normalize values between -1 and 1, then scale down for a subtle tilt
      _tiltX = ((event.localPosition.dx - centerX) / centerX) * 0.15;
      _tiltY = ((event.localPosition.dy - centerY) / centerY) * 0.15;
    });
  }

  void _onExit(PointerExitEvent event) {
    setState(() {
      _isHovered = false;
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = widget.screenWidth <= 800;

    return Container(
      color: const Color(0xFF111111), // Deep dark background to make the glow pop
      padding: EdgeInsets.symmetric(
        vertical: 120,
        horizontal: widget.screenWidth > 900 ? widget.screenWidth * 0.1 : 20,
      ),
      child: Column(
        children: [
          // STYLISH TITLE
          const Text(
            "EXPERIENCE",
            style: TextStyle(
              fontSize: 50,
              fontFamily: 'gondens',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 20,
            ),
          ),
          const SizedBox(height: 80),

          // 3D GLASS CARD CONTAINER
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return MouseRegion(
                    onEnter: (_) => setState(() => _isHovered = true),
                    onHover: (e) => _onHover(e, constraints),
                    onExit: _onExit,
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      // Animate the matrix transform for smooth return to center
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        final matrix = Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Adds 3D perspective
                          ..rotateX(-_tiltY) // Tilt Up/Down
                          ..rotateY(_tiltX); // Tilt Left/Right

                        return Transform(
                          transform: matrix,
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 1. AMBIENT GLOWING ORB (Behind the glass)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                left: _isHovered ? constraints.maxWidth * 0.4 : constraints.maxWidth * 0.2,
                                top: _isHovered ? 50 : 0,
                                child: Container(
                                  width: 300,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF26A1B).withOpacity(0.4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF26A1B).withOpacity(0.5),
                                        blurRadius: 100,
                                        spreadRadius: 50,
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              // 2. THE FROSTED GLASS PANE
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                  child: Container(
                                    padding: EdgeInsets.all(isMobile ? 30 : 60),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.03),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1.5,
                                      ),
                                      // Subtle internal glow
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.1),
                                          Colors.white.withOpacity(0.01),
                                        ],
                                      ),
                                    ),
                                    child: _buildCardContent(isMobile),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The actual text and layout inside the glass card
  Widget _buildCardContent(bool isMobile) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // MASSIVE BACKGROUND WATERMARK
        Positioned(
          right: -20,
          top: -40,
          child: Text(
            "01",
            style: TextStyle(
              fontSize: 250,
              fontFamily: 'gondens',
              fontWeight: FontWeight.bold,
              height: 1,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2
                ..color = Colors.white.withOpacity(0.05),
            ),
          ),
        ),

        // FOREGROUND CONTENT
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Status Indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF26A1B),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF26A1B).withOpacity(0.8 * _pulseController.value),
                            blurRadius: 15 * _pulseController.value,
                            spreadRadius: 4 * _pulseController.value,
                          )
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Text(
                    "2025 - PRESENT",
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 50),

            // Role Title
            Text(
              "UI/UX & Frontend\nDeveloper.",
              style: TextStyle(
                fontSize: isMobile ? 40 : 64,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Company Name
            Row(
              children: [
                const Icon(Icons.arrow_forward_rounded, color: Color(0xFFF26A1B), size: 24),
                const SizedBox(width: 12),
                Text(
                  "Your Company Name", // <-- Update this
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),

            // Description Box
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: const Color(0xFFF26A1B), width: 3)),
              ),
              child: Text(
                "Designing intuitive, user-centric interfaces and translating them into responsive, high-performance applications. Bridging the gap between pure aesthetics and strict engineering.",
                style: TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}