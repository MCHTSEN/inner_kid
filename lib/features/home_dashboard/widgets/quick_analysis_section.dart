import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuickAnalysisSection extends StatelessWidget {
  const QuickAnalysisSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildAnalysisButton(
            context: context,
            icon: Icons.camera_alt,
            title: 'Fotoğraf Çek',
            subtitle: 'Yeni çizim çek',
            color: const Color(0xFF667EEA),
            onTap: () {
              // Navigate to camera
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAnalysisButton(
            context: context,
            icon: Icons.photo_library,
            title: 'Galeriden Seç',
            subtitle: 'Var olan çizim',
            color: const Color(0xFF38B2AC),
            onTap: () {
              // Navigate to gallery
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: const Color(0xFF718096),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(delay: 200.ms, duration: 300.ms).fadeIn(duration: 300.ms);
  }
}
