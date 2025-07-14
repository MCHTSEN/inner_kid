import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/share_options_widget.dart';
import '../models/analysis_state.dart';
import '../viewmodels/analysis_viewmodel.dart';

class AnalysisTab {
  final String title;
  final IconData icon;
  final Color color;

  const AnalysisTab({
    required this.title,
    required this.icon,
    required this.color,
  });
}

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

class _AnalysisResultsPageState extends ConsumerState<AnalysisResultsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<AnalysisTab> _tabs = [
    AnalysisTab(
      title: 'Özet',
      icon: Icons.summarize,
      color: const Color(0xFF667EEA),
    ),
    AnalysisTab(
      title: 'Duygular',
      icon: Icons.favorite,
      color: const Color(0xFFE53E3E),
    ),
    AnalysisTab(
      title: 'Gelişim',
      icon: Icons.trending_up,
      color: const Color(0xFF38A169),
    ),
    AnalysisTab(
      title: 'Sosyal',
      icon: Icons.group,
      color: const Color(0xFF3182CE),
    ),
    AnalysisTab(
      title: 'Öneriler',
      icon: Icons.lightbulb,
      color: const Color(0xFF805AD5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });

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
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: Column(
        children: [
          // Compact drawing preview - always visible
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCompactDrawingPreview(results.imageUrl),
          ),

          // Custom Tab Bar
          _buildCustomTabBar(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(insights),
                _buildEmotionalTab(insights),
                _buildDevelopmentTab(insights),
                _buildSocialTab(insights),
                _buildRecommendationsTab(insights),
              ],
            ),
          ),

          // Action buttons - always visible
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildActionButtons(),
          ),
        ],
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

  Widget _buildHighlightCard(
      String title, String content, IconData icon, Color color) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
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
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
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
            content,
            style: GoogleFonts.nunito(
              fontSize: 16,
              height: 1.6,
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildTagStyleKeyFindings(List<String> keyFindings) {
    if (keyFindings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎯 Öne Çıkan Bulgular',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keyFindings
              .take(4)
              .map((finding) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667EEA).withOpacity(0.1),
                          const Color(0xFF764BA2).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      finding,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF667EEA),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
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

  // Custom Tab Bar
  Widget _buildCustomTabBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? tab.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.icon,
                      size: 20,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab.title,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().slideY(begin: -0.5, delay: 200.ms);
  }

  // Tab Content Widgets
  Widget _buildSummaryTab(AnalysisInsights insights) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Analiz Özeti',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          _buildHighlightCard(
            'Ana Değerlendirme',
            insights.primaryInsight,
            Icons.lightbulb,
            const Color(0xFF667EEA),
          ),
          const SizedBox(height: 20),
          _buildTagStyleKeyFindings(insights.keyFindings),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildEmotionalTab(AnalysisInsights insights) {
    final emotionalIndicators =
        insights.detailedAnalysis['emotionalIndicators'];
    String content = '';

    if (emotionalIndicators is String) {
      content = emotionalIndicators;
    } else if (emotionalIndicators is List) {
      content = emotionalIndicators.join('\n• ');
      if (content.isNotEmpty) content = '• $content';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '❤️ Duygusal Analiz',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Çocuğunuzun duygusal durumu ve iç dünyası',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 24),
          if (content.isNotEmpty)
            _buildContentCard(
              content,
              Icons.favorite,
              const Color(0xFFE53E3E),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildDevelopmentTab(AnalysisInsights insights) {
    final developmentLevel = insights.detailedAnalysis['developmentLevel'];
    String content = developmentLevel?.toString() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📈 Gelişim Analizi',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yaş grubuna göre gelişim seviyesi ve beceriler',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 24),
          if (content.isNotEmpty)
            _buildContentCard(
              content,
              Icons.trending_up,
              const Color(0xFF38A169),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildSocialTab(AnalysisInsights insights) {
    final socialAspects = insights.detailedAnalysis['socialAspects'];
    final creativityMarkers = insights.detailedAnalysis['creativityMarkers'];

    String socialContent = '';
    String creativityContent = '';

    if (socialAspects is String) {
      socialContent = socialAspects;
    } else if (socialAspects is List) {
      socialContent = socialAspects.join('\n• ');
      if (socialContent.isNotEmpty) socialContent = '• $socialContent';
    }

    if (creativityMarkers is String) {
      creativityContent = creativityMarkers;
    } else if (creativityMarkers is List) {
      creativityContent = creativityMarkers.join('\n• ');
      if (creativityContent.isNotEmpty)
        creativityContent = '• $creativityContent';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👥 Sosyal & Yaratıcılık',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sosyal etkileşim ve yaratıcı yetenekler',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 24),
          if (socialContent.isNotEmpty) ...[
            _buildContentCard(
              socialContent,
              Icons.group,
              const Color(0xFF3182CE),
              title: 'Sosyal İlişkiler',
            ),
            const SizedBox(height: 16),
          ],
          if (creativityContent.isNotEmpty)
            _buildContentCard(
              creativityContent,
              Icons.palette,
              const Color(0xFF805AD5),
              title: 'Yaratıcılık Göstergeleri',
            ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildRecommendationsTab(AnalysisInsights insights) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Önerilerimiz',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Çocuğunuzun gelişimini desteklemek için özel öneriler',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 24),
          _buildFullRecommendationsList(insights.recommendations),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildContentCard(
    String content,
    IconData icon,
    Color color, {
    String? title,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
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
          if (title != null) ...[
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Text(
            content,
            style: GoogleFonts.nunito(
              fontSize: 15,
              height: 1.6,
              color: const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullRecommendationsList(List<String> recommendations) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      children: recommendations.asMap().entries.map((entry) {
        final index = entry.key;
        final recommendation = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF38A169).withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF38A169),
                      const Color(0xFF48BB78),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  recommendation,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    height: 1.5,
                    color: const Color(0xFF4A5568),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
