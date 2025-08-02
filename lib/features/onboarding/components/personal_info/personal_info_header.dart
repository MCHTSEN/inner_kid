import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

import '../../viewmodels/onboarding_viewmodel.dart';

class PersonalInfoHeader extends ConsumerWidget {
  const PersonalInfoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingViewModelProvider);
    final currentPageIndex = state.currentPageIndex;
    final totalPages =
        OnboardingViewModel.questions.length + 1; // +1 for social proof section

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          if (currentPageIndex > 0)
            IconButton(
              onPressed: () {
                ref.read(onboardingViewModelProvider.notifier).previousPage();
              },
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            )
          else
            const SizedBox(width: 48), // Spacer for alignment

          // Progress indicator
          Expanded(
            child: Column(
              children: [
                Text(
                  'Kişisel Sorular',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: currentPageIndex / totalPages,
                  backgroundColor: AppTheme.surfaceColor,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ],
            ),
          ),

          // Spacer for alignment
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
