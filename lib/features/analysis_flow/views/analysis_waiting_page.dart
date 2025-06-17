import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../components/analysis_status_widget.dart';
import '../components/progress_indicator_widget.dart';
import '../models/analysis_state.dart';
import '../viewmodels/analysis_viewmodel.dart';
import 'analysis_results_page.dart';

class AnalysisWaitingPage extends ConsumerStatefulWidget {
  const AnalysisWaitingPage({super.key});

  @override
  ConsumerState<AnalysisWaitingPage> createState() =>
      _AnalysisWaitingPageState();
}

class _AnalysisWaitingPageState extends ConsumerState<AnalysisWaitingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisViewModelProvider);

    // Navigate to results when analysis is completed
    ref.listen(analysisViewModelProvider, (previous, next) {
      if (next.isCompleted && next.hasResults) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AnalysisResultsPage(),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: analysisState.canCancel
              ? () => _showCancelDialog()
              : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Color(0xFF2D3748)),
        ),
        title: Text(
          'Analiz Ediliyor',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Main illustration
              _buildMainIllustration(analysisState),

              const SizedBox(height: 60),

              // Status text
              _buildStatusText(analysisState),

              const SizedBox(height: 40),

              // Progress indicator
              AnalysisProgressIndicator(
                progress: analysisState.overallProgress,
                message: analysisState.currentStepMessage,
              ),

              const SizedBox(height: 40),

              // Analysis status widget
              AnalysisStatusWidget(status: analysisState.status),

              const Spacer(),

              // Cancel button (if applicable)
              if (analysisState.canCancel) _buildCancelButton(),

              // Error message (if any)
              if (analysisState.hasError)
                _buildErrorMessage(analysisState.errorMessage!),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainIllustration(AnalysisState state) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    ).animate().scale(duration: 800.ms, curve: Curves.elasticOut);
  }

  Widget _buildStatusText(AnalysisState state) {
    String title;
    String subtitle;

    switch (state.status) {
      case AnalysisStatus.uploading:
        title = 'Görsel Yükleniyor';
        subtitle = 'Çiziminiz güvenli şekilde yükleniyor...';
        break;
      case AnalysisStatus.analyzing:
        title = 'AI Analizi Devam Ediyor';
        subtitle = 'Yapay zeka çiziminizi detaylı şekilde inceliyor...';
        break;
      case AnalysisStatus.completed:
        title = 'Analiz Tamamlandı!';
        subtitle = 'Sonuçlarınız hazırlanıyor...';
        break;
      case AnalysisStatus.failed:
        title = 'Analiz Başarısız';
        subtitle = 'Bir hata oluştu, lütfen tekrar deneyin';
        break;
      case AnalysisStatus.cancelled:
        title = 'Analiz İptal Edildi';
        subtitle = 'İşlem kullanıcı tarafından durduruldu';
        break;
      default:
        title = 'Hazırlanıyor';
        subtitle = 'Analiz süreci başlatılıyor...';
    }

    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: const Color(0xFF718096),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showCancelDialog(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.red.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Analizi İptal Et',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade600,
          ),
        ),
      ),
    ).animate().slideY(begin: 0.3, delay: 600.ms);
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    ).animate().shakeX();
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Analizi İptal Et',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
        ),
        content: Text(
          'Analiz sürecini iptal etmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: const Color(0xFF718096),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Vazgeç',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF718096),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(analysisViewModelProvider.notifier).cancelAnalysis();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'İptal Et',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
