import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationsWidget extends StatelessWidget {
  final List<String> recommendations;

  const RecommendationsWidget({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.recommend,
                  color: Colors.orange.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Öneriler',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Çocuğunuzla birlikte yapabileceğiniz aktiviteler',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
          ),

          const SizedBox(height: 20),

          // Recommendations list
          Expanded(
            child: ListView.builder(
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                return _buildRecommendationCard(
                  recommendations[index],
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String recommendation, int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];

    final icons = [
      Icons.palette,
      Icons.sports_esports,
      Icons.menu_book,
      Icons.music_note,
      Icons.sports_soccer,
      Icons.nature,
    ];

    final color = colors[index % colors.length];
    final icon = icons[index % icons.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Öneri ${index + 1}',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 12,
            ),
          ),
        ],
      ),
    ).animate().slideX(delay: (index * 100).ms);
  }
}
