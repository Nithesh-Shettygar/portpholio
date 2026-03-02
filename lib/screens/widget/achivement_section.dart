// import 'package:flutter/material.dart';

// class AchievementSection extends StatefulWidget {
//   final double screenWidth;
//   final double screenHeight;
//   final ScrollController scrollController;

//   const AchievementSection({
//     super.key,
//     required this.screenWidth,
//     required this.screenHeight,
//     required this.scrollController,
//   });

//   @override
//   State<AchievementSection> createState() => _AchievementSectionState();
// }

// class _AchievementSectionState extends State<AchievementSection> {
//   final GlobalKey _sectionKey = GlobalKey();
//   double _imageOffset = -1.5; 
//   double _imageScale = 1.0; // Added for shrinking effect

//   @override
//   void initState() {
//     super.initState();
//     widget.scrollController.addListener(_handleScroll);
//   }

//   @override
//   void dispose() {
//     widget.scrollController.removeListener(_handleScroll);
//     super.dispose();
//   }

//   void _handleScroll() {
//     if (!mounted) return;

//     final RenderBox? renderBox = _sectionKey.currentContext?.findRenderObject() as RenderBox?;
//     if (renderBox == null) return;

//     final position = renderBox.localToGlobal(Offset.zero);
//     double viewportHeight = MediaQuery.of(context).size.height;
    
//     // scrollProgress:
//     // 0.0 -> Bottom of section enters screen
//     // 1.0 -> Center of section is at center of screen
//     // 2.0 -> Section is moving off the top
//     double scrollProgress = (viewportHeight - position.dy) / viewportHeight;

//     setState(() {
//       // 1. PINNING OFFSET LOGIC
//       // Slides in until it reaches center (Offset 0.0), then stays pinned.
//       _imageOffset = (-1.5 + (scrollProgress * 1.5)).clamp(-1.5, 0.0);

//       // 2. DYNAMIC SCALING LOGIC
//       if (scrollProgress <= 1.0) {
//         // Phase A: Starting small and growing to 1.0 as it enters
//         // Starts at 0.4 and reaches 1.0 when scrollProgress is 1.0
//         _imageScale = (0.4 + (scrollProgress * 0.6)).clamp(0.4, 1.0);
//       } else {
//         // Phase B: Shrinking back down as user scrolls past center
//         // Shrinks from 1.0 back toward 0.4
//         _imageScale = (1.0 - (scrollProgress - 1.0) * 0.6).clamp(0.4, 1.0);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = widget.screenWidth < 800;

//     return Container(
//       key: _sectionKey,
//       width: widget.screenWidth,
//       constraints: BoxConstraints(minHeight: widget.screenHeight * 1.5), // Extra height to allow "pinning" space
//       color: const Color(0xFFF2F2F2),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // 1. CONTENT LAYER
//           Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 30 : widget.screenWidth * 0.1,
//               vertical: 80,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   "ACHIEVEMENTS",
//                   style: TextStyle(
//                     fontSize: 64,
//                     fontFamily: 'gondens',
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                     letterSpacing: 8,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Container(
//                   width: 100,
//                   height: 4,
//                   color: const Color(0xFFF26A1B),
//                 ),
//                 const SizedBox(height: 60),
//                 Wrap(
//                   spacing: 30,
//                   runSpacing: 30,
                  
//                 ),
//               ],
//             ),
//           ),

//           // 2. IMAGE LAYER (Pinned and Scaling)
//           IgnorePointer(
//             child: Transform(
//               alignment: Alignment.center,
//               transform: Matrix4.identity()
//                 ..translate(0.0, _imageOffset * widget.screenHeight)
//                 ..scale(_imageScale), // Apply the shrinking scale
//               child: Image.asset(
//                 'assets/images/glass.png',
//                 height: widget.screenHeight * 0.8,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAchievementCard(String title, String year, String description, IconData icon) {
//     return Container(
//       width: 320,
//       padding: const EdgeInsets.all(30),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.black12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(icon, size: 40, color: const Color(0xFFF26A1B)),
//               Text(year, style: const TextStyle(fontFamily: 'gondens', fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
//         ],
//       ),
//     );
//   }
// }



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
  @override
  Widget build(BuildContext context) {
    bool isMobile = widget.screenWidth < 900;

    return Container(
      width: widget.screenWidth,
      constraints: BoxConstraints(minHeight: widget.screenHeight),
      color: const Color(0xFFF2F2F2),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : widget.screenWidth * 0.08,
        vertical: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Container(width: 80, height: 4, color: const Color(0xFFF26A1B)),
          const SizedBox(height: 50),

          LayoutBuilder(
            builder: (context, constraints) {
              double spacing = 16.0;
              double totalWidth = constraints.maxWidth;
              
              // 4-Column Grid logic for Desktop
              double unit = (totalWidth - (spacing * 3)) / 4;
              double col1 = unit;
              double col2 = (unit * 2) + spacing;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  // 1. Featured Large (2x2 style)
                  _buildBentoCard(0, isMobile ? totalWidth : col2, 420, "2024 Design Gold", "International Awards", Icons.emoji_events, isDark: true),
                  
                  // 2. Small square
                  _buildBentoCard(1, isMobile ? totalWidth : col1, 202, "10+", "Global Clients", Icons.public),
                  
                  // 3. Small square
                  _buildBentoCard(2, isMobile ? totalWidth : col1, 202, "Top 1%", "Dribbble", Icons.auto_awesome),

                  // 4. Wide item
                  _buildBentoCard(3, isMobile ? totalWidth : col2, 202, "Flutter Expert", "Verified Developer", Icons.bolt),

                  // 5. Tall item
                  _buildBentoCard(4, isMobile ? (totalWidth - spacing)/2 : col1, 350, "Mentorship", "50+ Students", Icons.groups),

                  // 6. Medium item
                  _buildBentoCard(5, isMobile ? (totalWidth - spacing)/2 : col1, 350, "99%", "Client Satisfaction", Icons.sentiment_very_satisfied),

                  // 7. Small Wide
                  _buildBentoCard(6, isMobile ? totalWidth : col1, 160, "Hackathon", "Winner '21", Icons.lightbulb),

                  // 8. Small Wide
                  _buildBentoCard(7, isMobile ? totalWidth : col1, 160, "Open Source", "1K+ Stars", Icons.code),

                  // 9. Large Horizontal
                  _buildBentoCard(8, isMobile ? totalWidth : col2, 160, "UI/UX Consultant", "Fortune 500", Icons.business),

                  // 10. Final Accent Square
                  _buildBentoCard(9, isMobile ? totalWidth : col2, 180, "Available for Work", "Q3 2026", Icons.calendar_today, isOrange: true),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard(int index, double width, double height, String title, String sub, IconData icon, {bool isDark = false, bool isOrange = false}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)), // Sequential delay
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0, 1),
            child: child,
          ),
        );
      },
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isOrange ? const Color(0xFFF26A1B) : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: (isDark || isOrange) ? Colors.white : const Color(0xFFF26A1B), size: 24),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: height > 250 ? 28 : 20,
                fontFamily: 'gondens',
                fontWeight: FontWeight.bold,
                color: (isDark || isOrange) ? Colors.white : Colors.black,
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: (isDark || isOrange) ? Colors.white70 : Colors.black54,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}