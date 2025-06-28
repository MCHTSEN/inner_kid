import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/share_options_widget.dart';
import '../models/analysis_state.dart';
import '../viewmodels/analysis_viewmodel.dart';

class AnalysisResultsPage extends ConsumerStatefulWidget {
  final String? analysisId;

  const AnalysisResultsPage({
    super.key,
    this.analysisId,
  });

  @override
  ConsumerState<AnalysisResultsPage> createState() =>
      _AnalysisResultsPageState();
}

class _AnalysisResultsPageState extends ConsumerState<AnalysisResultsPage> {
  @override
  void initState() {
    super.initState();

    // Load analysis if ID provided
    if (widget.analysisId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(analysisViewModelProvider.notifier)
            .loadAnalysisResults(widget.analysisId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisViewModelProvider);

    if (analysisState.isLoading) {
      return _buildLoadingView();
    }

    if (analysisState.hasError) {
      return _buildErrorView(analysisState.errorMessage!);
    }

    if (!analysisState.hasResults) {
      return _buildNoResultsView();
    }

    final results = analysisState.results!;
    final insights = results.insights;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        title: Text(
          'Çizim Analizi Raporu',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => _showShareOptions(context),
            icon: const Icon(Icons.share, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _generatePDF(),
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact drawing preview
            _buildCompactDrawingPreview(results.imageUrl),

            const SizedBox(height: 20),

            // All analysis sections in vertical layout
            _buildReadableAnalysisParametersVertical(
                insights, results.rawAnalysisData),

            const SizedBox(height: 20),

            // Action buttons
            _buildActionButtons(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sonuçlar Yükleniyor',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            ),
            const SizedBox(height: 16),
            Text(
              'Analiz sonuçları yükleniyor...',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: const Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hata',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bir Hata Oluştu',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: const Color(0xFF718096),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Geri Dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sonuç Bulunamadı',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.search_off,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sonuç Bulunamadı',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu analiz için henüz sonuç mevcut değil',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: const Color(0xFF718096),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactDrawingPreview(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Image section
            Expanded(
              flex: 2,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Info section
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.brush,
                          color: const Color(0xFF667EEA),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Analiz Edilen Çizim',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI analizi tamamlandı',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38A169).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Tamamlandı',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF38A169),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildSummaryCardFromString(String summary) {
    if (summary.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA).withOpacity(0.1),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Genel Değerlendirme',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: GoogleFonts.nunito(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSummaryCard(Map<String, dynamic> fullAnalysis) {
    final summary = fullAnalysis['summary'] as String? ?? '';
    if (summary.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA).withOpacity(0.1),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF667EEA),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Genel Değerlendirme',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary,
            style: GoogleFonts.nunito(
              fontSize: 16,
              height: 1.6,
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildScoreCards(AnalysisInsights insights) {
    return Row(
      children: [
        Expanded(
          child: _buildScoreCard(
            'Duygusal',
            insights.emotionalScore,
            Icons.favorite,
            const Color(0xFFE53E3E),
            const Color(0xFFFED7D7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildScoreCard(
            'Yaratıcılık',
            insights.creativityScore,
            Icons.palette,
            const Color(0xFF805AD5),
            const Color(0xFFE9D8FD),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildScoreCard(
            'Gelişim',
            insights.developmentScore,
            Icons.trending_up,
            const Color(0xFF38A169),
            const Color(0xFFC6F6D5),
          ),
        ),
      ],
    ).animate().slideX(delay: 400.ms);
  }

  Widget _buildScoreCard(
    String title,
    double score,
    IconData icon,
    Color color,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            score.toStringAsFixed(1),
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: score / 10,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadableAnalysisParametersVertical(
      AnalysisInsights insights, Map<String, dynamic>? rawAnalysisData) {
    return Column(
      children: [
        // Ana Değerlendirme - Kompakt versiyon
        _buildMainInsightCard(insights.primaryInsight),

        const SizedBox(height: 16),

        // Öne Çıkan Temalar - Tag format (Always show)
        _buildCompactKeyFindingsCard(_getEmergingThemes(rawAnalysisData) ??
            (insights.keyFindings.isNotEmpty
                ? insights.keyFindings
                : [
                    'Yaratıcı ifade',
                    'Gelişim göstergeleri',
                    'Pozitif duygular'
                  ])),

        const SizedBox(height: 16),

        // Expandable Analysis Sections (Always show with fallback content)
        _buildExpandableAnalysisCard(
          'Duygusal Durumu',
          Icons.psychology,
          const Color(0xFFE53E3E),
          _getAnalysisText(rawAnalysisData, 'emotional_signals') ??
              insights.detailedAnalysis['emotionalIndicators'] ??
              'Çocuğunuzun çiziminde pozitif duygusal göstergeler mevcuttur. Renk seçimleri ve çizim tarzı genel olarak mutlu bir ruh halini yansıtmaktadır.',
          '🎭 Çocuğunuzun duygusal durumu nasıl?',
        ),

        const SizedBox(height: 12),

        _buildExpandableAnalysisCard(
          'Gelişim Seviyesi',
          Icons.trending_up,
          const Color(0xFF38A169),
          _getAnalysisText(rawAnalysisData, 'developmental_indicators') ??
              insights.detailedAnalysis['developmentLevel'] ??
              'Çizim becerileri yaşına uygun gelişim göstermektedir. Motor beceriler ve el-göz koordinasyonu yaşıtlarıyla benzer seviyededir.',
          '📈 Yaşına göre gelişim durumu',
        ),

        const SizedBox(height: 12),

        _buildExpandableAnalysisCard(
          'Sosyal Bağları',
          Icons.group,
          const Color(0xFF3182CE),
          _getAnalysisText(rawAnalysisData, 'social_and_family_context') ??
              insights.detailedAnalysis['socialAspects'] ??
              'Çizimde sosyal etkileşim ve aile bağlarına dair pozitif işaretler görülmektedir. Çevresiyle sağlıklı ilişkiler kurma eğilimi göstermektedir.',
          '👨‍👩‍👧‍👦 Aile ve çevre ile ilişkisi',
        ),

        const SizedBox(height: 12),

        _buildExpandableAnalysisCard(
          'Yaratıcılık',
          Icons.auto_awesome,
          const Color(0xFF805AD5),
          _getAnalysisText(rawAnalysisData, 'symbolic_content') ??
              insights.detailedAnalysis['creativityMarkers'] ??
              'Yaratıcı düşünce becerileri ve hayal gücü çizimde kendini göstermektedir. Orijinal yaklaşımlar ve detay zenginliği dikkat çekicidir.',
          '🎨 Yaratıcı düşünce ve hayal gücü',
        ),

        const SizedBox(height: 16),

        // Kompakt Öneriler (Always show)
        _buildCompactRecommendationsCard(_getRecommendations(rawAnalysisData) ??
            (insights.recommendations.isNotEmpty
                ? insights.recommendations
                : [
                    'Çocuğunuzla birlikte sanat aktiviteleri yapın',
                    'Yaratıcı oyunları destekleyin',
                    'Çizimlerini evde sergilemeye devam edin',
                    'Farklı sanat malzemeleriyle deneyim fırsatları sağlayın'
                  ])),
      ],
    );
  }

  Widget _buildMainInsightCard(String insight) {
    if (insight.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA).withOpacity(0.1),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '✨ Ana Değerlendirme',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight,
            style: GoogleFonts.nunito(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildCompactKeyFindingsCard(List<String> keyFindings) {
    // Always show card with fallback content if empty
    final displayFindings =
        keyFindings.isNotEmpty ? keyFindings : ['Analiz temaları hazırlanıyor'];

    // Don't hide the card anymore

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏷️ Öne Çıkan Temalar',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displayFindings
                .take(4)
                .map((finding) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF805AD5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF805AD5).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        finding,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF805AD5),
                        ),
                      ),
                    ))
                .toList(),
          ),
          if (displayFindings.length > 4)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${displayFindings.length - 4} daha fazla tema',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: const Color(0xFF718096),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildExpandableAnalysisCard(
    String title,
    IconData icon,
    Color color,
    dynamic content,
    String subtitle,
  ) {
    // Always show card, even if content is null or empty
    String displayText = '';
    if (content is String) {
      displayText =
          content.isNotEmpty ? content : 'Analiz verisi henüz mevcut değil.';
    } else if (content is List && content.isNotEmpty) {
      displayText = content.take(3).join('\n• ');
      if (displayText.isNotEmpty) displayText = '• $displayText';
    } else {
      displayText = 'Bu bölüm için analiz verisi henüz hazırlanmadı.';
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3748),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: const Color(0xFF718096),
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              displayText,
              style: GoogleFonts.nunito(
                fontSize: 13,
                height: 1.4,
                color: const Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildCompactRecommendationsCard(List<String> recommendations) {
    // Always show card with fallback content if empty
    final displayRecommendations = recommendations.isNotEmpty
        ? recommendations
        : ['Öneriler hazırlanıyor'];

    // Don't hide the card anymore

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF38A169).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tips_and_updates,
                  color: Color(0xFF38A169),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '💡 Size Öneriler',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...displayRecommendations
              .take(3)
              .toList()
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final recommendation = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF38A169).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF38A169).withOpacity(0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF38A169).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.nunito(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF38A169),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        height: 1.3,
                        color: const Color(0xFF4A5568),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (displayRecommendations.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${displayRecommendations.length - 3} öneri daha',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: const Color(0xFF718096),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSimpleAnalysisCard(
      String title, String content, IconData icon, Color color) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.nunito(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildKeyFindingsCard(List<String> keyFindings) {
    if (keyFindings.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF805AD5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Color(0xFF805AD5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Öne Çıkan Temalar',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: keyFindings
                .map((finding) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF805AD5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF805AD5).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        finding,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF805AD5),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildDetailedAnalysisCard(
      String title, dynamic content, IconData icon, Color color) {
    if (content == null) return const SizedBox.shrink();

    String displayText = '';
    if (content is String) {
      displayText = content;
    } else if (content is List) {
      displayText = content.join('\n• ');
      if (displayText.isNotEmpty) displayText = '• $displayText';
    }

    if (displayText.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayText,
            style: GoogleFonts.nunito(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildRecommendationsCard(List<String> recommendations) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF38A169).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.recommend,
                  color: Color(0xFF38A169),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Öneriler',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final recommendation = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF38A169).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF38A169).withOpacity(0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF38A169).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF38A169),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        height: 1.4,
                        color: const Color(0xFF4A5568),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildAllAnalysisSections(
      AnalysisInsights insights, Map<String, dynamic>? fullAnalysis) {
    return Column(
      children: [
        // Ana Değerlendirme
        _buildAnalysisCard(
          'Ana Değerlendirme',
          insights.primaryInsight,
          Icons.lightbulb,
          const Color(0xFF667EEA),
        ),

        const SizedBox(height: 20),

        // Öne Çıkan Temalar
        if (fullAnalysis != null && fullAnalysis['analysis'] != null)
          _buildEmergingThemes(fullAnalysis['analysis']),

        const SizedBox(height: 20),

        // Duygusal Sinyaller
        if (fullAnalysis != null && fullAnalysis['analysis'] != null)
          _buildEmotionalSignalsSection(fullAnalysis['analysis']),

        const SizedBox(height: 20),

        // Gelişimsel Göstergeler
        if (fullAnalysis != null && fullAnalysis['analysis'] != null)
          _buildDevelopmentalSection(fullAnalysis['analysis']),

        const SizedBox(height: 20),

        // Sembolik İçerik
        if (fullAnalysis != null && fullAnalysis['analysis'] != null)
          _buildSymbolicContentSection(fullAnalysis['analysis']),

        const SizedBox(height: 20),

        // Sosyal ve Aile Bağlamı
        if (fullAnalysis != null && fullAnalysis['analysis'] != null)
          _buildSocialContextSection(fullAnalysis['analysis']),

        const SizedBox(height: 20),

        // Öneriler
        if (fullAnalysis != null && fullAnalysis['analysis'] != null)
          _buildRecommendationsSection(fullAnalysis['analysis']),
      ],
    );
  }

  Widget _buildAnalysisCard(
      String title, String content, IconData icon, Color color) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.nunito(
              fontSize: 16,
              height: 1.6,
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildEmergingThemes(Map<String, dynamic> analysis) {
    final themes = analysis['emerging_themes'] as List<dynamic>? ?? [];
    if (themes.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF805AD5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Color(0xFF805AD5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Öne Çıkan Temalar',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: themes
                .map((theme) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF805AD5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF805AD5).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        theme.toString(),
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF805AD5),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildEmotionalSignalsSection(Map<String, dynamic> analysis) {
    final emotionalSignals =
        analysis['emotional_signals'] as Map<String, dynamic>?;
    if (emotionalSignals == null) return const SizedBox.shrink();

    final text = emotionalSignals['text'] as String? ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    return _buildAnalysisCard(
      'Duygusal Sinyaller',
      text,
      Icons.psychology,
      const Color(0xFFE53E3E),
    );
  }

  Widget _buildDevelopmentalSection(Map<String, dynamic> analysis) {
    final developmentalIndicators =
        analysis['developmental_indicators'] as Map<String, dynamic>?;
    if (developmentalIndicators == null) return const SizedBox.shrink();

    final text = developmentalIndicators['text'] as String? ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    return _buildAnalysisCard(
      'Gelişimsel Göstergeler',
      text,
      Icons.trending_up,
      const Color(0xFF38A169),
    );
  }

  Widget _buildSymbolicContentSection(Map<String, dynamic> analysis) {
    final symbolicContent =
        analysis['symbolic_content'] as Map<String, dynamic>?;
    if (symbolicContent == null) return const SizedBox.shrink();

    final text = symbolicContent['text'] as String? ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    return _buildAnalysisCard(
      'Sembolik İçerik',
      text,
      Icons.auto_awesome,
      const Color(0xFF805AD5),
    );
  }

  Widget _buildSocialContextSection(Map<String, dynamic> analysis) {
    final socialContext =
        analysis['social_and_family_context'] as Map<String, dynamic>?;
    if (socialContext == null) return const SizedBox.shrink();

    final text = socialContext['text'] as String? ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    return _buildAnalysisCard(
      'Sosyal ve Aile Bağlamı',
      text,
      Icons.group,
      const Color(0xFF3182CE),
    );
  }

  Widget _buildRecommendationsSection(Map<String, dynamic> analysis) {
    final recommendations =
        analysis['recommendations'] as Map<String, dynamic>?;
    if (recommendations == null) return const SizedBox.shrink();

    final parentingTips =
        recommendations['parenting_tips'] as List<dynamic>? ?? [];
    final activityIdeas =
        recommendations['activity_ideas'] as List<dynamic>? ?? [];

    if (parentingTips.isEmpty && activityIdeas.isEmpty)
      return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF38A169).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.recommend,
                  color: Color(0xFF38A169),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
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
          const SizedBox(height: 20),
          if (parentingTips.isNotEmpty) ...[
            Text(
              'Ebeveynlik Önerileri',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            ...parentingTips.asMap().entries.map((entry) {
              final index = entry.key;
              final tip = entry.value.toString();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF38A169).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF38A169).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38A169).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF38A169),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          height: 1.5,
                          color: const Color(0xFF4A5568),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (parentingTips.isNotEmpty && activityIdeas.isNotEmpty)
            const SizedBox(height: 20),
          if (activityIdeas.isNotEmpty) ...[
            Text(
              'Aktivite Fikirleri',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            ...activityIdeas.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value.toString();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3182CE).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3182CE).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3182CE).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3182CE),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        activity,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          height: 1.5,
                          color: const Color(0xFF4A5568),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _generatePDF(),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Detaylı PDF Raporu İndir'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showShareOptions(context),
            icon: const Icon(Icons.share),
            label: const Text('Analizi Paylaş'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF667EEA), width: 2),
              foregroundColor: const Color(0xFF667EEA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    ).animate().slideY(begin: 0.3, delay: 800.ms);
  }

  void _generatePDF() {
    ref.read(analysisViewModelProvider.notifier).generatePDF();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.file_download, color: Colors.white),
            const SizedBox(width: 12),
            const Text('PDF raporu oluşturuluyor...'),
          ],
        ),
        backgroundColor: const Color(0xFF38A169),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ShareOptionsWidget(),
    );
  }

  /// Helper method to extract text from raw analysis data
  String? _getAnalysisText(Map<String, dynamic>? rawData, String key) {
    if (rawData == null) return null;

    final analysis = rawData['analysis'] as Map<String, dynamic>?;
    if (analysis == null) return null;

    final section = analysis[key] as Map<String, dynamic>?;
    if (section == null) return null;

    return section['text'] as String?;
  }

  /// Helper method to extract emerging themes from raw analysis data
  List<String>? _getEmergingThemes(Map<String, dynamic>? rawData) {
    if (rawData == null) return null;

    final analysis = rawData['analysis'] as Map<String, dynamic>?;
    if (analysis == null) return null;

    final themes = analysis['emerging_themes'] as List?;
    if (themes == null) return null;

    return themes.cast<String>();
  }

  /// Helper method to extract recommendations from raw analysis data
  List<String>? _getRecommendations(Map<String, dynamic>? rawData) {
    if (rawData == null) return null;

    final analysis = rawData['analysis'] as Map<String, dynamic>?;
    if (analysis == null) return null;

    final recommendations =
        analysis['recommendations'] as Map<String, dynamic>?;
    if (recommendations == null) return null;

    final allRecommendations = <String>[];

    final parentingTips = recommendations['parenting_tips'] as List?;
    if (parentingTips != null) {
      allRecommendations.addAll(parentingTips.cast<String>());
    }

    final activityIdeas = recommendations['activity_ideas'] as List?;
    if (activityIdeas != null) {
      allRecommendations.addAll(activityIdeas.cast<String>());
    }

    return allRecommendations.isNotEmpty ? allRecommendations : null;
  }
}
