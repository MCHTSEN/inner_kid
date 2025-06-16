import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:inner_kid/core/models/drawing_analysis.dart';
import 'package:inner_kid/features/home_dashboard/widgets/daily_insight_card.dart';
import 'package:inner_kid/features/home_dashboard/widgets/quick_analysis_section.dart';
import 'package:inner_kid/features/home_dashboard/widgets/recent_analyses_section.dart';
import 'package:inner_kid/features/home_dashboard/widgets/daily_recommendations.dart';
import 'package:inner_kid/features/home_dashboard/providers/home_dashboard_provider.dart';
import 'package:inner_kid/features/home_dashboard/widgets/child_selector_menu.dart';

class HomeDashboardPage extends ConsumerWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(homeDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: dashboardState.when(
        data: (data) => _buildDashboard(context, data),
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(error),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Inner Kid',
        style: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2D3748),
        ),
      ),
      actions: [
        ChildSelectorMenu(
          onChildSelected: (selectedChild) {
            if (selectedChild != null) {
              // Handle child selection
              if (selectedChild['name'] == 'Çocuk Ekle') {
                // Navigate to add child page
                debugPrint('Navigate to add child');
              } else {
                // Child selected
                debugPrint('Selected child: ${selectedChild['name']}');
              }
            }
          },
        ),
        IconButton(
          onPressed: () {
            // Navigate to notifications
          },
          icon: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDashboard(BuildContext context, DashboardData data) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Insight Card
            DailyInsightCard(
              insight: data.dailyInsight,
            ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2),

            const SizedBox(height: 24),

            // Quick Analysis Section
            _buildSectionHeader('Hızlı Analiz'),
            const SizedBox(height: 12),
            const QuickAnalysisSection(),

            const SizedBox(height: 24),

            // Recent Analyses
            if (data.recentAnalyses.isNotEmpty) ...[
              _buildSectionHeader('Son Analizler'),
              const SizedBox(height: 12),
              RecentAnalysesSection(analyses: data.recentAnalyses),
              const SizedBox(height: 24),
            ],

            // Daily Recommendations
            _buildSectionHeader('Günlük Öneriler'),
            const SizedBox(height: 12),
            DailyRecommendations(
              recommendations: data.dailyRecommendations,
            ),

            const SizedBox(height: 120), // Space for floating bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
          ),
          SizedBox(height: 16),
          Text(
            'Yükleniyor...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFE53E3E),
          ),
          const SizedBox(height: 16),
          Text(
            'Bir hata oluştu',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Retry loading
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}

// Data class for dashboard state
class DashboardData {
  final String dailyInsight;
  final List<DrawingAnalysis> recentAnalyses;
  final List<String> dailyRecommendations;

  DashboardData({
    required this.dailyInsight,
    required this.recentAnalyses,
    required this.dailyRecommendations,
  });
}
