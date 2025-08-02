import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

import '../../viewmodels/onboarding_viewmodel.dart';

class PersonalInfoNavigation extends ConsumerWidget {
  const PersonalInfoNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingViewModelProvider);
    final currentPageIndex = state.currentPageIndex;
    final isCurrentPageValid = ref.watch(
      onboardingViewModelProvider.select((s) => s.isCurrentPageValid()),
    );

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Back button
            if (currentPageIndex > 0)
              TextButton(
                onPressed: () {
                  ref.read(onboardingViewModelProvider.notifier).previousPage();
                },
                child: Text(
                  'Geri',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),

            const Spacer(),

            // Next/Continue button
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: isCurrentPageValid
                    ? () {
                        // Hide keyboard
                        FocusScope.of(context).unfocus();
                        ref
                            .read(onboardingViewModelProvider.notifier)
                            .nextPage();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  currentPageIndex >= OnboardingViewModel.questions.length
                      ? 'Devam'
                      : 'İleri',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
