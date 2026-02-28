import 'package:flutter/material.dart';

class ExperienceSection extends StatelessWidget {
  final double screenWidth;
  const ExperienceSection({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F2F2),
      padding: EdgeInsets.symmetric(
        vertical: 100,
        horizontal: screenWidth > 900 ? screenWidth * 0.2 : 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "EXPERIENCE",
            style: TextStyle(
              fontSize: 64,
              fontFamily: 'gondens',
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 80),
          _buildTimelineItem(
            role: "Flutter Developer Intern",
            company: "Tech Solutions",
            period: "2025 - Present",
            description: "Building immersive cross-platform applications with complex animations and structural integrity.",
            isLast: false,
          ),
          _buildTimelineItem(
            role: "UI/UX Student Designer",
            company: "Portfolio Projects",
            period: "2024 - 2025",
            description: "Crafting minimalist design systems and prototyping technical high-performance interfaces.",
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String role,
    required String company,
    required String period,
    required String description,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFF26A1B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.black12,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(period, style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, color: Color(0xFFF26A1B), fontSize: 14)),
                const SizedBox(height: 8),
                Text(role, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black)),
                Text(company, style: TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.6))),
                const SizedBox(height: 12),
                Text(description, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}