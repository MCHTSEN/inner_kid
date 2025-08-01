import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/constants/assets.dart';
import 'package:inner_kid/core/extension/ui_helper_extensions.dart';
import 'package:inner_kid/core/helper/gap.dart';
import 'package:inner_kid/core/theme/theme.dart';
import 'package:inner_kid/features/landing/components/analysis_card.dart';
import 'package:inner_kid/features/onboarding/views/onboarding_flow_page.dart';
import 'package:lottie/lottie.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Hero Section
                _buildHeroSection(),

                // Analysis Section
                _buildAnalysisSection(),

                // Footer Section
                _buildFooterSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        children: [
          // Header with title and subtitle
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  children: [
                    // App title
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.child_care,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Inner Kid',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Main title
                    Text(
                      'Çocuğunuzun iç dünyasını daha iyi anlamak ister misiniz?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Drawing image with animation
          SlideTransition(
            position: _slideAnimation,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main drawing container
                Container(
                  height: 220,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage(Assets.img_1),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating arrow animation
                Positioned(
                  bottom: -120,
                  left: 40,
                  child: AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + (_slideAnimation.value.dy.abs() * 0.2),
                        child: Transform.rotate(
                          angle: 1.2708, // 90 degrees in radians
                          child: Lottie.asset(
                            Assets.arrowLottie,
                            width: 150,
                            height: 150,
                            repeat: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return const DrawingAnalysisWidget().withPadding(top: 55);
  }

  Widget _buildFooterSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Call to action card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: AppStyles.primaryGradientDecoration,
            child: Column(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Daha Fazla Keşfet',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Çocuğunuzun yaratıcılığını ve duygusal gelişimini\ndaha derinlemesine anlayın',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingFlowPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'İç Dünyasını Anlayın',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),

                // Login button for existing users
              ],
            ),
          ),

          Gap.low,
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Zaten hesabın var mı? Giriş Yap',
                    style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          Gap.high,
          Text(
            '© 2024 Inner Kid - Çocuk Gelişim Uzmanları',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
