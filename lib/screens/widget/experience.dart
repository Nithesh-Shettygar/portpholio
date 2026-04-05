import 'package:flutter/material.dart';

class ExperienceSection extends StatelessWidget {
  final double screenWidth;

  const ExperienceSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenWidth <= 800;
    final horizontalPadding = isMobile
        ? 15.0
        : (screenWidth > 900 ? screenWidth * 0.1 : 20.0);

    return Container(
      color: const Color(0xFF111111),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 120,
        horizontal: horizontalPadding,
      ),
      child: Column(
        children: [
          Text(
            'EXPERIENCE',
            style: TextStyle(
              fontSize: isMobile ? 32 : 50,
              fontFamily: 'gondens',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: isMobile ? 12 : 20,
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: RepaintBoundary(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: isMobile ? 10 : 120,
                      top: isMobile ? 10 : 0,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF26A1B).withOpacity(0.18),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(isMobile ? 30 : 60),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.07),
                            Colors.white.withOpacity(0.01),
                          ],
                        ),
                      ),
                      child: _buildCardContent(isMobile),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(bool isMobile) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: -20,
          top: -40,
          child: Text(
            '01',
            style: TextStyle(
              fontSize: isMobile ? 140 : 250,
              fontFamily: 'gondens',
              fontWeight: FontWeight.bold,
              height: 1,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2
                ..color = Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF26A1B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Text(
                    '2025 - PRESENT',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Text(
              'UI/UX & Frontend\nDeveloper.',
              style: TextStyle(
                fontSize: isMobile ? 34 : 64,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFF26A1B),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Company Name',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 24,
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 24 : 40),
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.only(left: 20),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0xFFF26A1B), width: 3),
                ),
              ),
              child: Text(
                'Designing intuitive, user-centric interfaces and translating them into responsive, high-performance applications. Bridging the gap between pure aesthetics and strict engineering.',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 18,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
