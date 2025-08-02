import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

import '../components/social_proof_widget.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class FakeLoadingScreen extends ConsumerStatefulWidget {
  const FakeLoadingScreen({super.key});

  @override
  ConsumerState<FakeLoadingScreen> createState() => _FakeLoadingScreenState();
}

class _FakeLoadingScreenState extends ConsumerState<FakeLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startLoadingSimulation();
  }

  void _initAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _rotationController.repeat();
  }

  void _startLoadingSimulation() {
    // The viewmodel already handles the transition after 3 seconds
    // We just need to make sure the animation is running
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);

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
                    const SizedBox(
                        width: 48), // For alignment with back button space
                    const Spacer(),
                    Text(
                      'Analiz Ediliyor',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // For alignment
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
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.3),
                                        width: 4,
                                      ),
                                    ),
                                    child: CustomPaint(
                                      painter: LoadingRingPainter(
                                        color: AppTheme.primaryColor,
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
                                color: AppTheme.primaryColor.withOpacity(0.1),
                              ),
                              child: const Icon(
                                Icons.psychology_outlined,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Loading message
                      Text(
                        state.childName != null
                            ? 'Uygulamanız kişiselleştiriliyor, ${state.childName} için hazırlanıyor...'
                            : 'Uygulamanız kişiselleştiriliyor...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Social proof messages
                      const SocialProofWidget(
                        title:
                            'Psikologlar ve pedagoglar ile birlikte geliştirildi.',
                        icon: Icons.school_outlined,
                      ),

                      const SizedBox(height: 12),

                      const SocialProofWidget(
                        title:
                            '10.000+ çocuk çizimleri üzerinden duygusal analiz yapıldı.',
                        icon: Icons.analytics_outlined,
                      ),

                      const SizedBox(height: 12),

                      const SocialProofWidget(
                        title:
                            '22.400+ anne-baba uygulamayı aktif olarak kullanıyor.',
                        icon: Icons.family_restroom_outlined,
                      ),
                    ],
                  ),
                ),

                // Bottom message
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    state.childName != null
                        ? '22.400+ çocuk, çizimleriyle duygusal gelişim yolculuğunda. ${state.childName} için ilk adımı atalım mı?'
                        : '22.400+ çocuk, çizimleriyle duygusal gelişim yolculuğunda. İlk adımı atalım mı?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
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
      ..strokeWidth = 4
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
