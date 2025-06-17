import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/models/drawing_analysis.dart';
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
      children: [
        // Show more analyses now (up to 5)
        ...analyses.take(5).map((analysis) {
          final index = analyses.indexOf(analysis);
          return Padding(
            padding: EdgeInsets.only(bottom: index < 4 ? 16 : 0),
            child: _buildEnhancedAnalysisCard(context, analysis)
                .animate(delay: (index * 100).ms)
                .slideX(begin: 0.3, duration: 300.ms)
                .fadeIn(duration: 300.ms),
          );
        }),

        // Show all analyses button if there are more
        if (analyses.length > 5) ...[
          const SizedBox(height: 16),
          _buildShowAllButton(context),
        ],
      ],
    );
  }

  Widget _buildEnhancedAnalysisCard(
      BuildContext context, DrawingAnalysis analysis) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          // Navigate to analysis details
          // Navigator.pushNamed(context, '/analysis-details', arguments: analysis.id);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with type and status
              Row(
                children: [
                  _buildTypeIcon(analysis.testType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.testType.displayName,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(analysis.uploadDate),
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: const Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(analysis.status),
                ],
              ),

              const SizedBox(height: 16),

              // Content based on status
              if (analysis.status == AnalysisStatus.completed) ...[
                // Thumbnail and insight
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThumbnail(analysis),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ana Değerlendirme',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF667EEA),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            analysis.primaryInsight,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: const Color(0xFF4A5568),
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Scores section
                _buildScoresSection(analysis),

                const SizedBox(height: 16),

                // Key findings
                if (analysis.keyFindings.isNotEmpty) ...[
                  Text(
                    'Önemli Bulgular',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF667EEA),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...analysis.keyFindings.take(3).map(
                        (finding) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 6, right: 8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF48BB78),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  finding,
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: const Color(0xFF4A5568),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ] else if (analysis.status == AnalysisStatus.processing) ...[
                // Processing state
                Row(
                  children: [
                    _buildThumbnail(analysis),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analiz Devam Ediyor',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Yapay zeka çiziminizi detaylı şekilde inceliyor...',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: const Color(0xFF718096),
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF92400E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Other states (pending, failed)
                Row(
                  children: [
                    _buildThumbnail(analysis),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _getStatusMessage(analysis.status),
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: const Color(0xFF718096),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Action row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (analysis.status == AnalysisStatus.completed) ...[
                    Text(
                      'Detayları Gör',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF667EEA),
                      ),
                    ),
                  ] else ...[
                    Text(
                      analysis.status.displayName,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF718096),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(DrawingTestType type) {
    IconData icon;
    Color color;

    switch (type) {
      case DrawingTestType.familyDrawing:
        icon = Icons.family_restroom;
        color = const Color(0xFF667EEA);
        break;
      case DrawingTestType.selfPortrait:
        icon = Icons.person;
        color = const Color(0xFF48BB78);
        break;
      case DrawingTestType.houseTreePerson:
        icon = Icons.home;
        color = const Color(0xFFED8936);
        break;
      case DrawingTestType.narrativeDrawing:
        icon = Icons.auto_stories;
        color = const Color(0xFF9F7AEA);
        break;
      case DrawingTestType.emotionalStates:
        icon = Icons.psychology;
        color = const Color(0xFFECC94B);
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildScoresSection(DrawingAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildScoreItem(
              'Duygusal',
              analysis.emotionalScore,
              const Color(0xFF48BB78),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: const Color(0xFFE2E8F0),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: _buildScoreItem(
              'Yaratıcılık',
              analysis.creativityScore,
              const Color(0xFF667EEA),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: const Color(0xFFE2E8F0),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Expanded(
            child: _buildScoreItem(
              'Gelişim',
              analysis.developmentScore,
              const Color(0xFFED8936),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          score.toString(),
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 10,
            color: const Color(0xFF718096),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildShowAllButton(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: () {
          // Navigate to all analyses page
          // Navigator.pushNamed(context, '/all-analyses');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tüm Analizleri Gör (${analyses.length})',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF667EEA),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward,
                color: Color(0xFF667EEA),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusMessage(AnalysisStatus status) {
    switch (status) {
      case AnalysisStatus.pending:
        return 'Analiz sıraya alındı, yakında başlayacak';
      case AnalysisStatus.processing:
        return 'Yapay zeka çiziminizi analiz ediyor...';
      case AnalysisStatus.failed:
        return 'Analiz başarısız oldu, lütfen tekrar deneyin';
      case AnalysisStatus.completed:
        return 'Analiz tamamlandı';
    }
  }

  Widget _buildThumbnail(DrawingAnalysis analysis) {
    // Debug: Log the image URL
    debugPrint(
        '📸 Image URL for analysis ${analysis.id}: ${analysis.imageUrl}');

    // Check if URL is a valid Firebase Storage URL
    final isValidUrl = analysis.imageUrl.isNotEmpty &&
        (analysis.imageUrl.startsWith('https://') ||
            analysis.imageUrl.startsWith('http://')) &&
        !analysis.imageUrl.startsWith('mock_');

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
        child: isValidUrl
            ? CachedNetworkImage(
                imageUrl: analysis.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildThumbnailPlaceholder(),
                errorWidget: (context, url, error) {
                  debugPrint('❌ Error loading image: $error');
                  return _buildThumbnailPlaceholder();
                },
              )
            : _buildThumbnailPlaceholder(showMockIcon: true),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder({bool showMockIcon = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA).withOpacity(0.1),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: showMockIcon
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: const Color(0xFF667EEA),
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  'Çizim',
                  style: GoogleFonts.nunito(
                    fontSize: 8,
                    color: const Color(0xFF667EEA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : const Icon(
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
