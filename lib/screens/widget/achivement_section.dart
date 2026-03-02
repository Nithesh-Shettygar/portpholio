import 'package:flutter/material.dart';

class AchievementSection extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final ScrollController scrollController;

  const AchievementSection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.scrollController,
  });

  @override
  State<AchievementSection> createState() => _AchievementSectionState();
}

class _AchievementSectionState extends State<AchievementSection> {
  final GlobalKey _sectionKey = GlobalKey();
  double _imageOffset = -1.5; 
  double _imageScale = 1.0; // Added for shrinking effect

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted) return;

    final RenderBox? renderBox = _sectionKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    double viewportHeight = MediaQuery.of(context).size.height;
    
    // scrollProgress:
    // 0.0 -> Bottom of section enters screen
    // 1.0 -> Center of section is at center of screen
    // 2.0 -> Section is moving off the top
    double scrollProgress = (viewportHeight - position.dy) / viewportHeight;

    setState(() {
      // 1. PINNING OFFSET LOGIC
      // Slides in until it reaches center (Offset 0.0), then stays pinned.
      _imageOffset = (-1.5 + (scrollProgress * 1.5)).clamp(-1.5, 0.0);

      // 2. DYNAMIC SCALING LOGIC
      if (scrollProgress <= 1.0) {
        // Phase A: Starting small and growing to 1.0 as it enters
        // Starts at 0.4 and reaches 1.0 when scrollProgress is 1.0
        _imageScale = (0.4 + (scrollProgress * 0.6)).clamp(0.4, 1.0);
      } else {
        // Phase B: Shrinking back down as user scrolls past center
        // Shrinks from 1.0 back toward 0.4
        _imageScale = (1.0 - (scrollProgress - 1.0) * 0.6).clamp(0.4, 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = widget.screenWidth < 800;

    return Container(
      key: _sectionKey,
      width: widget.screenWidth,
      constraints: BoxConstraints(minHeight: widget.screenHeight * 1.5), // Extra height to allow "pinning" space
      color: const Color(0xFFF2F2F2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. CONTENT LAYER
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 30 : widget.screenWidth * 0.1,
              vertical: 80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "ACHIEVEMENTS",
                  style: TextStyle(
                    fontSize: 64,
                    fontFamily: 'gondens',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 100,
                  height: 4,
                  color: const Color(0xFFF26A1B),
                ),
                const SizedBox(height: 60),
                Wrap(
                  spacing: 30,
                  runSpacing: 30,
                  
                ),
              ],
            ),
          ),

          // 2. IMAGE LAYER (Pinned and Scaling)
          IgnorePointer(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(0.0, _imageOffset * widget.screenHeight)
                ..scale(_imageScale), // Apply the shrinking scale
              child: Image.asset(
                'assets/images/glass.png',
                height: widget.screenHeight * 0.8,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String year, String description, IconData icon) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 40, color: const Color(0xFFF26A1B)),
              Text(year, style: const TextStyle(fontFamily: 'gondens', fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }
}