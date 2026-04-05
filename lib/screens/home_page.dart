import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'dart:ui';

// Custom Widget Imports (Ensure these files exist in your project)
import 'package:nithesh/screens/widget/hero_section.dart';
import 'package:nithesh/screens/widget/about_section.dart';
import 'package:nithesh/screens/widget/premium_project_card.dart';
import 'package:nithesh/screens/widget/skills_popup_content.dart';
import 'package:nithesh/screens/widget/experience.dart';
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

  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _projectKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

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

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    double offset = _scrollController.offset;
    double screenHeight = MediaQuery.of(context).size.height;

    int newIndex = 0;
    if (offset < screenHeight * 0.5)
      newIndex = 0;
    else if (offset < screenHeight * 1.8)
      newIndex = 1;
    else if (offset < screenHeight * 4.0)
      newIndex = 2;
    else if (offset < screenHeight * 6.0)
      newIndex = 3;
    else if (offset < screenHeight * 7.0)
      newIndex = 4;
    else if (offset < screenHeight * 8.0)
      newIndex = 5;
    else
      newIndex = 6;

    if (newIndex != _currentNavIndex) {
      setState(() => _currentNavIndex = newIndex);
    }
  }

  void _scrollTo(double offset) {
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOutCubic,
    );
  }

  void _scrollToSection(GlobalKey key, {double offsetAdjustment = 0}) {
    final targetOffset = _offsetForKey(key);
    if (targetOffset == null || !_scrollController.hasClients) return;

    final correctedOffset = (targetOffset + offsetAdjustment).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollTo(correctedOffset);
  }

  double? _offsetForKey(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext == null || !_scrollController.hasClients) return null;
    final renderObject = targetContext.findRenderObject();
    if (renderObject is! RenderBox) return null;
    final yInViewport = renderObject.localToGlobal(Offset.zero).dy;
    return _scrollController.offset + yInViewport;
  }

  void _scrollToSkills(double screenHeight) {
    // Skills popup becomes visible in the Project section after ~3.3 screen-heights.
    const double skillsPopupOffsetScreens = 3.3;

    final projectOffset = _offsetForKey(_projectKey);
    if (projectOffset == null || !_scrollController.hasClients) {
      _scrollTo(screenHeight * (2 + skillsPopupOffsetScreens));
      return;
    }

    final skillsOffset =
        (projectOffset + (screenHeight * skillsPopupOffsetScreens)).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
    _scrollTo(skillsOffset);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        children: [
          // 1. GLOBAL MOUSE TRACKER
          if (!isMobile)
            Positioned.fill(
              child: MouseRegion(
                cursor: SystemMouseCursors.none,
                onEnter: (_) => _isHovering.value = true,
                onExit: (_) => _isHovering.value = false,
                onHover: (event) => _mousePos.value = event.position,
                child: const SizedBox.expand(),
              ),
            ),

          // 2. CONTENT LAYER
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: HeroSection(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                ),
              ),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _aboutKey,
                  child: AboutSection(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(key: _projectKey, height: 1)),
              SliverPersistentHeader(
                pinned: true,
                delegate: ProjectSectionDelegate(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  scrollController: _scrollController,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: screenHeight * 3.5)),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _experienceKey,
                  child: ExperienceSection(screenWidth: screenWidth),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  key: _galleryKey,
                  height: screenHeight,
                  child: GallerySection(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _contactKey,
                  child: ContactSection(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ),
              ),
            ],
          ),

          // 3. FLOATING GLASSES ANIMATION
          if (!isMobile)
            AnimatedBuilder(
              animation: _scrollController,
              child: const RepaintBoundary(child: HeroSpecsImage()),
              builder: (context, child) {
                double offset = _scrollController.hasClients
                    ? _scrollController.offset
                    : 0.0;
                double totalProgress = (offset / (screenHeight * 4)).clamp(
                  0.0,
                  1.0,
                );
                if (offset < 0) return const SizedBox.shrink();

                double startAt = screenHeight * 2;
                double projectProgress = ((offset - startAt) / screenHeight)
                    .clamp(0.0, 4.5);
                double growProgress = ((projectProgress - 2.5) / 1.0).clamp(
                  0.0,
                  1.0,
                );
                double expProgress = ((projectProgress - 3.5) / 1.0).clamp(
                  0.0,
                  1.0,
                );

                double phaseAbout = 1.0 / 4.0;
                double phaseProjectsStart = 2.0 / 4.0;
                double phaseGlassMovesLeft = 2.5 / 4.0;

                double rotation, horizontalAlign, verticalAlign, glassWidth;

                // --- BASE LOGIC ---
                if (totalProgress < phaseAbout) {
                  double p = totalProgress / phaseAbout;
                  double ease = Curves.easeInOutCubic.transform(p);
                  rotation = lerpDouble(
                    -7 * (math.pi / 180),
                    math.pi / 2,
                    ease,
                  )!;
                  horizontalAlign = lerpDouble(0.0, 1.0, ease)!;
                  verticalAlign = lerpDouble(-0.22, 0.0, ease)!;
                  glassWidth = lerpDouble(180, 500, ease)!;
                } else if (totalProgress < phaseProjectsStart) {
                  double p =
                      (totalProgress - phaseAbout) /
                      (phaseProjectsStart - phaseAbout);
                  double ease = Curves.easeInOutCubic.transform(p);
                  rotation = lerpDouble(math.pi / 2, 0.0, ease)!;
                  horizontalAlign = lerpDouble(1.0, 0.0, ease)!;
                  verticalAlign = lerpDouble(0.0, -0.08, ease)!;
                  glassWidth = lerpDouble(500, 600, ease)!;
                } else if (totalProgress < phaseGlassMovesLeft) {
                  double p =
                      (totalProgress - phaseProjectsStart) /
                      (phaseGlassMovesLeft - phaseProjectsStart);
                  double ease = Curves.easeInOutCubic.transform(p);
                  rotation = lerpDouble(0.0, -math.pi / 2, ease)!;
                  horizontalAlign = lerpDouble(0.0, -1.3, ease)!;
                  verticalAlign = lerpDouble(-0.08, 0.0, ease)!;
                  glassWidth = lerpDouble(600, 500, ease)!;
                } else if (growProgress < 0.5) {
                  double exitProgress = (growProgress / 0.5);
                  double ease = Curves.easeInOutCubic.transform(exitProgress);
                  rotation = -math.pi / 2;
                  horizontalAlign = lerpDouble(-1.3, -3.0, ease)!;
                  verticalAlign = 0.0;
                  glassWidth = 500;
                } else if (expProgress == 0) {
                  double enterProgress = ((growProgress - 0.5) / 0.5);
                  double ease = Curves.easeInOutCubic.transform(enterProgress);
                  rotation = lerpDouble(
                    -math.pi / 2,
                    -20 * (math.pi / 180),
                    ease,
                  )!;
                  horizontalAlign = lerpDouble(3.0, -0.2, ease)!;
                  verticalAlign = lerpDouble(0.0, -0.5, ease)!;
                  glassWidth = lerpDouble(300, 200, ease)!;
                } else {
                  double bounceEase = Curves.bounceOut.transform(expProgress);
                  double smoothEase = Curves.easeInOutCubic.transform(
                    expProgress,
                  );
                  rotation = lerpDouble(
                    -20 * (math.pi / 180),
                    4 * math.pi,
                    smoothEase,
                  )!;
                  horizontalAlign = lerpDouble(-0.2, 0.6, smoothEase)!;
                  verticalAlign = lerpDouble(-0.5, 0.0, bounceEase)!;
                  glassWidth = lerpDouble(200, 500, bounceEase)!;
                }

                // --- GALLERY OVERRIDE ---
                if (offset > screenHeight * 6.8 &&
                    offset <= screenHeight * 8.0) {
                  double galleryTransition =
                      ((offset - screenHeight * 6.8) / (screenHeight * 1.0))
                          .clamp(0.0, 1.0);
                  double ease = Curves.easeInOutCubic.transform(
                    galleryTransition,
                  );
                  rotation = lerpDouble(rotation, math.pi / 2, ease)!;
                  horizontalAlign = lerpDouble(horizontalAlign, -1.19, ease)!;
                  verticalAlign = lerpDouble(verticalAlign, 0.0, ease)!;
                  glassWidth = lerpDouble(glassWidth, 500, ease)!;
                }

                // --- CONTACT OVERRIDE (STICKY TOP & LARGE) ---
                if (offset > screenHeight * 8.0) {
                  // Transition over 0.5 screen heights, then clamp (locks in place)
                  double contactTransition =
                      ((offset - screenHeight * 8.0) / (screenHeight * 0.5))
                          .clamp(0.0, 1.0);
                  double ease = Curves.easeInOutCubic.transform(
                    contactTransition,
                  );

                  rotation = lerpDouble(math.pi / 2, 0.0, ease)!;
                  horizontalAlign = lerpDouble(-1.19, 0.0, ease)!;
                  // -0.95 keeps it "stuck" at the top of the viewport relative to the stack
                  verticalAlign = lerpDouble(0.0, -0.95, ease)!;
                  glassWidth = lerpDouble(500, 900, ease)!; // Large size
                }

                return IgnorePointer(
                  child: Align(
                    alignment: Alignment(horizontalAlign, verticalAlign),
                    child: SizedBox(
                      width: glassWidth,
                      child: Transform.rotate(angle: rotation, child: child),
                    ),
                  ),
                );
              },
            ),

          // 4. NAVIGATION
          if (screenWidth > 600)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Container(
                width: 80,
                alignment: Alignment.center,
                child: CustomNavBar(
                  currentIndex: _currentNavIndex,
                  onHomeTap: () => _scrollTo(0),
                  onAboutTap: () => _scrollToSection(_aboutKey),
                  onProjectsTap: () => _scrollToSection(_projectKey),
                  onSkillsTap: () => _scrollToSkills(screenHeight),
                  onExperienceTap: () => _scrollToSection(_experienceKey),
                  onGalleryTap: () => _scrollToSection(_galleryKey),
                  onContactTap: () => _scrollToSection(_contactKey),
                ),
              ),
            ),

          // 5. CUSTOM CURSOR
          if (!isMobile)
            ValueListenableBuilder<bool>(
              valueListenable: _isHovering,
              builder: (context, isHovering, child) {
                if (!isHovering) return const SizedBox.shrink();
                return ValueListenableBuilder<Offset>(
                  valueListenable: _mousePos,
                  builder: (context, pos, child) {
                    return Positioned(
                      left: pos.dx - 15,
                      top: pos.dy - 15,
                      child: const IgnorePointer(child: CustomCursorWidget()),
                    );
                  },
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
    if (delta < -math.pi) delta += 2 * math.pi;
    return a + delta * t;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        double offset = scrollController.hasClients
            ? scrollController.offset
            : 0.0;
        final bool isMobile = screenWidth <= 800;

        double startAt = screenHeight * 2;
        double progress = ((offset - startAt) / screenHeight).clamp(0.0, 4.5);
        double bgShiftProgress = ((progress - 0.5) / 0.4).clamp(0.0, 1.0);
        double stripSlideProgress = ((progress - 0.7) / 0.4).clamp(0.0, 1.0);
        double rawDrop = ((progress - 0.5) / 0.3).clamp(0.0, 1.0);
        double rawFan = ((progress - 0.8) / 0.3).clamp(0.0, 1.0);
        double rawSplit = ((progress - 1.1) / 0.4).clamp(0.0, 1.0);
        double rawRotate = ((progress - 1.5) / 0.5).clamp(0.0, 1.0);
        double growProgress = ((progress - 2.5) / 1.0).clamp(0.0, 1.0);
        double slideUpProgress = ((progress - 3.5) / 1.0).clamp(0.0, 1.0);
        double titleXOffset = lerpDouble(
          (screenWidth / 2) - 150,
          60.0,
          Curves.easeInOutCubic.transform(rawSplit),
        )!;
        double titleOpacity = lerpDouble(
          1.0,
          0.0,
          (growProgress - 0.8).clamp(0.0, 1.0) / 0.2,
        )!;
        double finalYOffset =
            lerpDouble(
              screenHeight,
              0,
              Curves.fastOutSlowIn.transform(growProgress),
            )! +
            (-screenHeight * slideUpProgress);
        double currentWidth = lerpDouble(
          screenWidth * 0.4,
          screenWidth,
          growProgress,
        )!;
        double currentRadius = lerpDouble(40.0, 0.0, growProgress)!;
        double cardOpacity = (1.0 - growProgress).clamp(0.0, 1.0);
        final double fanRadius = isMobile ? screenWidth * 0.24 : 300;
        final double fanLift = isMobile ? screenHeight * 0.18 : 300;
        final double orbitRadius = isMobile ? math.min(screenWidth * 0.24, 95) : 200;
        final double dropStartY = isMobile ? -screenHeight * 0.5 : -screenHeight * 1.2;

        return IgnorePointer(
          ignoring: slideUpProgress >= 1.0,
          child: Container(
            height: screenHeight,
            color: Colors.black.withOpacity(
              (1.0 - slideUpProgress).clamp(0.0, 1.0),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (cardOpacity > 0.01)
                  Positioned.fill(
                    child: Opacity(
                      opacity: cardOpacity * 0.7,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: lerpDouble(
                                1.0,
                                0.88,
                                Curves.easeInOut.transform(bgShiftProgress),
                              ),
                              heightFactor: 1.0,
                              child: Image.asset(
                                'assets/images/black leather.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            left: lerpDouble(
                              -screenWidth * 0.12,
                              0,
                              Curves.easeOutCubic.transform(stripSlideProgress),
                            ),
                            top: 0,
                            bottom: 0,
                            width: screenWidth * 0.12,
                            child: isMobile
                                ? Container(
                                    color: const Color(0xFFF26A1B),
                                  )
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.matrix(<double>[
                                      0.299,
                                      0.587,
                                      0.114,
                                      0,
                                      0,
                                      0.299,
                                      0.587,
                                      0.114,
                                      0,
                                      0,
                                      0.299,
                                      0.587,
                                      0.114,
                                      0,
                                      0,
                                      0,
                                      0,
                                      0,
                                      1,
                                      0,
                                    ]),
                                    child: Image.asset(
                                      'assets/images/4.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 50,
                  right: titleXOffset,
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
                if (cardOpacity > 0.01)
                  Transform.translate(
                    offset: Offset(0, isMobile ? -100 : 0),
                    child: Opacity(
                      opacity: cardOpacity,
                      child: SizedBox.expand(
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: List.generate(8, (index) {
                          double fanTheta = lerpDouble(
                            -math.pi / 4,
                            math.pi / 4,
                            index / 7,
                          )!;
                          double currentFanTheta =
                              fanTheta *
                              Curves.easeInOutCubic.transform(rawFan);
                          double dynamicBaseAngle =
                              ((index * (math.pi / 4)) + (math.pi * 0.75)) +
                              (Curves.easeInOut.transform(rawRotate) * math.pi);
                          double x = lerpDouble(
                            fanRadius * math.sin(currentFanTheta),
                            math.cos(dynamicBaseAngle) * orbitRadius,
                            Curves.easeInOutCubic.transform(rawSplit),
                          )!;
                          double y =
                              lerpDouble(
                                dropStartY,
                                0,
                                Curves.easeInOutCubic.transform(rawDrop),
                              )! +
                              lerpDouble(
                                fanLift - fanLift * math.cos(currentFanTheta),
                                math.sin(dynamicBaseAngle) * orbitRadius,
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
      errorBuilder: (c, e, s) =>
          const Icon(Icons.remove_red_eye, size: 100, color: Colors.orange),
    );
  }
}

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
