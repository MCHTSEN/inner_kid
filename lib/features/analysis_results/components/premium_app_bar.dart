import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';

/// Premium app bar with feature-gated buttons
///
/// Shows different button states based on premium status:
/// - Active buttons for premium users
/// - Dimmed buttons with lock overlay for non-premium users
class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isPremiumUnlocked;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onPaywallTrigger;

  const PremiumAppBar({
    super.key,
    required this.isPremiumUnlocked,
    this.onBackPressed,
    this.onSharePressed,
    this.onSavePressed,
    this.onPaywallTrigger,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: onBackPressed ?? () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppTheme.textPrimary,
            ),
          ),

          // Title
          Expanded(
            child: Center(
              child: Text(
                'Analiz Sonuçları',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),

          // Action buttons
          Row(
            children: [
              _buildPremiumActionButton(
                icon: Icons.share,
                onPressed:
                    isPremiumUnlocked ? onSharePressed : onPaywallTrigger,
                tooltip:
                    isPremiumUnlocked ? 'Sonuçları Paylaş' : 'Premium gerekli',
              ),
              const SizedBox(width: 8),
              _buildPremiumActionButton(
                icon: Icons.bookmark,
                onPressed: isPremiumUnlocked ? onSavePressed : onPaywallTrigger,
                tooltip:
                    isPremiumUnlocked ? 'Sonuçları Kaydet' : 'Premium gerekli',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActionButton({
    required IconData icon,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    if (isPremiumUnlocked) {
      // Active button for premium users
      return Tooltip(
        message: tooltip ?? '',
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    } else {
      // Disabled button with lock overlay for non-premium users
      return Tooltip(
        message: tooltip ?? '',
        child: Stack(
          children: [
            IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color: AppTheme.textSecondary.withOpacity(0.4),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
