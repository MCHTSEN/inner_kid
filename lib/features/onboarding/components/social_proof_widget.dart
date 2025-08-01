import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

class SocialProofWidget extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool isPrimary;

  const SocialProofWidget({
    super.key,
    required this.title,
    this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary 
            ? AppTheme.primaryColor.withOpacity(0.1)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary 
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPrimary 
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : AppTheme.surfaceColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isPrimary ? AppTheme.primaryColor : AppTheme.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
                color: isPrimary ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
