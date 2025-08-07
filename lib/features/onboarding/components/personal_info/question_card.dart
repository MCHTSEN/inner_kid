import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

import '../../models/onboarding_state.dart';
import '../../viewmodels/onboarding_viewmodel.dart';

class QuestionCard extends ConsumerWidget {
  final Map<String, dynamic> question;
  final int questionIndex;

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingViewModelProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question text
          Text(
            question['question'],
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          // Input field based on question type
          if (question['type'] == 'text')
            _buildNameInput(ref, state)
          else if (question['type'] == 'number')
            _buildNumberInput(question['field'], ref, state)
          else if (question['type'] == 'gender')
            _buildGenderSelection(ref, state)
          else if (question['type'] == 'boolean')
            _buildBooleanSelection(ref, state)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildNameInput(WidgetRef ref, OnboardingState state) {
    return Builder(
      builder: (context) => TextField(
        decoration: const InputDecoration(
          hintText: 'Çocuğunuzun adını girin',
        ),
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: AppTheme.textPrimary,
        ),
        textCapitalization: TextCapitalization.words,
        onChanged: (value) {
          ref.read(onboardingViewModelProvider.notifier).updateChildName(value);
        },
        onSubmitted: (_) {
          // Hide keyboard
          FocusScope.of(context).unfocus();
          ref.read(onboardingViewModelProvider.notifier).nextPage();
        },
      ),
    );
  }

  Widget _buildNumberInput(String field, WidgetRef ref, OnboardingState state) {
    if (field == 'age') {
      return _buildAgeSelection(ref, state);
    } else {
      return _buildSiblingSelection(ref, state);
    }
  }

  Widget _buildSiblingSelection(WidgetRef ref, OnboardingState state) {
    final siblingCounts = [0, 1, 2, 3, 4, 5, 6, 7, 8];

    return Column(
      children: [
     
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: siblingCounts.length,
          itemBuilder: (context, index) {
            final count = siblingCounts[index];
            final isSelected = state.siblingCount == count;

            return GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                ref
                    .read(onboardingViewModelProvider.notifier)
                    .updateSiblingCount(count);
                await Future.delayed(const Duration(milliseconds: 300));
                ref.read(onboardingViewModelProvider.notifier).nextPage();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade200,
                  ),
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAgeSelection(WidgetRef ref, OnboardingState state) {
    final ages = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
        .reversed
        .toList();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: ages.length,
          itemBuilder: (context, index) {
            final age = ages[index];
            final isSelected = state.childAge == age;

            return GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                ref
                    .read(onboardingViewModelProvider.notifier)
                    .updateChildAge(age);
                await Future.delayed(const Duration(milliseconds: 300));
                ref.read(onboardingViewModelProvider.notifier).nextPage();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade200,
                  ),
                ),
                child: Center(
                  child: Text(
                    age.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGenderSelection(WidgetRef ref, OnboardingState state) {
    final genders = ['Kız', 'Erkek', 'Diğer'];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: genders.length,
          itemBuilder: (context, index) {
            final gender = genders[index];
            final isSelected = state.childGender == gender;

            return GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                ref
                    .read(onboardingViewModelProvider.notifier)
                    .updateChildGender(gender);
                await Future.delayed(const Duration(milliseconds: 300));
                ref.read(onboardingViewModelProvider.notifier).nextPage();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade200,
                  ),
                ),
                child: Center(
                  child: Text(
                    gender,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBooleanSelection(WidgetRef ref, OnboardingState state) {
    final schoolOptions = ['Evet', 'Hayır'];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: schoolOptions.length,
          itemBuilder: (context, index) {
            final option = schoolOptions[index];
            final value = option == 'Evet';
            final isSelected = state.attendsSchool == value;

            return GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                ref
                    .read(onboardingViewModelProvider.notifier)
                    .updateAttendsSchool(value);
                await Future.delayed(const Duration(milliseconds: 300));
                // Don't auto-advance for the last question, let user click "Devam"
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade200,
                  ),
                ),
                child: Center(
                  child: Text(
                    option,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
