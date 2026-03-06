import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'dart:ui';

// Custom Widget Imports
import 'package:nithesh/screens/widget/hero_section.dart';
import 'package:nithesh/screens/widget/about_section.dart';
import 'package:nithesh/screens/widget/premium_project_card.dart';
import 'package:nithesh/screens/widget/skills_popup_content.dart';
import 'package:nithesh/screens/widget/experience.dart';
// --- NEW IMPORT HERE ---
import 'package:nithesh/screens/widget/contact_section.dart';
import 'package:nithesh/screens/widget/custom_nav_bar.dart';
import 'package:nithesh/screens/widget/gallery_section.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'nithesh',
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

  // --- CURSOR STATE ---
  final ValueNotifier<Offset> _mousePos = ValueNotifier<Offset>(Offset.zero);
  final ValueNotifier<bool> _isHovering = ValueNotifier<bool>(false);

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
    _mousePos.dispose();
    _isHovering.dispose();
    super.dispose();
  }

  // --- SCROLL SPY LOGIC ---
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    double offset = _scrollController.offset;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth <= 800;

    int newIndex = 0;

    if (isMobile) {
      // Mobile breakpoints - adjusted for smaller screens
      if (offset < screenHeight * 0.4) {
        newIndex = 0; // Home
      } else if (offset >= screenHeight * 0.4 && offset < screenHeight * 1.5) {
        newIndex = 1; // About
      } else if (offset >= screenHeight * 1.5 && offset < screenHeight * 2.8) {
        newIndex = 2; // Projects
      } else if (offset >= screenHeight * 2.8 && offset < screenHeight * 3.8) {
        newIndex = 3; // Skills
      } else if (offset >= screenHeight * 3.8 && offset < screenHeight * 4.6) {
        newIndex = 4; // Experience
      } else if (offset >= screenHeight * 4.6 && offset < screenHeight * 5.4) {
        newIndex = 5; // Gallery
      } else {
        newIndex = 6; // Contact
      }
    } else {
      // Desktop breakpoints
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
      } else if (offset >= screenHeight * 5.8 && offset < screenHeight * 6.8) {
        newIndex = 5; // Gallery
      } else {
        newIndex = 6; // Contact
      }
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
      body: MouseRegion(
        cursor: SystemMouseCursors.none,
        onEnter: (_) => _isHovering.value = true,
        onExit: (_) => _isHovering.value = false,
        onHover: (event) => _mousePos.value = event.position,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // SECTION 1: Intro
                SliverToBoxAdapter(child: HeroSection(screenHeight: screenHeight, screenWidth: screenWidth)),

                // SECTION 2: About
                SliverToBoxAdapter(child: AboutSection(screenHeight: screenHeight, screenWidth: screenWidth)),

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
                SliverToBoxAdapter(child: ExperienceSection(screenWidth: screenWidth)),

                // SECTION 6: Gallery (after Experience)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: screenHeight,
                    child: GallerySection(screenHeight: screenHeight, screenWidth: screenWidth),
                  ),
                ),

                // SECTION 7: Contact & Footer
                SliverToBoxAdapter(
                  child: ContactSection(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ),
              ],
            ),

            // FLOATING GLASSES LAYER (unchanged)
            AnimatedBuilder(
              animation: _scrollController,
              child: const RepaintBoundary(child: HeroSpecsImage()),
              builder: (context, child) {
                double offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                double progressToAbout = (offset / screenHeight).clamp(0.0, 1.0);
                double progressThroughAbout = ((offset - screenHeight) / screenHeight).clamp(0.0, 1.0);

                double smoothIntro = Curves.easeInOutCubic.transform(progressToAbout);
                const double startRotation = -7 * (math.pi / 180);
                const double endRotation = math.pi / 2;
                double targetRotation = lerpDouble(startRotation, endRotation, smoothIntro)!;
                double horizontalShift = lerpDouble(0.0, 1.0, smoothIntro)!;
                double verticalShift = lerpDouble(-0.22, 0.0, smoothIntro)!;
                double dynamicWidth = lerpDouble(180, 500, smoothIntro)!;
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
                top: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  width: 80,
                  height: screenHeight,
                  alignment: Alignment.center,
                  child: CustomNavBar(
                    currentIndex: _currentNavIndex,
                    onHomeTap: () => _scrollTo(0),
                    onAboutTap: () => _scrollTo(screenHeight),
                    onProjectsTap: () => _scrollTo(screenHeight * 2),
                    onSkillsTap: () => _scrollTo(screenHeight * 4.5),
                    onExperienceTap: () => _scrollTo(screenHeight * 5.5),
                    onGalleryTap: () => _scrollTo(screenHeight * 6.5),
                    onContactTap: () => _scrollTo(screenHeight * 7.5),
                  ),
                ),
              ),

            // 2. THE CUSTOM CURSOR LAYER
            ValueListenableBuilder<bool>(
              valueListenable: _isHovering,
              builder: (context, isHovering, child) {
                if (!isHovering) return const SizedBox.shrink();
                return ValueListenableBuilder<Offset>(
                  valueListenable: _mousePos,
                  builder: (context, pos, child) {
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 50),
                      curve: Curves.easeOutCubic,
                      left: pos.dx - 15,
                      top: pos.dy - 15, 
                      child: const IgnorePointer(
                        child: CustomCursorWidget(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- PROJECT SECTION DELEGATE ---
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
    if (delta > math.pi) {
      delta -= 2 * math.pi;
    } else if (delta < -math.pi) {
      delta += 2 * math.pi;
    }
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

        double rawDrop = (progress / 0.3).clamp(0.0, 1.0);
        double rawFan = ((progress - 0.3) / 0.3).clamp(0.0, 1.0);
        double rawSplit = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
        double rawRotate = ((progress - 1.0) / 0.5).clamp(0.0, 1.0);

        double growProgress = ((progress - 1.5) / 1.0).clamp(0.0, 1.0);
        double slideUpProgress = ((progress - 2.5) / 1.0).clamp(0.0, 1.0);

        double titleXOffset = lerpDouble((screenWidth / 2) - 150, 60.0, Curves.easeInOutCubic.transform(rawSplit))!;
        double titleOpacity = lerpDouble(1.0, 0.0, (growProgress - 0.8).clamp(0.0, 1.0) / 0.2)!;

        double entryY = lerpDouble(screenHeight, 0, Curves.fastOutSlowIn.transform(growProgress))!;
        double exitY = -screenHeight * slideUpProgress;
        double finalYOffset = entryY + exitY;

        double currentWidth = lerpDouble(screenWidth * 0.4, screenWidth, growProgress)!;
        double currentRadius = lerpDouble(40.0, 0.0, growProgress)!;

        double cardOpacity = (1.0 - growProgress).clamp(0.0, 1.0);

        return Container(
          height: screenHeight,
          color: Colors.black.withOpacity((1.0 - slideUpProgress).clamp(0.0, 1.0)),
          child: Stack(
            alignment: Alignment.center,
            children: [
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

              // (Glow removed)

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
                        double dynamicBaseAngle = ((index * (math.pi / 4)) + (math.pi * 0.75)) +
                            (Curves.easeInOut.transform(rawRotate) * math.pi);
                        double x = lerpDouble(
                          300 * math.sin(currentFanTheta),
                          math.cos(dynamicBaseAngle) * 200,
                          Curves.easeInOutCubic.transform(rawSplit),
                        )!;
                        double y = lerpDouble(-screenHeight * 1.2, 0, Curves.easeInOutCubic.transform(rawDrop))! +
                            lerpDouble(
                              300 - 300 * math.cos(currentFanTheta),
                              math.sin(dynamicBaseAngle) * 200,
                              Curves.easeInOutCubic.transform(rawSplit),
                            )!;
                        return Transform(
                          transform: Matrix4.identity()
                            ..translate(x, y)
                            ..rotateZ(
                              _lerpAngle(
                                currentFanTheta,
                                dynamicBaseAngle + (math.pi / 2),
                                Curves.easeInOutCubic.transform(rawSplit),
                              ),
                            ),
                          alignment: Alignment.center,
                          child: cachedCards[index],
                        );
                      }).reversed.toList(),
                    ),
                  ),
                ),

              if (growProgress > 0)
                Transform.translate(
                  offset: Offset(0, finalYOffset),
                  child: Container(
                    width: currentWidth,
                    height: screenHeight,
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

// --- UTILITY WIDGETS ---

class HeroSpecsImage extends StatelessWidget {
  const HeroSpecsImage({super.key});
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/glass.png',
      fit: BoxFit.contain,
      errorBuilder: (c, e, s) => const Icon(Icons.remove_red_eye, size: 100, color: Colors.orange),
    );
  }
}

// --- NEW CUSTOM CURSOR WIDGET ---
class CustomCursorWidget extends StatelessWidget {
  const CustomCursorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, 
      height: 50,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. BOTTOM LAYER: The Black Stroke (Border)
          Text(
            'N',
            style: TextStyle(
              fontFamily: 'gondens', 
              fontSize: 30, 
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0 
                ..color = Colors.black, 
            ),
          ),
          
          // 2. TOP LAYER: The Orange Fill
          const Text(
            'N',
            style: TextStyle(
              fontFamily: 'gondens',
              fontSize: 30, 
              color: Color(0xFFF26A1B), 
            ),
          ),
        ],
      ),
    );
  }
}