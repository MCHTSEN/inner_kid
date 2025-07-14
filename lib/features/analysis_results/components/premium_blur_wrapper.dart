import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';

/// Premium blur wrapper widget for content protection
///
/// Features:
/// - ImageFilter.blur for content obscuring
/// - Clickable overlay that triggers paywall
/// - Visual premium indicator with call-to-action
/// - Gradient overlay for better readability
class PremiumBlurWrapper extends StatelessWidget {
  final Widget child;
  final bool isPremiumUnlocked;
  final VoidCallback? onTap;
  final VoidCallback? onPremiumButtonTap;

  const PremiumBlurWrapper({
    super.key,
    required this.child,
    required this.isPremiumUnlocked,
    this.onTap,
    this.onPremiumButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isPremiumUnlocked) {
      return child;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Blurred content
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: child,
          ),

          // Clickable premium overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: _buildPremiumOverlay(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumOverlay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Premium icon with pulse animation
          _buildPulsingIcon(),

          const SizedBox(height: 16),

          // Premium title
          Text(
            'Premium İçerik',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            'Detaylı analiz sonuçlarını görmek için premium\'a geçin',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          // Clickable hint
          Text(
            'Dokunarak premium\'a geçin',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 20),

          // Premium CTA button
          ElevatedButton(
            onPressed: onPremiumButtonTap ?? onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: Text(
              'Premium\'a Geç',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween<double>(begin: 0.8, end: 1.2),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: const Icon(
            Icons.lock_outline,
            size: 48,
            color: AppTheme.primaryColor,
          ),
        );
      },
    );
  }
}
