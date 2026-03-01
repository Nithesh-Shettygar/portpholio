import 'package:flutter/material.dart';

class ContactSection extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  const ContactSection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> with SingleTickerProviderStateMixin {
  bool isEmailHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = widget.screenWidth <= 800;

    // Dynamic sizing based on screen
    double titleSize = isMobile ? 60 : 130;
    double letterSpace = isMobile ? 5 : 10;
    
    // Calculate indents for the cascade effect
    double step2Indent = isMobile ? 20 : widget.screenWidth * 0.08;
    double step3Indent = isMobile ? 40 : widget.screenWidth * 0.16;

    return Container(
      color: const Color(0xFF111111),
      padding: EdgeInsets.fromLTRB(
        widget.screenWidth > 900 ? widget.screenWidth * 0.1 : 20,
        150,
        widget.screenWidth > 900 ? widget.screenWidth * 0.1 : 20,
        50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // INTRO TEXT WITH PULSE
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF26A1B),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF26A1B).withOpacity(0.6 * _pulseController.value),
                          blurRadius: 10 * _pulseController.value,
                          spreadRadius: 4 * _pulseController.value,
                        )
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Text(
                "GOT A PROJECT IN MIND?",
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // CASCADING TYPOGRAPHY
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LET'S BUILD",
                style: TextStyle(
                  fontSize: titleSize,
                  fontFamily: 'gondens',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 0.9, // Tighter line height
                  letterSpacing: letterSpace,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: step2Indent),
                child: Text(
                  "SOMETHING",
                  style: TextStyle(
                    fontSize: titleSize,
                    fontFamily: 'gondens',
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.15), // Ghost text effect
                    height: 0.9,
                    letterSpacing: letterSpace,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: step3Indent),
                child: Text(
                  "EXTRAORDINARY.",
                  style: TextStyle(
                    fontSize: titleSize,
                    fontFamily: 'gondens',
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF26A1B),
                    height: 0.9,
                    letterSpacing: letterSpace,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 120),
          Container(height: 1, width: double.infinity, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 80),

          // INTERACTIVE TEXT EMAIL BUTTON
          MouseRegion(
            onEnter: (_) => setState(() => isEmailHovered = true),
            onExit: (_) => setState(() => isEmailHovered = false),
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Email text with animated underline
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: isMobile ? 32 : 64,
                        fontFamily: 'gondens',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                        color: isEmailHovered ? Colors.white : Colors.white70,
                      ),
                      child: const Text("nitheshs829@gmail.com"), // <-- Update Email Here
                    ),
                    // Growing Underline
                    Positioned(
                      bottom: -10,
                      left: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutQuint,
                        height: 4,
                        // Expands based on text width roughly
                        width: isEmailHovered ? (isMobile ? 250 : 500) : 0, 
                        color: const Color(0xFFF26A1B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Sliding Arrow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutQuint,
                  transform: Matrix4.identity()..translate(isEmailHovered ? 20.0 : 0.0),
                  child: Opacity(
                    opacity: isEmailHovered ? 1.0 : 0.0,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: const Color(0xFFF26A1B),
                      size: isMobile ? 40 : 64,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 120),

          // FOOTER: SOCIALS & COPYRIGHT
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSocialLinks(),
                    const SizedBox(height: 40),
                    _buildCopyright(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCopyright(),
                    _buildSocialLinks(),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Wrap(
      spacing: 30,
      runSpacing: 15,
      children: [
        _HoverLink(text: "LINKEDIN", onTap: () {}),
        _HoverLink(text: "GITHUB", onTap: () {}),
        _HoverLink(text: "TWITTER", onTap: () {}),
      ],
    );
  }

  Widget _buildCopyright() {
    return Text(
      "© ${DateTime.now().year} NITHESH. ALL RIGHTS RESERVED.",
      style: TextStyle(
        fontFamily: 'Courier',
        fontSize: 12,
        color: Colors.white.withOpacity(0.4),
        letterSpacing: 1,
      ),
    );
  }
}

// Custom Hover Widget for Social Links
class _HoverLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _HoverLink({required this.text, required this.onTap});

  @override
  State<_HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<_HoverLink> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: isHovered ? const Color(0xFFF26A1B) : Colors.white,
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}