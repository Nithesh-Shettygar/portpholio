import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg

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

class _ContactSectionState extends State<ContactSection>
    with SingleTickerProviderStateMixin {
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
    double titleSize = isMobile
        ? (widget.screenWidth < 380 ? 44 : 52)
        : 130;
    double letterSpace = isMobile ? 2 : 10;

    // Calculate indents for the cascade effect
    double step2Indent = isMobile ? 12 : widget.screenWidth * 0.08;
    double step3Indent = isMobile ? 24 : widget.screenWidth * 0.16;

    return Container(
      color: const Color(0xFF111111),
      padding: EdgeInsets.fromLTRB(
        widget.screenWidth > 900 ? widget.screenWidth * 0.1 : 20,
        isMobile ? 90 : 150,
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
                          color: const Color(
                            0xFFF26A1B,
                          ).withOpacity(0.6 * _pulseController.value),
                          blurRadius: 10 * _pulseController.value,
                          spreadRadius: 4 * _pulseController.value,
                        ),
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
                  height: 0.9,
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
                    color: Colors.white.withOpacity(0.15),
                    height: 0.86,
                    letterSpacing: letterSpace,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: step3Indent),
                child: Text(
                  "EXTRAORDINARY.",
                  style: TextStyle(
                    fontSize: isMobile ? titleSize * 0.84 : titleSize,
                    fontFamily: 'gondens',
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF26A1B),
                    height: 0.86,
                    letterSpacing: letterSpace,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 60 : 120),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withOpacity(0.1),
          ),
          SizedBox(height: isMobile ? 45 : 80),

          // INTERACTIVE TEXT EMAIL BUTTON
          MouseRegion(
            onEnter: (_) => setState(() => isEmailHovered = true),
            onExit: (_) => setState(() => isEmailHovered = false),
            cursor: SystemMouseCursors.click,
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEmailText(isMobile),
                      const SizedBox(height: 14),
                      _buildEmailArrow(isMobile),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildEmailText(isMobile),
                      const SizedBox(width: 20),
                      _buildEmailArrow(isMobile),
                    ],
                  ),
          ),

          SizedBox(height: isMobile ? 70 : 120),

          // FOOTER: SOCIALS & COPYRIGHT
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSocialLinks(isMobile),
                    const SizedBox(height: 40),
                    _buildCopyright(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_buildCopyright(), _buildSocialLinks(isMobile)],
                ),
        ],
      ),
    );
  }

  Widget _buildEmailText(bool isMobile) {
    final emailText = AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        fontSize: isMobile ? 24 : 64,
        fontFamily: 'gondens',
        fontWeight: FontWeight.w600,
        letterSpacing: isMobile ? 1.2 : 4,
        color: isEmailHovered ? Colors.white : Colors.white70,
      ),
      child: const Text("nitheshs829@gmail.com"),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (isMobile)
          SizedBox(
            width: widget.screenWidth - 40,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: emailText,
            ),
          )
        else
          emailText,
        Positioned(
          bottom: -10,
          left: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuint,
            height: 4,
            width: isEmailHovered ? (isMobile ? 220 : 500) : 0,
            color: const Color(0xFFF26A1B),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailArrow(bool isMobile) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuint,
      transform: Matrix4.identity()..translate(isEmailHovered ? 20.0 : 0.0),
      child: Opacity(
        opacity: isEmailHovered ? 1.0 : 0.0,
        child: Icon(
          Icons.arrow_forward_rounded,
          color: const Color(0xFFF26A1B),
          size: isMobile ? 32 : 64,
        ),
      ),
    );
  }

  // --- UPDATED SOCIAL LINKS SECTION FOR SVG ---
  Widget _buildSocialLinks(bool isMobile) {
    const icons = [
      _HoverIconLink(
        svgPath: 'assets/icons/github.svg',
        url: "https://github.com/YOUR_PROFILE_HERE",
      ),
      _HoverIconLink(
        svgPath: 'assets/icons/linkedin.svg',
        url: "https://www.linkedin.com/in/YOUR_PROFILE_HERE",
      ),
      _HoverIconLink(
        svgPath: 'assets/icons/instagram.svg',
        url: "https://www.instagram.com/YOUR_PROFILE_HERE",
      ),
    ];

    if (isMobile) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _HoverIconLink(
            svgPath: 'assets/icons/github.svg',
            url: "https://github.com/YOUR_PROFILE_HERE",
          ),
          SizedBox(width: 25),
          _HoverIconLink(
            svgPath: 'assets/icons/linkedin.svg',
            url: "https://www.linkedin.com/in/YOUR_PROFILE_HERE",
          ),
          SizedBox(width: 25),
          _HoverIconLink(
            svgPath: 'assets/icons/instagram.svg',
            url: "https://www.instagram.com/YOUR_PROFILE_HERE",
          ),
        ],
      );
    }

    return Wrap(spacing: 25, runSpacing: 15, children: icons);
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

// --- UPDATED WIDGET FOR SVG HOVER & LAUNCHING ---
class _HoverIconLink extends StatefulWidget {
  final String svgPath;
  final String url;

  const _HoverIconLink({required this.svgPath, required this.url});

  @override
  State<_HoverIconLink> createState() => _HoverIconLinkState();
}

class _HoverIconLinkState extends State<_HoverIconLink> {
  bool isHovered = false;

  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch ${widget.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _launchUrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          // Slightly scale up the icon when hovered
          transform: Matrix4.identity()..scale(isHovered ? 1.2 : 1.0),
          // Ensure scaling happens from the center of the icon
          alignment: Alignment.center,
          child: SvgPicture.asset(
            widget.svgPath,
            width: 24,
            height: 24,
            // Uses colorFilter to apply the white/orange transition directly to the SVG shapes
            colorFilter: ColorFilter.mode(
              isHovered ? const Color(0xFFF26A1B) : Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
