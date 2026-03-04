import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Data ───────────────────────────────────────────────────────────────────

const List<String> kTitles = [
  'Whispers of Light', 'Golden Hour', 'Urban Decay', 'Solitude',
  'Fractured Dreams', 'Neon Pulse', 'Still Waters', 'Dust & Shadow',
  'Chromatic Shift', 'The Void',
];

List<Map<String, String>> get kImages => List.generate(10, (i) => {
  'thumb': 'https://picsum.photos/id/${10 + i}/500/700?random=$i', 
  'full': 'https://picsum.photos/id/${10 + i}/1200/1200?random=$i',
  'title': kTitles[i],
  'index': i.toString(),
});

// ─── Gallery Section ────────────────────────────────────────────────────────

class GallerySection extends StatelessWidget {
  final double screenHeight;

  const GallerySection({super.key, required this.screenHeight});

  void _openLightbox(BuildContext context, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.95),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: LightboxScreen(images: kImages, initialIndex: index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight,
      color: const Color(0xFF0A0A0A), // Deep premium black
      child: Row(
        children: [
          // ── LEFT SIDE: Static Content ──
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 40, height: 2, color: const Color(0xFFF26A1B)),
                  const SizedBox(height: 20),
                  // const Text(
                  //   '03 / GALLERY',
                  //   style: TextStyle(
                  //     fontFamily: 'Courier',
                  //     color: Colors.white54,
                  //     letterSpacing: 4,
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  const Text(
                    'Gallery',
                    style: TextStyle(
                      fontFamily: 'gondens',
                      fontSize: 100,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 100),
                  Text(
                    'A curated collection of 10 frames moving in a continuous loop. Explore the moments captured through the lens, blending light, shadow, and architectural symmetry.',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 15,
                      height: 1.8,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── RIGHT SIDE: 4 Infinite Scrolling Marquees ──
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Row(
                  children: [
                    // Column 1 (Scrolls Down)
                    Expanded(
                      child: AutoScrollingGalleryColumn(
                        images: kImages,
                        reverse: false,
                        initialOffset: 50000.0, 
                        onTap: (idx) => _openLightbox(context, idx),
                      ),
                    ),
                    // Column 2 (Scrolls Up)
                    Expanded(
                      child: AutoScrollingGalleryColumn(
                        images: kImages,
                        reverse: true,
                        initialOffset: 50400.0, // Staggered offset
                        onTap: (idx) => _openLightbox(context, idx),
                      ),
                    ),
                    // Column 3 (Scrolls Down)
                    Expanded(
                      child: AutoScrollingGalleryColumn(
                        images: kImages,
                        reverse: false,
                        initialOffset: 50800.0, // Staggered offset
                        onTap: (idx) => _openLightbox(context, idx),
                      ),
                    ),
                    // Column 4 (Scrolls Up)
                    Expanded(
                      child: AutoScrollingGalleryColumn(
                        images: kImages,
                        reverse: true,
                        initialOffset: 51200.0, // Staggered offset
                        onTap: (idx) => _openLightbox(context, idx),
                      ),
                    ),
                  ],
                ),
                
                // Top Gradient for smooth fading
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [const Color(0xFF0A0A0A), const Color(0xFF0A0A0A).withOpacity(0)],
                      ),
                    ),
                  ),
                ),
                // Bottom Gradient for smooth fading
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [const Color(0xFF0A0A0A), const Color(0xFF0A0A0A).withOpacity(0)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Infinite Auto-Scrolling Column ─────────────────────────────────────────

class AutoScrollingGalleryColumn extends StatefulWidget {
  final List<Map<String, String>> images;
  final bool reverse;
  final double initialOffset;
  final Function(int) onTap;

  const AutoScrollingGalleryColumn({
    super.key,
    required this.images,
    required this.reverse,
    required this.initialOffset,
    required this.onTap,
  });

  @override
  State<AutoScrollingGalleryColumn> createState() => _AutoScrollingGalleryColumnState();
}

class _AutoScrollingGalleryColumnState extends State<AutoScrollingGalleryColumn>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollCtrl;
  late AnimationController _autoScrollAnim;
  
  late double _scrollOffset;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scrollOffset = widget.initialOffset;
    _scrollCtrl = ScrollController(initialScrollOffset: _scrollOffset);
    
    _autoScrollAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        if (!_scrollCtrl.hasClients || _isHovered) return;
        
        final delta = widget.reverse ? -1.0 : 1.0; 
        _scrollOffset += delta;
        _scrollCtrl.jumpTo(_scrollOffset);
    });
    
    _autoScrollAnim.repeat();
  }

  @override
  void dispose() {
    _autoScrollAnim.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) {
        setState(() => _isHovered = false);
        if (_scrollCtrl.hasClients) {
          _scrollOffset = _scrollCtrl.offset; 
        }
      },
      child: ListView.builder(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final realIndex = index % widget.images.length;
          return GalleryItem(
            image: widget.images[realIndex],
            index: realIndex,
            onTap: () => widget.onTap(realIndex),
          );
        },
      ),
    );
  }
}

// ─── Gallery Item Frame ──────────────────────────────────────────────────────

class GalleryItem extends StatefulWidget {
  final Map<String, String> image;
  final int index;
  final VoidCallback onTap;

  const GalleryItem({
    super.key,
    required this.image,
    required this.index,
    required this.onTap,
  });

  @override
  State<GalleryItem> createState() => _GalleryItemState();
}

