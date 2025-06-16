import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DailyRecommendations extends StatelessWidget {
  final List<String> recommendations;

  const DailyRecommendations({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: recommendations.take(3).map((recommendation) {
        final index = recommendations.indexOf(recommendation);
        return Padding(
          padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
          child: _buildRecommendationCard(context, recommendation, index)
              .animate(delay: (index * 150).ms)
              .slideX(begin: -0.3, duration: 400.ms)
              .fadeIn(duration: 400.ms),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    String recommendation,
    int index,
  ) {
    final icons = [
      Icons.palette,
      Icons.emoji_emotions,
      Icons.lightbulb,
      Icons.favorite,
      Icons.star,
    ];

    final colors = [
      const Color(0xFF667EEA),
      const Color(0xFF38B2AC),
      const Color(0xFFED8936),
      const Color(0xFFE53E3E),
      const Color(0xFF9F7AEA),
    ];

    final icon = icons[index % icons.length];
    final color = colors[index % colors.length];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                recommendation,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: const Color(0xFF2D3748),
                  height: 1.4,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF718096),
            ),
          ],
        ),
      ),
    );
  }
}
