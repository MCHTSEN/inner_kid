import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DailyInsightCard extends StatelessWidget {
  final String insight;

  const DailyInsightCard({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.emoji_emotions,
                  label: 'Duygusal',
                  value: '8.5',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.palette,
                  label: 'Yaratıcılık',
                  value: '9.2',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  icon: Icons.trending_up,
                  label: 'Gelişim',
                  value: '7.8',
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: -0.1, duration: 400.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String label,
    required String value,
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
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
