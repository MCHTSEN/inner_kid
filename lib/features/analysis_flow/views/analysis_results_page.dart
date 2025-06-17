import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../components/insights_display_widget.dart';
import '../components/recommendations_widget.dart';
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

class _AnalysisResultsPageState extends ConsumerState<AnalysisResultsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            const Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Analiz Sonuçları',
                                    style: GoogleFonts.nunito(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'AI destekli çizim analizi',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Drawing image
                  _buildDrawingPreview(results.imageUrl),

                  const SizedBox(height: 24),

                  // Score cards
                  _buildScoreCards(results.insights),

                  const SizedBox(height: 24),

                  // Tab bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: const Color(0xFF718096),
                      labelStyle: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      indicatorColor: AppTheme.primaryColor,
                      tabs: const [
                        Tab(text: 'Genel Görüş'),
                        Tab(text: 'Detaylar'),
                        Tab(text: 'Öneriler'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab content
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(
                          child:
                              InsightsDisplayWidget(insights: results.insights),
                        ),
                        SingleChildScrollView(
                          child: _buildDetailedAnalysis(results.insights),
                        ),
                        SingleChildScrollView(
                          child: RecommendationsWidget(
                              recommendations:
                                  results.insights.recommendations),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  _buildActionButtons(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
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
      body: const Center(
        child: CircularProgressIndicator(),
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
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
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
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
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

  Widget _buildDrawingPreview(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    ).animate().slideY(begin: 0.3, delay: 200.ms);
  }

  Widget _buildScoreCards(AnalysisInsights insights) {
    return Row(
      children: [
        Expanded(
          child: _buildScoreCard(
            'Duygusal',
            insights.emotionalScore,
            Icons.favorite,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildScoreCard(
            'Yaratıcılık',
            insights.creativityScore,
            Icons.brush,
            Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildScoreCard(
            'Gelişim',
            insights.developmentScore,
            Icons.trending_up,
            Colors.green,
          ),
        ),
      ],
    ).animate().slideX(delay: 400.ms);
  }

  Widget _buildScoreCard(
      String title, double score, IconData icon, Color color) {
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
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
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
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis(AnalysisInsights insights) {
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
      child: ListView(
        children: [
          _buildAnalysisSection(
            'Duygusal Belirtiler',
            insights.detailedAnalysis['emotionalIndicators'] ?? [],
            Icons.psychology,
            Colors.blue,
          ),
          const SizedBox(height: 20),
          _buildAnalysisSection(
            'Gelişim Seviyesi',
            [insights.detailedAnalysis['developmentLevel'] ?? ''],
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 20),
          _buildAnalysisSection(
            'Sosyal Yönler',
            insights.detailedAnalysis['socialAspects'] ?? [],
            Icons.group,
            Colors.orange,
          ),
          const SizedBox(height: 20),
          _buildAnalysisSection(
            'Yaratıcılık İşaretleri',
            insights.detailedAnalysis['creativityMarkers'] ?? [],
            Icons.color_lens,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(
    String title,
    List<dynamic> items,
    IconData icon,
    Color color,
  ) {
    return Column(
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
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: const Color(0xFF4A5568),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _generatePDF(),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('PDF Raporu İndir'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showShareOptions(context),
            icon: const Icon(Icons.share),
            label: const Text('Sonuçları Paylaş'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppTheme.primaryColor),
              foregroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    ).animate().slideY(begin: 0.3, delay: 600.ms);
  }

  void _generatePDF() {
    ref.read(analysisViewModelProvider.notifier).generatePDF();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF raporu oluşturuluyor...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ShareOptionsWidget(),
    );
  }
}
