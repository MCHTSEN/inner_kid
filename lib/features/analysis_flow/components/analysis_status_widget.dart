import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../models/analysis_state.dart';

class AnalysisStatusWidget extends StatelessWidget {
  final AnalysisStatus status;

  const AnalysisStatusWidget({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(status);

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
      child: Row(
        children: [
          // Status icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusData.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusData.icon,
              color: statusData.color,
              size: 24,
            ),
          ).animate().scale(delay: 100.ms, curve: Curves.elasticOut),

          const SizedBox(width: 16),

          // Status info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusData.title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ).animate().slideX(delay: 200.ms),
                const SizedBox(height: 4),
                Text(
                  statusData.description,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: const Color(0xFF718096),
                  ),
                ).animate().slideX(delay: 300.ms),
              ],
            ),
          ),

          // Animation indicator for active states
          if (status == AnalysisStatus.uploading ||
              status == AnalysisStatus.analyzing) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(statusData.color),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ],
      ),
    );
  }

  _StatusData _getStatusData(AnalysisStatus status) {
    switch (status) {
      case AnalysisStatus.idle:
        return _StatusData(
          icon: Icons.hourglass_empty,
          title: 'Hazırlanıyor',
          description: 'Analiz süreci başlatılıyor',
          color: const Color(0xFF718096),
        );

      case AnalysisStatus.uploading:
        return _StatusData(
          icon: Icons.cloud_upload,
          title: 'Görsel Yükleniyor',
          description: 'Çiziminiz güvenli şekilde sunucuya yükleniyor',
          color: AppTheme.primaryColor,
        );

      case AnalysisStatus.analyzing:
        return _StatusData(
          icon: Icons.psychology,
          title: 'AI Analizi',
          description: 'Yapay zeka çiziminizi detaylı şekilde inceliyor',
          color: AppTheme.primaryColor,
        );

      case AnalysisStatus.completed:
        return _StatusData(
          icon: Icons.check_circle,
          title: 'Tamamlandı',
          description: 'Analiz başarıyla tamamlandı',
          color: Colors.green,
        );

      case AnalysisStatus.failed:
        return _StatusData(
          icon: Icons.error,
          title: 'Başarısız',
          description: 'Analiz sırasında bir hata oluştu',
          color: Colors.red,
        );

      case AnalysisStatus.cancelled:
        return _StatusData(
          icon: Icons.cancel,
          title: 'İptal Edildi',
          description: 'Analiz işlemi iptal edildi',
          color: Colors.orange,
        );
    }
  }
}

class _StatusData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _StatusData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
