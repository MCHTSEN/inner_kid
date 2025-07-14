import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';
import 'package:logger/logger.dart';
import 'components/image_upload_widget.dart';
import 'components/question_widget.dart';
import 'components/progress_indicator_widget.dart';
import 'components/native_dialogs.dart';
import 'components/paywall_widget.dart';
import 'components/analysis_loading_widget.dart';
import 'viewmodel/first_analysis_viewmodel.dart';
import '../analysis_results/analysis_results_page_refactored.dart';

/// First Analysis Page - Handles image upload and questionnaire flow
class FirstAnalysisPage extends ConsumerStatefulWidget {
  const FirstAnalysisPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FirstAnalysisPageState();
}

class _FirstAnalysisPageState extends ConsumerState<FirstAnalysisPage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  final _logger = Logger();
  @override
  void initState() {
    super.initState();
    _logger.d('🔵 FirstAnalysisPage: initState called');
    _initAnimations();
    _scrollController = ScrollController();
  }

  void _initAnimations() {
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    ));

    // Start the page animation
    Future.delayed(const Duration(milliseconds: 200), () {
      _pageController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(firstAnalysisViewModelProvider);
    final viewModel = ref.read(firstAnalysisViewModelProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // App Bar
                _buildAppBar(context, state),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Image Upload Widget
                        GestureDetector(
                          onTap: () =>
                              _showImageUploadOptions(context, viewModel),
                          child: ImageUploadWidget(
                            uploadedImage: state.uploadedImage,
                            isLoading: state.isLoading,
                            isCompact: state.isImageUploaded,
                            onGalleryTap: viewModel.uploadImageFromGallery,
                            onCameraTap: viewModel.uploadImageFromCamera,
                            onChangeTap: () =>
                                _showImageUploadOptions(context, viewModel),
                          ),
                        ),

                        // Questions Section
                        if (state.isImageUploaded) ...[
                          const SizedBox(height: 24),
                          _buildQuestionsSection(state, viewModel),
                        ],

                        // Submit Button
                        if (state.allQuestionsAnswered &&
                            state.isImageUploaded) ...[
                          const SizedBox(height: 32),
                          _buildSubmitButton(context, state, viewModel),
                        ],

                        // Completion Message
                        if (state.isCompleted) ...[
                          const SizedBox(height: 32),
                          _buildCompletionMessage(),
                        ],

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Top row with back button, title, and reset
          Row(
            children: [
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İlk Analiz',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (!state.isImageUploaded)
                      Text(
                        'Çizimi yükleyin ve soruları yanıtlayın',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              // Reset button (shown if analysis started)
              if (state.isImageUploaded)
                IconButton(
                  onPressed: () => _showResetDialog(context),
                  icon: const Icon(
                    Icons.refresh,
                    color: AppTheme.textSecondary,
                  ),
                ),
            ],
          ),

          // Progress indicator (shown after image upload)
          if (state.isImageUploaded) ...[
            const SizedBox(height: 16),
            ProgressIndicatorWidget(
              progress: _calculateProgress(state),
              totalSteps: state.questions.length,
              currentStep: _calculateCurrentStep(state),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionsSection(state, viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const Icon(
                Icons.quiz_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Değerlendirme Soruları',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Questions list
        ...state.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          // Find the first unanswered question and make it active
          final firstUnansweredIndex =
              state.questions.indexWhere((q) => !q.isAnswered);
          final isActive = !question.isAnswered &&
              (firstUnansweredIndex == -1
                  ? false
                  : index == firstUnansweredIndex);

          return QuestionWidget(
            key: ValueKey(question.id),
            question: question,
            isActive: isActive,
            isAnswered: question.isAnswered,
            questionNumber: index + 1,
            onAnswerSelected: (answer) {
              viewModel.answerQuestion(question.id, answer);
              _scrollToNextQuestion();
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, state, FirstAnalysisViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: state.isLoading
            ? null
            : () => _submitAnalysis(context, state, viewModel),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: state.isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Analiz ediliyor...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Analizi Gönder',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCompletionMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration.copyWith(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analiz Tamamlandı!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Çizim analizi başarıyla gönderildi. Sonuçları yakında görebileceksiniz.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Auto-scroll functionality
  void _scrollToNextQuestion() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.offset + 120, // Scroll down by 120 pixels
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // Helper methods
  double _calculateProgress(state) {
    if (!state.isImageUploaded && state.questions.isEmpty) return 0.0;

    final imageStep = state.isImageUploaded ? 1 : 0;
    final answeredQuestions = state.answeredQuestions.length;
    final totalSteps = 1 + state.questions.length; // 1 for image + questions

    return (imageStep + answeredQuestions) / totalSteps;
  }

  int _calculateCurrentStep(state) {
    final imageStep = state.isImageUploaded ? 1 : 0;
    final answeredQuestions = state.answeredQuestions.length;
    return (imageStep + answeredQuestions).toInt();
  }

  void _showImageUploadOptions(BuildContext context, viewModel) {
    NativeDialogs.showImagePickerActionSheet(
      context: context,
      onGalleryTap: viewModel.uploadImageFromGallery,
      onCameraTap: viewModel.uploadImageFromCamera,
    );
  }

  void _showResetDialog(BuildContext context) async {
    final shouldReset = await NativeDialogs.showResetConfirmationDialog(
      context: context,
    );

    if (shouldReset) {
      ref.read(firstAnalysisViewModelProvider.notifier).reset();
    }
  }

  void _showPaywallSheet(BuildContext context, state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaywallWidget(
        onPaymentSuccess: () {
          Navigator.pop(context); // Close paywall
          _navigateToResults(context, state);
        },
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  void _navigateToResults(BuildContext context, state) {
    // Convert answered questions to a map
    final Map<String, String> analysisData = {};
    for (final question in state.answeredQuestions) {
      analysisData[question.question] = question.selectedAnswer ?? '';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisResultsPageRefactored(
          analyzedImage: state.uploadedImage,
          analysisData: analysisData,
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    NativeDialogs.showSuccessDialog(
      context: context,
      title: 'Başarılı!',
      message: 'Analiziniz başarıyla gönderildi.',
    );
  }

  // New method to handle analysis submission with loading page
  void _submitAnalysis(
      BuildContext context, state, FirstAnalysisViewModel viewModel) async {
    _logger.d('🔵 FirstAnalysisPage: _submitAnalysis called');

    // Navigate to loading page immediately (analysis will start there)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalysisLoadingWidget(),
      ),
    );

    _logger.d('🟡 FirstAnalysisPage: Loading widget returned result: $result');

    // If loading completed successfully, navigate to blurred results
    if (result == true && mounted) {
      _logger
          .d('🟢 FirstAnalysisPage: Loading completed, navigating to results');
      _navigateToBlurredResults(context, state);
    } else {
      _logger.d('🔴 FirstAnalysisPage: Loading was cancelled or failed');
    }
  }

  void _navigateToBlurredResults(BuildContext context, state) {
    _logger.d('🔵 FirstAnalysisPage: _navigateToBlurredResults called');

    // Convert answered questions to a map
    final Map<String, String> analysisData = {};
    for (final question in state.answeredQuestions) {
      analysisData[question.question] = question.selectedAnswer ?? '';
    }

    _logger.d('🟡 FirstAnalysisPage: Navigation data prepared:');
    _logger.d('  - analyzedImage: ${state.uploadedImage}');
    _logger.d('  - analysisData: $analysisData');
    _logger.d('  - isBlurred: true');

    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            _logger.d('🟢 FirstAnalysisPage: MaterialPageRoute builder called');
            return AnalysisResultsPageRefactored(
              analyzedImage: state.uploadedImage,
              analysisData: analysisData,
              isBlurred: true, // Show blurred results initially
              userId:
                  'demo-user-${DateTime.now().millisecondsSinceEpoch}', // Demo user ID for A/B testing
              onPremiumUnlock: () {
                _logger
                    .d('🟢 FirstAnalysisPage: onPremiumUnlock callback called');
                // Update the state to show full results
                ref
                    .read(firstAnalysisViewModelProvider.notifier)
                    .unlockPremium();
              },
            );
          },
        ),
      );
      _logger.d('🟢 FirstAnalysisPage: Navigation initiated successfully');
    } catch (e, stackTrace) {
      _logger.d('🔴 FirstAnalysisPage: Error during navigation: $e');
      _logger.d('🔴 StackTrace: $stackTrace');
    }
  }
}
