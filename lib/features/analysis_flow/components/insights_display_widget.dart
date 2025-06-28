import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/analysis_state.dart';

class InsightsDisplayWidget extends StatelessWidget {
  final AnalysisInsights insights;

  const InsightsDisplayWidget({
    super.key,
    required this.insights,
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
          // Primary insight
          _buildPrimaryInsight(),

          const SizedBox(height: 24),

          // Key findings
          _buildKeyFindings(),

          const SizedBox(height: 24),

          // Detailed analysis sections (if available from OpenAI)
          if (_hasDetailedAnalysis()) _buildDetailedAnalysis(),

          const SizedBox(height: 24),

          // Recommendations
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildPrimaryInsight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lightbulb,
                color: Color(0xFF667EEA),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Ana Değerlendirme',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF667EEA).withOpacity(0.2),
            ),
          ),
          child: Text(
            insights.primaryInsight,
            style: GoogleFonts.nunito(
              fontSize: 16,
              height: 1.6,
              color: const Color(0xFF2D3748),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildKeyFindings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.search,
                color: Colors.green.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Önemli Bulgular',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...insights.keyFindings.asMap().entries.map((entry) {
          final index = entry.key;
          final finding = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    finding,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      height: 1.5,
                      color: const Color(0xFF4A5568),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().slideX(delay: (200 + (index * 100)).ms);
        }),
      ],
    );
  }

  Widget _buildDetailedAnalysis() {
    final fullAnalysis =
        insights.detailedAnalysis['fullAnalysis'] as Map<String, dynamic>?;
    if (fullAnalysis == null) return const SizedBox.shrink();

    final analysis = fullAnalysis['analysis'] as Map<String, dynamic>?;
    if (analysis == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.psychology,
                color: Colors.purple.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Detaylı Analiz',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Emotional Signals
        if (analysis['emotional_signals'] != null)
          _buildAnalysisSection(
            'Duygusal Göstergeler',
            analysis['emotional_signals']['text'] ?? '',
            Icons.favorite,
            Colors.red,
          ),

        // Developmental Indicators
        if (analysis['developmental_indicators'] != null)
          _buildAnalysisSection(
            'Gelişim Göstergeleri',
            analysis['developmental_indicators']['text'] ?? '',
            Icons.trending_up,
            Colors.blue,
          ),

        // Symbolic Content
        if (analysis['symbolic_content'] != null)
          _buildAnalysisSection(
            'Sembolik İçerik',
            analysis['symbolic_content']['text'] ?? '',
            Icons.auto_awesome,
            Colors.orange,
          ),

        // Social and Family Context
        if (analysis['social_and_family_context'] != null)
          _buildAnalysisSection(
            'Sosyal ve Aile Bağlamı',
            analysis['social_and_family_context']['text'] ?? '',
            Icons.people,
            Colors.green,
          ),
      ],
    );
  }

  Widget _buildAnalysisSection(
      String title, String content, IconData icon, Color color) {
    if (content.isEmpty) return const SizedBox.shrink();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.nunito(
              fontSize: 14,
              height: 1.6,
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tips_and_updates,
                color: Colors.amber.shade700,
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
        const SizedBox(height: 16),
        ...insights.recommendations.asMap().entries.map((entry) {
          final index = entry.key;
          final recommendation = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.star,
                    color: Colors.amber.shade700,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      height: 1.5,
                      color: const Color(0xFF4A5568),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().slideX(delay: (500 + (index * 100)).ms);
        }),
      ],
    );
  }

  bool _hasDetailedAnalysis() {
    final fullAnalysis =
        insights.detailedAnalysis['fullAnalysis'] as Map<String, dynamic>?;
    return fullAnalysis != null && fullAnalysis['analysis'] != null;
  }
}
