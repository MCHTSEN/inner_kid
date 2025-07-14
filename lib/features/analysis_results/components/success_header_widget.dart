import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import '../services/ab_testing_service.dart';

/// Success header widget displaying A/B testing variant messages
///
/// Shows the success message based on the selected A/B testing variant
/// to optimize user engagement and conversion rates.
class SuccessHeaderWidget extends StatelessWidget {
  final SuccessHeaderVariant variant;
  final VoidCallback? onTap;

  const SuccessHeaderWidget({
    super.key,
    required this.variant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: _getVariantGradient(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getVariantColor().withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                _getVariantIcon(),
                size: 48,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Success title
            Text(
              'Analiz Tamamlandı!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // A/B testing variant message
            Text(
              variant.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get gradient colors based on variant
  LinearGradient _getVariantGradient() {
    switch (variant) {
      case SuccessHeaderVariant.emotional:
        return const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFF8E9E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SuccessHeaderVariant.scientific:
        return const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SuccessHeaderVariant.development:
        return const LinearGradient(
          colors: [Color(0xFFFF9A8B), Color(0xFFA8E6CF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SuccessHeaderVariant.achievement:
        return const LinearGradient(
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// Get primary color based on variant
  Color _getVariantColor() {
    switch (variant) {
      case SuccessHeaderVariant.emotional:
        return const Color(0xFFFF6B9D);
      case SuccessHeaderVariant.scientific:
        return const Color(0xFF667EEA);
      case SuccessHeaderVariant.development:
        return const Color(0xFFFF9A8B);
      case SuccessHeaderVariant.achievement:
        return const Color(0xFF11998E);
    }
  }

  /// Get icon based on variant
  IconData _getVariantIcon() {
    switch (variant) {
      case SuccessHeaderVariant.emotional:
        return Icons.favorite;
      case SuccessHeaderVariant.scientific:
        return Icons.science;
      case SuccessHeaderVariant.development:
        return Icons.trending_up;
      case SuccessHeaderVariant.achievement:
        return Icons.emoji_events;
    }
  }
}
