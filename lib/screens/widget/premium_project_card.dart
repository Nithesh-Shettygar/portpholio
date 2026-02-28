import 'package:flutter/material.dart';

class PremiumProjectCard extends StatefulWidget {
  final int index;
  const PremiumProjectCard({super.key, required this.index});

  @override
  State<PremiumProjectCard> createState() => _PremiumProjectCardState();
}

class _PremiumProjectCardState extends State<PremiumProjectCard> {
  bool isHovered = false;

  final List<String> projectNames = [
    "AERO\nFLIGHT",
    "ECLIPSE\nSERIES",
    "LUNAR\nOPTICS",
    "SOLAR\nFLARE",
    "NOVA\nGLASS",
    "ZENITH\nXR",
    "PULSE\nAR",
    "NEXUS\nPRO"
  ];

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 170, 
        height: 260, 
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black, 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(
            color: isHovered ? const Color(0xFFF26A1B) : Colors.white, 
            width: 3.0, 
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered ? const Color(0xFFF26A1B).withOpacity(0.4) : Colors.black.withOpacity(0.8), 
              blurRadius: isHovered ? 40 : 30,
              offset: isHovered ? const Offset(0, 0) : const Offset(0, 15),
              spreadRadius: isHovered ? 5 : -5,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Glass reflection gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.3, 0.3, 1.0],
                      colors: [
                        Colors.white.withOpacity(isHovered ? 0.20 : 0.10), 
                        Colors.white.withOpacity(isHovered ? 0.05 : 0.02),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              // Positioned.fill ensures the Column takes up the whole card height
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // TOP ROW
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: isHovered ? const Color(0xFFF26A1B) : Colors.white70,
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                            child: const Text("VIEW\nDETAILS ↗"),
                          ),
                          Text(
                            "0${widget.index + 1}",
                            style: TextStyle(
                              color: isHovered ? const Color(0xFFF26A1B) : Colors.white,
                              fontFamily: 'gondens', 
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                      
                      // Spacer pushes the text down into the middle
                      const Spacer(),
                      
                      // CENTER AREA: Project Name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Small decorative line
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: isHovered ? 40 : 20,
                            height: 3,
                            color: isHovered ? const Color(0xFFF26A1B) : Colors.white,
                            margin: const EdgeInsets.only(bottom: 12),
                          ),
                          Text(
                            projectNames[widget.index % projectNames.length],
                            textAlign: TextAlign.center, // Centers multi-line text perfectly
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      
                      // Spacer pushes the text up, perfectly balancing it in the center
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}