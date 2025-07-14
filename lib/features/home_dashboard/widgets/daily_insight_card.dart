import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/drawing_analysis.dart';

class DailyInsightCard extends StatelessWidget {
  final String insight;
  final List<DrawingAnalysis> recentAnalyses;

  const DailyInsightCard({
    super.key,
    required this.insight,
    required this.recentAnalyses,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = _calculateMetrics();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Günlük İçgörü',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTodayDateString(),
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            insight,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Analysis summary
          if (recentAnalyses.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Colors.white.withOpacity(0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${recentAnalyses.length} analiz • ${_getCompletedCount()} tamamlandı',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.emoji_emotions,
                  label: 'Duygusal',
                  value: metrics['emotional']!,
                  trend: _getTrend('emotional'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.palette,
                  label: 'Yaratıcılık',
                  value: metrics['creativity']!,
                  trend: _getTrend('creativity'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.trending_up,
                  label: 'Gelişim',
                  value: metrics['development']!,
                  trend: _getTrend('development'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: -0.1, duration: 400.ms).fadeIn(duration: 400.ms);
  }

  Map<String, String> _calculateMetrics() {
    final completedAnalyses = recentAnalyses
        .where((a) => a.status == AnalysisStatus.completed)
        .toList();

    if (completedAnalyses.isEmpty) {
      return {
        'emotional': '--',
        'creativity': '--',
        'development': '--',
      };
    }

    final avgEmotional =
        completedAnalyses.map((a) => a.emotionalScore).reduce((a, b) => a + b) /
            completedAnalyses.length;

    final avgCreativity = completedAnalyses
            .map((a) => a.creativityScore)
            .reduce((a, b) => a + b) /
        completedAnalyses.length;

    final avgDevelopment = completedAnalyses
            .map((a) => a.developmentScore)
            .reduce((a, b) => a + b) /
        completedAnalyses.length;

    return {
      'emotional': (avgEmotional / 10).toStringAsFixed(1),
      'creativity': (avgCreativity / 10).toStringAsFixed(1),
      'development': (avgDevelopment / 10).toStringAsFixed(1),
    };
  }

  int _getCompletedCount() {
    return recentAnalyses
        .where((a) => a.status == AnalysisStatus.completed)
        .length;
  }

  String _getTrend(String metric) {
    final completedAnalyses = recentAnalyses
        .where((a) => a.status == AnalysisStatus.completed)
        .toList();

    if (completedAnalyses.length < 2) return '';

    // Get recent and older scores
    final recentScore = _getScoreByMetric(completedAnalyses.first, metric);
    final olderScore = _getScoreByMetric(completedAnalyses.last, metric);

    if (recentScore > olderScore) return '↗';
    if (recentScore < olderScore) return '↘';
    return '→';
  }

  int _getScoreByMetric(DrawingAnalysis analysis, String metric) {
    switch (metric) {
      case 'emotional':
        return analysis.emotionalScore;
      case 'creativity':
        return analysis.creativityScore;
      case 'development':
        return analysis.developmentScore;
      default:
        return 0;
    }
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (trend.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  trend,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return '${now.day} ${months[now.month - 1]}';
  }
}
