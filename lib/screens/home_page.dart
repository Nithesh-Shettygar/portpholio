import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'dart:ui';

// Custom Widget Imports
import 'package:nithesh/screens/widget/about_section.dart';
import 'package:nithesh/screens/widget/premium_project_card.dart';
import 'package:nithesh/screens/widget/skills_popup_content.dart';
import 'package:nithesh/screens/widget/experience.dart';
import 'package:nithesh/screens/widget/contact_section.dart';
import 'package:nithesh/screens/widget/custom_nav_bar.dart';

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
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // --- SCROLL SPY LOGIC ---
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    double offset = _scrollController.offset;
    double screenHeight = MediaQuery.of(context).size.height;

    int newIndex = 0;

    if (offset < screenHeight * 0.5) {
      newIndex = 0; // Home
    } else if (offset >= screenHeight * 0.5 && offset < screenHeight * 1.8) {
      newIndex = 1; // About
    } else if (offset >= screenHeight * 1.8 && offset < screenHeight * 3.5) {
      newIndex = 2; // Projects
    } else if (offset >= screenHeight * 3.5 && offset < screenHeight * 4.8) {
      newIndex = 3; // Skills
    } else if (offset >= screenHeight * 4.8 && offset < screenHeight * 5.8) {
      newIndex = 4; // Experience
    } else {
      newIndex = 5; // Contact
    }

    if (newIndex != _currentNavIndex) {
      setState(() {
        _currentNavIndex = newIndex;
      });
    }
  }

  // --- SCROLL NAVIGATION LOGIC ---
  void _scrollTo(double offset) {
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOutCubic,
    );
  }

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutCubic,
    );
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
                      Image.asset('assets/images/nithesh.png', fit: BoxFit.contain),
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
                child: AboutSection(screenHeight: screenHeight),
              ),

              // SECTION 3 & 4: Projects & Skills
              SliverPersistentHeader(
                pinned: true,
                delegate: ProjectSectionDelegate(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  scrollController: _scrollController,
                ),
              ),

              // Animation Spacer 
              SliverToBoxAdapter(child: SizedBox(height: screenHeight * 2.5)),

              // SECTION 5: Experience 
              SliverToBoxAdapter(
                child: ExperienceSection(screenWidth: screenWidth),
              ),

              // SECTION 6: Contact & Footer
              SliverToBoxAdapter(
                child: ContactSection(
                  screenWidth: screenWidth, 
                  screenHeight: screenHeight,
                ),
              ),
            ],
          ),

          // FLOATING GLASSES LAYER 
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

          // THE FLOATING NAVIGATION BAR
          if (screenWidth > 600)
            Positioned(
              top: 40,
              right: screenWidth > 1200 ? 80 : 40, 
              child: CustomNavBar(
                currentIndex: _currentNavIndex, 
                onHomeTap: () => _scrollTo(0),
                onAboutTap: () => _scrollTo(screenHeight),
                onProjectsTap: () => _scrollTo(screenHeight * 2),
                onSkillsTap: () => _scrollTo(screenHeight * 4.5), 
                onExperienceTap: () => _scrollTo(screenHeight * 5.5),
                onContactTap: _scrollToEnd,
              ),
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
        double progress = ((offset - startAt) / screenHeight).clamp(0.0, 3.5);

        // Animation Steps
        double rawDrop = (progress / 0.3).clamp(0.0, 1.0);
        double rawFan = ((progress - 0.3) / 0.3).clamp(0.0, 1.0);
        double rawSplit = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
        double rawRotate = ((progress - 1.0) / 0.5).clamp(0.0, 1.0);

        // Popup logic
        double growProgress = ((progress - 1.5) / 1.0).clamp(0.0, 1.0);
        double slideUpProgress = ((progress - 2.5) / 1.0).clamp(0.0, 1.0);

        // Title starts in center, moves to 60.0 margin on left during split
        double titleXOffset = lerpDouble((screenWidth / 2) - 150, 60.0, Curves.easeInOutCubic.transform(rawSplit))!;
        double titleOpacity = lerpDouble(1.0, 0.0, (growProgress - 0.8).clamp(0.0, 1.0) / 0.2)!;

        // Positioning for orange popup
        double entryY = lerpDouble(screenHeight, 0, Curves.fastOutSlowIn.transform(growProgress))!;
        
        // FIX: Linear exit to match scroll perfectly and prevent overlaps
        double exitY = -screenHeight * slideUpProgress; 
        double finalYOffset = entryY + exitY;

        // FIX: Removed the side-shrinking logic during slideUp to prevent the background gap
        double currentWidth = lerpDouble(screenWidth * 0.4, screenWidth, growProgress)!;
        double currentRadius = lerpDouble(40.0, 0.0, growProgress)!;

        double cardOpacity = (1.0 - growProgress).clamp(0.0, 1.0);

        return Container(
          height: screenHeight,
          color: Colors.black.withOpacity((1.0 - slideUpProgress).clamp(0.0, 1.0)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. PROJECTS TITLE
              Positioned(
                top: 50,
                left: titleXOffset,
                child: Opacity(
                  opacity: titleOpacity,
                  child: const Text(
                    "PROJECTS",
                    style: TextStyle(
                      fontSize: 64,
                      fontFamily: 'gondens',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 10,
                    ),
                  ),
                ),
              ),

              // 2. Cards Layer
              if (cardOpacity > 0.01)
                Opacity(
                  opacity: cardOpacity,
                  child: SizedBox.expand( 
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none, 
                      children: List.generate(8, (index) {
                        double fanTheta = lerpDouble(-math.pi / 4, math.pi / 4, index / 7)!;
                        double currentFanTheta = fanTheta * Curves.easeInOutCubic.transform(rawFan);
                        double dynamicBaseAngle = ((index * (math.pi / 4)) + (math.pi * 0.75)) + (Curves.easeInOut.transform(rawRotate) * math.pi);
                        double x = lerpDouble(300 * math.sin(currentFanTheta), math.cos(dynamicBaseAngle) * 200, Curves.easeInOutCubic.transform(rawSplit))!;
                        double y = lerpDouble(-screenHeight * 1.2, 0, Curves.easeInOutCubic.transform(rawDrop))! +
                            lerpDouble(300 - 300 * math.cos(currentFanTheta), math.sin(dynamicBaseAngle) * 200, Curves.easeInOutCubic.transform(rawSplit))!;
                        return Transform(
                          transform: Matrix4.identity()..translate(x, y)..rotateZ(_lerpAngle(currentFanTheta, dynamicBaseAngle + (math.pi / 2), Curves.easeInOutCubic.transform(rawSplit))),
                          alignment: Alignment.center,
                          child: cachedCards[index],
                        );
                      }).reversed.toList(),
                    ),
                  ),
                ),

              // 3. Popup
              if (growProgress > 0)
                Transform.translate(
                  offset: Offset(0, finalYOffset),
                  child: Container(
                    width: currentWidth,
                    height: screenHeight, // Remains full height
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

  @override double get maxExtent => screenHeight;
  @override double get minExtent => screenHeight;
  @override bool shouldRebuild(covariant ProjectSectionDelegate oldDelegate) => false;
}

class HeroSpecsImage extends StatelessWidget {
  const HeroSpecsImage({super.key});
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/glass.png', fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.remove_red_eye, size: 100, color: Colors.orange));
  }
}