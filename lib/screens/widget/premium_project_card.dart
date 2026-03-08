import 'package:flutter/material.dart';
import 'dart:ui';

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

  // Mock data for the popup details
  final List<String> projectDescriptions = [
    "A next-generation flight tracking and aerodynamics visualization dashboard. Built for high-performance data parsing in real-time.",
    "A dark-mode exclusive fin-tech dashboard prioritizing user privacy and sleek data representation.",
    "E-commerce platform for high-end optical gear. Features immersive 3D product rendering and AR try-ons.",
    "Solar energy management system interface. Tracks output, predicts weather impact, and manages grid distribution.",
    "Smart-glass OS interface prototype. Focuses on minimal eye-strain and ultra-fast glanceable information.",
    "Extended Reality spatial computing environment for architects to visualize structures before building.",
    "Augmented reality fitness application that tracks heart rate and overlays biometrics into the user's field of view.",
    "Professional networking hub for creatives. Features seamless portfolio integrations and secure messaging."
  ];

  final List<List<String>> techStacks = [
    ["Flutter", "WebGL", "Firebase"],
    ["React", "Node.js", "MongoDB"],
    ["Flutter", "Three.js", "ARCore"],
    ["Vue.js", "Python", "AWS"],
    ["Flutter", "C++", "TensorFlow"],
    ["Unity", "C#", "Oculus SDK"],
    ["Swift", "ARKit", "HealthKit"],
    ["Flutter", "Supabase", "Stripe"]
  ];

  void _showProjectDetails(BuildContext context) {
    final title = projectNames[widget.index % projectNames.length].replaceAll('\n', ' ');
    final description = projectDescriptions[widget.index % projectDescriptions.length];
    final tags = techStacks[widget.index % techStacks.length];

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black87, // Darkens the background heavily
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF26A1B).withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF26A1B).withOpacity(0.2),
                    blurRadius: 50,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Title and Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'gondens',
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                            height: 1.1,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white54, size: 32),
                        hoverColor: Colors.white12,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Decorative Divider
                  Container(
                    width: 60,
                    height: 4,
                    color: const Color(0xFFF26A1B),
                  ),
                  const SizedBox(height: 30),

                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Tech Stack Tags
                  Text(
                    "TECH STACK",
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 50),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: const BorderSide(color: Color(0xFFF26A1B), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: const Color(0xFFF26A1B),
                      ),
                      child: const Text(
                        "VIEW CASE STUDY →",
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      // Creates a smooth pop-in animation for the dialog
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack, // Gives a slight bounce effect
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: true,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      // Wrap AnimatedContainer in GestureDetector to handle clicks
      child: GestureDetector(
        onTap: () => _showProjectDetails(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: 200,
          height: 260,
          transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.index % 2 == 0
                  ? [
                      const Color(0xFFFFFFFF), // Light white
                      const Color(0xFFF0F0F0), // Medium white
                      const Color(0xFFE0E0E0), // Dark white
                      const Color(0xFFCCCCCC), // Darker white
                    ]
                  : [
                      const Color(0xFF333333), // Light black
                      const Color(0xFF1a1a1a), // Medium black
                      const Color(0xFF0a0a0a), // Dark black
                      const Color(0xFF000000), // Darker black
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHovered ? const Color(0xFFF26A1B) : (widget.index % 2 == 0 ? const Color(0xFF333333) : const Color(0xFFCCCCCC)),
              width: 10,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: isHovered ? 25 : 20,
                offset: isHovered ? const Offset(0, 6) : const Offset(0, 10),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.35, 0.7, 1.0],
                        colors: [
                          Colors.white.withOpacity(isHovered ? 0.30 : 0.20),
                          Colors.white.withOpacity(isHovered ? 0.12 : 0.06),
                          Colors.transparent,
                          Colors.black.withOpacity(isHovered ? 0.12 : 0.08),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}