import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'dart:ui';

// Ensure these files exist in your project
import 'package:nithesh/screens/widget/premium_project_card.dart';
import 'package:nithesh/screens/widget/skills_popup_content.dart';
import 'package:nithesh/screens/widget/experience.dart';

void main() {
  runApp(
    MaterialApp(
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
    ),
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // SECTION 1: Intro
              SliverToBoxAdapter(
                child: Container(
                  height: screenHeight,
                  color: const Color(0xFFF2F2F2),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: const Text(
                            'NITHESH',
                            style: TextStyle(
                              fontFamily: 'gondens',
                              fontSize: 350,
                              letterSpacing: 30,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/nithesh.png',
                        fit: BoxFit.contain,
                      ),
                      Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'NITHESH',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'gondens',
                              fontSize: 350,
                              letterSpacing: 30,
                              fontWeight: FontWeight.w300,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 0.3
                                ..color = const Color(0xFFF2F2F2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // SECTION 2: About
              SliverToBoxAdapter(
                child: Container(
                  height: screenHeight,
                  color: const Color(0xFFF26A1B),
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "ABOUT",
                              style: TextStyle(
                                fontSize: 64,
                                fontFamily: 'gondens',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Nithesh is a visionary designer specializing in high-performance eyewear. This collection represents a fusion of minimalist aesthetics and structural integrity.",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(flex: 2, child: SizedBox()),
                    ],
                  ),
                ),
              ),

              // SECTION 3 & 4: Projects and Expanding/Shrinking Skills Popup
              SliverPersistentHeader(
                pinned: true,
                delegate: ProjectSectionDelegate(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  scrollController: _scrollController,
                ),
              ),

              // Animation Spacer (Increased to handle grow + shrink phases)
              SliverToBoxAdapter(child: SizedBox(height: screenHeight * 4.5)),

              // SECTION 5: Experience (Revealed after popup shrinks)
              SliverToBoxAdapter(
                child: ExperienceSection(screenWidth: screenWidth),
              ),

              // Final Footer Spacer
              SliverToBoxAdapter(child: SizedBox(height: screenHeight * 0.5)),
            ],
          ),

          // 2. FLOATING GLASSES LAYER (Active during Intro/About)
          AnimatedBuilder(
            animation: _scrollController,
            child: const RepaintBoundary(child: HeroSpecsImage()),
            builder: (context, child) {
              double offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
              double progressToAbout = (offset / screenHeight).clamp(0.0, 1.0);
              double progressThroughAbout = ((offset - screenHeight) / screenHeight).clamp(0.0, 1.0);

              double smoothIntro = Curves.easeInOutCubic.transform(progressToAbout);
              double horizontalShift = lerpDouble(0.0, 1.0, smoothIntro)!;
              double verticalShift = lerpDouble(-0.2, 0.0, smoothIntro)!;
              double targetRotation = (math.pi / 2) * smoothIntro;
              double dynamicWidth = lerpDouble(200, 500, smoothIntro)!;
              double scrollUpOffset = progressThroughAbout * -screenHeight;

              if (progressThroughAbout >= 1.0) return const SizedBox.shrink();

              return IgnorePointer(
                child: Transform.translate(
                  offset: Offset(0, scrollUpOffset),
                  child: Align(
                    alignment: Alignment(horizontalShift, verticalShift),
                    child: SizedBox(
                      width: dynamicWidth,
                      child: Transform.rotate(
                        angle: targetRotation,
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProjectSectionDelegate extends SliverPersistentHeaderDelegate {
  final double screenHeight;
  final double screenWidth;
  final ScrollController scrollController;
  final List<Widget> cachedCards;

  ProjectSectionDelegate({
    required this.screenHeight,
    required this.screenWidth,
    required this.scrollController,
  }) : cachedCards = List.generate(
          8,
          (index) => RepaintBoundary(child: PremiumProjectCard(index: index)),
        );

  double _lerpAngle(double a, double b, double t) {
    double delta = (b - a) % (2 * math.pi);
    if (delta > math.pi) delta -= 2 * math.pi;
    else if (delta < -math.pi) delta += 2 * math.pi;
    return a + delta * t;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        double offset = scrollController.hasClients ? scrollController.offset : 0.0;
        double startAt = screenHeight * 2;
        
        // Progress 0.0 -> 3.5 Timeline
        double progress = ((offset - startAt) / screenHeight).clamp(0.0, 3.5);

        // Card Animation Phases
        double rawDrop = (progress / 0.3).clamp(0.0, 1.0);
        double rawFan = ((progress - 0.3) / 0.3).clamp(0.0, 1.0);
        double rawSplit = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
        double rawRotate = ((progress - 1.0) / 0.5).clamp(0.0, 1.0);

        // Popup Growth and Shrink Logic
        double growProgress = ((progress - 1.5) / 1.0).clamp(0.0, 1.0);
        double shrinkProgress = ((progress - 2.5) / 1.0).clamp(0.0, 1.0);
        double combinedUIFactor = growProgress - shrinkProgress;
        double smoothUI = Curves.easeInOutCubic.transform(combinedUIFactor.clamp(0.0, 1.0));

        // UI Properties
        double titleXOffset = lerpDouble((screenWidth / 2) - 150, 60.0, Curves.easeInOutCubic.transform(rawSplit))!;
        double titleOpacity = (1.0 - growProgress).clamp(0.0, 1.0);
        double yOffset = lerpDouble(screenHeight, 0, smoothUI)!;
        double currentWidth = lerpDouble(screenWidth * 0.4, screenWidth, smoothUI)!;
        double currentHeight = lerpDouble(screenHeight * 0.5, screenHeight, smoothUI)!;
        double currentRadius = lerpDouble(40.0, 0.0, smoothUI)!;
        double cardOpacity = (1.0 - growProgress).clamp(0.0, 1.0);

        return Container(
          height: screenHeight,
          color: Colors.black.withOpacity((1.0 - shrinkProgress).clamp(0.0, 1.0)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (titleOpacity > 0)
                Positioned(
                  top: 50,
                  left: titleXOffset,
                  child: Opacity(
                    opacity: titleOpacity,
                    child: const Text(
                      "PROJECTS",
                      style: TextStyle(fontSize: 64, fontFamily: 'gondens', fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 10),
                    ),
                  ),
                ),

              if (cardOpacity > 0.01)
                Opacity(
                  opacity: cardOpacity,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: List.generate(8, (index) {
                        double fanTheta = lerpDouble(-math.pi/4, math.pi/4, index/7)!;
                        double currentFanTheta = fanTheta * Curves.easeInOutCubic.transform(rawFan);
                        double dynamicBaseAngle = ((index * (math.pi / 4)) + (math.pi * 0.75)) + (Curves.easeInOut.transform(rawRotate) * math.pi);
                        
                        double x = lerpDouble(300 * math.sin(currentFanTheta), math.cos(dynamicBaseAngle) * 200, Curves.easeInOutCubic.transform(rawSplit))!;
                        double y = lerpDouble(-screenHeight * 1.2, 0, Curves.easeInOutCubic.transform(rawDrop))! + 
                                   lerpDouble(300 - 300 * math.cos(currentFanTheta), math.sin(dynamicBaseAngle) * 200, Curves.easeInOutCubic.transform(rawSplit))!;
                        
                        return Transform(
                          transform: Matrix4.identity()..translate(x, y)..rotateZ(_lerpAngle(currentFanTheta, dynamicBaseAngle + (math.pi/2), Curves.easeInOutCubic.transform(rawSplit))),
                          alignment: Alignment.center,
                          child: cachedCards[index],
                        );
                      }).reversed.toList(),
                    ),
                  ),
                ),

              if (combinedUIFactor > 0)
                Transform.translate(
                  offset: Offset(0, yOffset),
                  child: Container(
                    width: currentWidth,
                    height: currentHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF26A1B),
                      borderRadius: BorderRadius.circular(currentRadius),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(currentRadius),
                      child: SkillsPopupContent(progress: growProgress),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  double get maxExtent => screenHeight;
  @override
  double get minExtent => screenHeight;
  @override
  bool shouldRebuild(covariant ProjectSectionDelegate oldDelegate) => false;
}

class HeroSpecsImage extends StatelessWidget {
  const HeroSpecsImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/glass.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.remove_red_eye, size: 100, color: Colors.orange),
    );
  }
}