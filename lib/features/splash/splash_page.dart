import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/viewmodels/auth_viewmodel.dart';
import '../auth/models/auth_state.dart';
import '../landing/landing_page.dart';
import '../auth/views/login_page.dart';
import '../../core/navigation/main_navigation.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;

  static const String _firstTimeKey = 'first_time_user';
  static const Duration _splashDuration = Duration(milliseconds: 3000);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSplashSequence();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));
  }

  void _startSplashSequence() async {
    // Start logo animation
    _logoController.forward();

    // Start text animation after delay
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Wait for total splash duration
    await Future.delayed(_splashDuration);

    // Navigate based on user status
    _navigateToAppropriateScreen();
  }

  Future<void> _navigateToAppropriateScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool(_firstTimeKey) ?? true;

      if (isFirstTime) {
        // First time user - show landing page
        await prefs.setBool(_firstTimeKey, false);
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/landing');
        }
      } else {
        // Returning user - check authentication status
        final authState = ref.read(authViewModelProvider);

        if (mounted) {
          if (authState.isAuthenticated) {
            // User is already logged in - go to main app
            Navigator.of(context).pushReplacementNamed('/main');
          } else {
            // User needs to log in
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      }
    } catch (e) {
      // Error case - default to landing page
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/landing');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFF667EEA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Animation
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.child_care,
                                  size: 60,
                                  color: Color(0xFF667EEA),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // App Name Animation
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textOpacity.value,
                            child: Column(
                              children: [
                                Text(
                                  'Inner Kid',
                                  style: GoogleFonts.nunito(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Çocuk Çizimlerinde Gizli Mesajlar',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Loading Indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Yükleniyor...',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 1000.ms, duration: 500.ms)
                        .then()
                        .fadeOut(duration: 500.ms)
                        .then()
                        .fadeIn(duration: 500.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Provider for checking first time user status
final firstTimeUserProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_SplashPageState._firstTimeKey) ?? true;
});
 