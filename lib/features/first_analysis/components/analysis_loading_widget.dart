import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';
import '../viewmodel/first_analysis_viewmodel.dart';

/// Widget that displays analysis progress with trust-building messages
class AnalysisLoadingWidget extends ConsumerStatefulWidget {
  const AnalysisLoadingWidget({super.key});

  @override
  ConsumerState<AnalysisLoadingWidget> createState() =>
      _AnalysisLoadingWidgetState();
}

class _AnalysisLoadingWidgetState extends ConsumerState<AnalysisLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _textController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _textFadeAnimation;

  int _currentStepIndex = 0;
  late List<AnalysisStep> _analysisSteps;

  @override
  void initState() {
    super.initState();
    _initializeSteps();
    _initAnimations();
    _startStepCycle();
    _startAnalysis(); // Start the actual analysis
  }

  void _initializeSteps() {
    _analysisSteps = [
      AnalysisStep(
        icon: Icons.psychology_outlined,
        title: 'Psikolojik Etmenler Analiz Ediliyor',
        description: 'Çiziminizdeki duygusal işaretler değerlendiriliyor',
        color: Colors.purple,
      ),
      AnalysisStep(
        icon: Icons.menu_book_outlined,
        title: 'Bilimsel Literatür Taranıyor',
        description: 'Çocuk psikolojisi araştırmaları inceleniyor',
        color: Colors.blue,
      ),
      AnalysisStep(
        icon: Icons.analytics_outlined,
        title: 'Gelişimsel Göstergeler İnceleniyor',
        description: 'Yaş grubuna uygun kriterler değerlendiriliyor',
        color: Colors.orange,
      ),
      AnalysisStep(
        icon: Icons.lightbulb_outline,
        title: 'Kişiselleştirilmiş Öneriler Hazırlanıyor',
        description: 'Size özel gelişim önerileri oluşturuluyor',
        color: Colors.green,
      ),
      AnalysisStep(
        icon: Icons.check_circle_outline,
        title: 'Analiz Tamamlandı',
        description: 'Detaylı raporunuz hazır',
        color: Colors.teal,
      ),
    ];
  }

  void _initAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _textController.forward();
  }

  void _startStepCycle() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextStep();
      }
    });
  }

  void _nextStep() {
    if (_currentStepIndex < _analysisSteps.length - 1) {
      _textController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentStepIndex++;
          });
          _textController.forward();

          // Schedule next step
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              _nextStep();
            }
          });
        }
      });
    } else {
      // Analysis completed, wait a moment then auto-navigate back
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate completion
        }
      });
    }
  }

  void _startAnalysis() {
    // Start the analysis process using provider
    final viewModel = ref.read(firstAnalysisViewModelProvider.notifier);
    viewModel.submitAnalysis();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _analysisSteps[_currentStepIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    // Removed back button - analysis should not be interrupted
                    const SizedBox(width: 48), // Space for symmetry
                    Expanded(
                      child: Text(
                        'Analiz Ediliyor',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Space for symmetry
                  ],
                ),

                // Main content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading animation
                      Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 48),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer rotating ring
                            AnimatedBuilder(
                              animation: _rotationAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimation.value * 2 * 3.14159,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            currentStep.color.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: CustomPaint(
                                      painter: LoadingRingPainter(
                                        color: currentStep.color,
                                        progress: 0.7,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Center icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentStep.color.withOpacity(0.1),
                              ),
                              child: Icon(
                                currentStep.icon,
                                size: 40,
                                color: currentStep.color,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Step content
                      AnimatedBuilder(
                        animation: _textFadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textFadeAnimation.value,
                            child: Column(
                              children: [
                                Text(
                                  currentStep.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  currentStep.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 48),

                      // Progress dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _analysisSteps.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index <= _currentStepIndex
                                  ? currentStep.color
                                  : AppTheme.textSecondary.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Analiz işlemi, çocuk psikolojisi uzmanlarının bilimsel yaklaşımları temel alınarak gerçekleştirilmektedir.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Analysis step model
class AnalysisStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  AnalysisStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// Custom painter for loading ring
class LoadingRingPainter extends CustomPainter {
  final Color color;
  final double progress;

  LoadingRingPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const double startAngle = -1.5707963267948966; // -π/2 (top)
    final double sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
