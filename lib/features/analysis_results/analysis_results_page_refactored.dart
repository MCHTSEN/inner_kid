import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Core imports
import '../../core/theme/theme.dart';

// Components
import 'components/success_header_widget.dart';
import 'components/premium_blur_wrapper.dart';
import 'components/analysis_content_widgets.dart';
import 'components/premium_app_bar.dart';

// ViewModels
import 'viewmodels/analysis_results_viewmodel.dart';

// Services
import 'services/ab_testing_service.dart';

// External widgets
import '../first_analysis/components/paywall_widget.dart';

/// Refactored Analysis Results Page using MVVM architecture
///
/// Features:
/// - Clean separation of concerns with ViewModel
/// - Reusable component widgets
/// - Premium content gating with blur effect
/// - A/B testing framework for success messages
/// - Analytics tracking integration
/// - Responsive design with smooth animations
class AnalysisResultsPageRefactored extends ConsumerStatefulWidget {
  final File? analyzedImage;
  final Map<String, String>? analysisData;
  final bool isBlurred;
  final VoidCallback? onPremiumUnlock;
  final String? userId;
  final SuccessHeaderVariant? variant;

  const AnalysisResultsPageRefactored({
    super.key,
    this.analyzedImage,
    this.analysisData,
    this.isBlurred = false,
    this.onPremiumUnlock,
    this.userId,
    this.variant,
  });

  @override
  ConsumerState<AnalysisResultsPageRefactored> createState() =>
      _AnalysisResultsPageRefactoredState();
}

class _AnalysisResultsPageRefactoredState
    extends ConsumerState<AnalysisResultsPageRefactored>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeViewModel();
    _scheduleAutoPaywall();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  void _initializeViewModel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analysisResultsViewModelProvider).initialize(
            analyzedImage: widget.analyzedImage,
            analysisData: widget.analysisData,
            isBlurred: widget.isBlurred,
            userId: widget.userId,
            variant: widget.variant,
          );
    });
  }

  void _scheduleAutoPaywall() {
    if (widget.isBlurred) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            ref.read(analysisResultsViewModelProvider).onAutoPaywallTrigger();
            _showPaywall('auto');
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(analysisResultsViewModelProvider);
    final state = viewModel.state;

    return Scaffold(
      appBar: PremiumAppBar(
        isPremiumUnlocked: state.isPremiumUnlocked,
        onSharePressed: () => viewModel.shareResults(),
        onSavePressed: () => viewModel.downloadReport(),
        onPaywallTrigger: () => _showPaywall('button_click'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(context, viewModel),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AnalysisResultsViewModel viewModel) {
    final state = viewModel.state;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Success Header (always visible)
          SuccessHeaderWidget(
            variant: state.headerVariant,
            onTap: () => _showPaywall('header_click'),
          ),

          const SizedBox(height: 24),

          // Premium gated content
          PremiumBlurWrapper(
            isPremiumUnlocked: state.isPremiumUnlocked,
            onTap: () {
              viewModel.onBlurAreaClicked();
              _showPaywall('blur_click');
            },
            onPremiumButtonTap: () {
              viewModel.onPremiumButtonClicked();
              _showPaywall('cta_button');
            },
            child: Column(
              children: [
                // Analysis Overview
                AnalysisContentWidgets.buildAnalysisOverview(
                  analyzedImage: state.analyzedImage,
                  analysisData: state.analysisData,
                ),

                const SizedBox(height: 24),

                // Psychological Insights
                AnalysisContentWidgets.buildPsychologicalInsights(),

                const SizedBox(height: 24),

                // Development Recommendations
                AnalysisContentWidgets.buildDevelopmentRecommendations(),

                const SizedBox(height: 24),

                // Activities & Games
                AnalysisContentWidgets.buildActivitiesSection(),

                const SizedBox(height: 24),

                // Progress Tracking
                AnalysisContentWidgets.buildProgressTracking(),

                const SizedBox(height: 32),

                // Action Buttons
                AnalysisContentWidgets.buildActionButtons(
                  onDownload: () => viewModel.downloadReport(),
                  onNewAnalysis: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show paywall modal with payment options
  void _showPaywall(String trigger) {
    final viewModel = ref.read(analysisResultsViewModelProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaywallWidget(
        onPaymentSuccess: () async {
          Navigator.pop(context); // Close paywall

          // Update ViewModel state
          await viewModel.unlockPremium();

          // Trigger parent callback if provided
          widget.onPremiumUnlock?.call();

          // Show success feedback
          _showPremiumUnlockFeedback();
        },
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  /// Show success feedback when premium is unlocked
  void _showPremiumUnlockFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Premium aktif! Tüm özellikler açıldı.',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
