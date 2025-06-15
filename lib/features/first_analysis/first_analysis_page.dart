import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';
import 'components/image_upload_widget.dart';
import 'components/question_widget.dart';
import 'components/progress_indicator_widget.dart';
import 'viewmodel/first_analysis_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();
    _initAnimations();
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
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Progress Indicator (shown after image upload)
                        if (state.isImageUploaded) ...[
                          ProgressIndicatorWidget(
                            progress: _calculateProgress(state),
                            totalSteps: state.questions.length,
                            currentStep: _calculateCurrentStep(state),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Image Upload Widget
                        GestureDetector(
                          onTap: () =>
                              _showImageUploadOptions(context, viewModel),
                          child: ImageUploadWidget(
                            uploadedImage: state.uploadedImage,
                            isLoading: state.isLoading,
                            onGalleryTap: viewModel.uploadImageFromGallery,
                            onCameraTap: viewModel.uploadImageFromCamera,
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
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(width: 8),

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
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, state, viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: state.isLoading
            ? null
            : () async {
                await viewModel.submitAnalysis();
                if (mounted) {
                  _showSuccessDialog(context);
                }
              },
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
    if (viewModel.state.uploadedImage != null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageUploadOptionsSheet(
        onGalleryTap: () {
          Navigator.pop(context);
          viewModel.uploadImageFromGallery();
        },
        onCameraTap: () {
          Navigator.pop(context);
          viewModel.uploadImageFromCamera();
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Analizi Sıfırla',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Tüm ilerlemeniz silinecek. Emin misiniz?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(firstAnalysisViewModelProvider.notifier).reset();
            },
            child: Text(
              'Sıfırla',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Başarılı!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analiziniz başarıyla gönderildi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tamam',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
