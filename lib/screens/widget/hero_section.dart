import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class HeroSection extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;

  const HeroSection({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final Color _bgColor = const Color(0xFFF2F2F2);

  @override
  void initState() {
    super.initState();

    // Controls the duration of one full up/down cycle
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Defines how many pixels the text will move up and down
    _floatAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = widget.screenWidth <= 800;
    double circle1Size = isMobile ? 120 : 200;
    double circle2Size = isMobile ? 160 : 280;
    double titleSize = isMobile ? 120 : 350;
    double letterSpacing = isMobile ? 8 : 30;

    return Container(
      height: widget.screenHeight,
      width: double.infinity,
      color: _bgColor,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // --- ORANGE CIRCLE 1 ---
              Positioned(
                top: widget.screenHeight * 0.15,
                left: isMobile ? -60 : -30,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: circle1Size,
                    height: circle1Size,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange,
                          spreadRadius: 10,
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- ORANGE CIRCLE 2 ---
              Positioned(
                bottom: widget.screenHeight * 0.1,
                right: isMobile ? -80 : -50,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: circle2Size,
                    height: circle2Size,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange,
                          spreadRadius: 50,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 1. TEXT + IMAGE COMPOSITION
              if (isMobile)
                Positioned(
                  top: widget.screenHeight * 0.1,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(0, _floatAnimation.value * 0.5),
                    child: Center(
                      child: Text(
                        'NITHESH',
                        style: TextStyle(
                          fontFamily: 'gondens',
                          fontSize: 86,
                          letterSpacing: 8,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Text(
                              'NITHESH',
                              style: TextStyle(
                                fontFamily: 'gondens',
                                fontSize: titleSize,
                                letterSpacing: letterSpacing,
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 45),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: const Text(
                                  'UI/UX DESIGNER',
                                  style: TextStyle(
                                    fontFamily: 'gondens',
                                    fontSize: 22,
                                    letterSpacing: 16,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              if (isMobile)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -4,
                  child: Center(
                    child: SizedBox(
                      width: widget.screenWidth * 0.92,
                      child: const GlitchImage(
                        imagePath: 'assets/images/nithesh.png',
                      ),
                    ),
                  ),
                )
              else
                Transform.translate(
                  offset: const Offset(18, 0),
                  child: SizedBox(
                    width: widget.screenWidth * 0.55,
                    child: const GlitchImage(
                      imagePath: 'assets/images/nithesh.png',
                    ),
                  ),
                ),

              // 3. FOREGROUND TEXT (Stroke)
              if (!isMobile)
                Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Center(
                    child: IgnorePointer(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'NITHESH',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'gondens',
                            fontSize: titleSize,
                            letterSpacing: letterSpacing,
                            fontWeight: FontWeight.w300,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 0.4
                              ..color = Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// A custom widget that applies a random, intermittent glitch effect to an image,
/// making it rapidly turn black and white.
class GlitchImage extends StatefulWidget {
  final String imagePath;

  const GlitchImage({super.key, required this.imagePath});

  @override
  State<GlitchImage> createState() => _GlitchImageState();
}

class _GlitchImageState extends State<GlitchImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _glitchController;
  Timer? _glitchTimer;
  final Random _random = Random();

  // Grayscale matrix used to desaturate colors entirely
  static const greyscaleMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  void initState() {
    super.initState();
    // This controller runs very fast to simulate a digital stutter
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scheduleNextGlitch();
  }

  void _scheduleNextGlitch() {
    // Randomly triggers a glitch every 2 to 5 seconds
    final int nextGlitchDelay = 2000 + _random.nextInt(3000);
    _glitchTimer = Timer(Duration(milliseconds: nextGlitchDelay), () {
      if (mounted) {
        _glitchController.forward(from: 0).then((_) => _scheduleNextGlitch());
      }
    });
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    _glitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        // Base image widget to avoid repetition
        final Widget imageWidget = Image.asset(
          widget.imagePath,
          fit: BoxFit.contain,
        );

        // If not animating, just show the normal image still anchored
        if (!_glitchController.isAnimating) {
          return imageWidget;
        }

        // --- GLITCH ACTIVE STATE ---

        // 1. Random positional jitter (increased slightly for more energy)
        final double mainOffsetX = (_random.nextDouble() - 0.5) * 15;

        // 2. Decide frame-by-frame whether to show B&W or Color.
        // During the 250ms animation, this will rebuild rapidly,
        // causing a "flickering" effect between colors and grayscale.
        final bool showGrayscale = _random.nextBool();

        Widget currentGlitchView;

        if (showGrayscale) {
          // Apply black and white matrix filter
          currentGlitchView = ColorFiltered(
            colorFilter: const ColorFilter.matrix(greyscaleMatrix),
            child: imageWidget,
          );
        } else {
          // Show normal colored image
          currentGlitchView = imageWidget;
        }

        return Transform.translate(
          offset: Offset(mainOffsetX, 0),
          child: Opacity(
            // Randomly flicker the opacity slightly for extra "digital instability"
            opacity: _random.nextDouble() > 0.9 ? 0.6 : 1.0,
            child: currentGlitchView,
          ),
        );
      },
    );
  }
}
