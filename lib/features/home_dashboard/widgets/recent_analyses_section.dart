import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:inner_kid/core/models/drawing_analysis.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class RecentAnalysesSection extends StatelessWidget {
  final List<DrawingAnalysis> analyses;

  const RecentAnalysesSection({
    super.key,
    required this.analyses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: analyses.take(3).map((analysis) {
        final index = analyses.indexOf(analysis);
        return Padding(
          padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
          child: _buildAnalysisCard(context, analysis)
              .animate(delay: (index * 100).ms)
              .slideX(begin: 0.3, duration: 300.ms)
              .fadeIn(duration: 300.ms),
        );
      }).toList(),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, DrawingAnalysis analysis) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to analysis details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Drawing thumbnail
              _buildThumbnail(analysis),
              const SizedBox(width: 16),

              // Analysis info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            analysis.testType.displayName,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        _buildStatusBadge(analysis.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(analysis.uploadDate),
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    if (analysis.status == AnalysisStatus.completed) ...[
                      const SizedBox(height: 8),
                      Text(
                        analysis.primaryInsight,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: const Color(0xFF4A5568),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow icon
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF718096),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(DrawingAnalysis analysis) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF7FAFC),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: analysis.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildThumbnailPlaceholder(),
          errorWidget: (context, url, error) => _buildThumbnailPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF718096),
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge(AnalysisStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case AnalysisStatus.completed:
        backgroundColor = const Color(0xFFCCF7ED);
        textColor = const Color(0xFF047857);
        icon = Icons.check_circle_outline;
        break;
      case AnalysisStatus.processing:
        backgroundColor = const Color(0xFFFEEBC8);
        textColor = const Color(0xFF92400E);
        icon = Icons.refresh;
        break;
      case AnalysisStatus.pending:
        backgroundColor = const Color(0xFFDBE4FF);
        textColor = const Color(0xFF1E40AF);
        icon = Icons.schedule;
        break;
      case AnalysisStatus.failed:
        backgroundColor = const Color(0xFFFECDCA);
        textColor = const Color(0xFFB91C1C);
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }
}
