import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

import '../models/onboarding_state.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class ChildInfoCard extends ConsumerWidget {
  const ChildInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingViewModelProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.child_care,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Çocuk Bilgileri',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Child info grid
          _buildInfoGrid(state),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(OnboardingState state) {
    return Column(
      children: [
        // Name and Age row
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                label: 'Ad',
                value: state.childName ?? 'Belirtilmemiş',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                label: 'Yaş',
                value: state.childAge != null
                    ? '${state.childAge} yaş'
                    : 'Belirtilmemiş',
                icon: Icons.cake_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Gender and Siblings row
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                label: 'Cinsiyet',
                value: _getGenderText(state.childGender),
                icon: Icons.people_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                label: 'Kardeş Sayısı',
                value: state.siblingCount != null
                    ? '${state.siblingCount}'
                    : 'Belirtilmemiş',
                icon: Icons.family_restroom_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // School attendance
        _buildInfoItem(
          label: 'Okula Gidiyor mu?',
          value: _getSchoolText(state.attendsSchool),
          icon: Icons.school_outlined,
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getGenderText(String? gender) {
    switch (gender) {
      case 'male':
        return 'Erkek';
      case 'female':
        return 'Kız';
      default:
        return 'Belirtilmemiş';
    }
  }

  String _getSchoolText(bool? attendsSchool) {
    if (attendsSchool == null) {
      return 'Belirtilmemiş';
    }
    return attendsSchool ? 'Evet' : 'Hayır';
  }
}