class _GalleryItemState extends State<GalleryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          // Reduced padding from 20 to 10 horizontally to fit 4 columns gracefully
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: AspectRatio(
            aspectRatio: 0.70, // Cinematic vertical frame
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered ? const Color(0xFFF26A1B) : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  if (_isHovered)
                    BoxShadow(
                      color: const Color(0xFFF26A1B).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: -5,
                    )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedScale(
                      scale: _isHovered ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      child: Image.network(
                        widget.image['thumb']!,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const _ShimmerBox();
                        },
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.5, 1.0],
                          colors: [Colors.transparent, Color(0xEE000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16, // Adjusted bottom padding
                      left: 12,   // Adjusted left padding
                      right: 12,  // Adjusted right padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.image['title']!,
                            style: const TextStyle(
                              fontFamily: 'gondens',
                              fontSize: 18, // Scaled down font for narrower columns
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 9, // Scaled down font
                              fontFamily: 'Courier',
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              color: _isHovered ? const Color(0xFFF26A1B) : Colors.white54,
                            ),
                            child: Text('FRAME 0${widget.index + 1}'),
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
      ),
    );
  }
}

// ─── Shimmer Loading ─────────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_ctrl.value - 0.3).clamp(0.0, 1.0),
              _ctrl.value.clamp(0.0, 1.0),
              (_ctrl.value + 0.3).clamp(0.0, 1.0),
            ],
            colors: const [
              Color(0xFF151515),
              Color(0xFF1E1E1E),
              Color(0xFF151515),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Lightbox Screen ─────────────────────────────────────────────────────────

class LightboxScreen extends StatefulWidget {
  final List<Map<String, String>> images;
  final int initialIndex;

  const LightboxScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<LightboxScreen> createState() => _LightboxScreenState();
}

class _LightboxScreenState extends State<LightboxScreen>
    with SingleTickerProviderStateMixin {
  late int _current;
  late final PageController _pageCtrl;
  late final ScrollController _stripCtrl;
  late final AnimationController _captionCtrl;
  late final Animation<double> _captionFade;
  late final Animation<Offset> _captionSlide;

  static const _stripItemW = 50.0;
  static const _stripGap = 6.0;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: _current);
    _stripCtrl = ScrollController();
    _captionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _captionFade = CurvedAnimation(parent: _captionCtrl, curve: Curves.easeOut);
    _captionSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_captionFade);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollStrip(_current));
  }

  void _scrollStrip(int idx) {
    if (!_stripCtrl.hasClients) return;
    final offset = idx * (_stripItemW + _stripGap) -
        (MediaQuery.of(context).size.width / 2) +
        _stripItemW / 2;
    _stripCtrl.animateTo(
      offset.clamp(0.0, _stripCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _goTo(int idx) {
    if (idx == _current) return;
    _captionCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _current = idx);
      _pageCtrl.animateToPage(
        idx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _scrollStrip(idx);
      _captionCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _stripCtrl.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (e) {
        if (e is! KeyDownEvent) return;
        if (e.logicalKey == LogicalKeyboardKey.escape) Navigator.pop(context);
        if (e.logicalKey == LogicalKeyboardKey.arrowRight && _current < widget.images.length - 1) _goTo(_current + 1);
        if (e.logicalKey == LogicalKeyboardKey.arrowLeft && _current > 0) _goTo(_current - 1);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF333333)),
                color: Colors.black45,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
        body: Column(
          children: [
            // ── Main image viewer ──
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) {
                      setState(() => _current = i);
                      _scrollStrip(i);
                    },
                    itemCount: widget.images.length,
                    itemBuilder: (_, i) => InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.network(
                        widget.images[i]['full']!,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFF26A1B),
                              strokeWidth: 2,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Nav buttons
                  if (_current > 0)
                    Positioned(
                      left: 30,
                      child: _NavButton(icon: Icons.chevron_left, onTap: () => _goTo(_current - 1)),
                    ),
                  if (_current < widget.images.length - 1)
                    Positioned(
                      right: 30,
                      child: _NavButton(icon: Icons.chevron_right, onTap: () => _goTo(_current + 1)),
                    ),
                ],
              ),
            ),

            // ── Caption ──
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 12, 40, 0),
              child: FadeTransition(
                opacity: _captionFade,
                child: SlideTransition(
                  position: _captionSlide,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.images[_current]['title']!,
                        style: const TextStyle(
                          fontFamily: 'gondens',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(_current + 1).toString().padLeft(2, '0')} / ${widget.images.length}',
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF26A1B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Thumbnail strip ──
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              child: SizedBox(
                height: _stripItemW,
                child: ListView.separated(
                  controller: _stripCtrl,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: _stripGap),
                  itemBuilder: (_, i) {
                    final active = i == _current;
                    return GestureDetector(
                      onTap: () => _goTo(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _stripItemW,
                        height: _stripItemW,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: active ? const Color(0xFFF26A1B) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Opacity(
                            opacity: active ? 1.0 : 0.35,
                            child: Image.network(
                              widget.images[i]['thumb']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Nav Button ──────────────────────────────────────────────────────────────

class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _hovered ? const Color(0xFFF26A1B) : Colors.white24,
            ),
            color: _hovered ? const Color(0xFFF26A1B).withOpacity(0.15) : Colors.black54,
          ),
          child: Icon(
            widget.icon,
            color: _hovered ? const Color(0xFFF26A1B) : Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}