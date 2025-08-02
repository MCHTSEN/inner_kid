import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_kid/core/theme/theme.dart';

import '../models/onboarding_state.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import 'fake_loading_screen.dart';
import 'fake_results_screen.dart';
import 'image_upload_screen.dart';
import 'personal_info_screen.dart';
import 'social_proof_screen.dart';

class OnboardingFlowPage extends ConsumerWidget {
  const OnboardingFlowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingViewModelProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _buildCurrentStep(state.currentStep),
      ),
    );
  }

  Widget _buildCurrentStep(OnboardingStep currentStep) {
    switch (currentStep) {
      case OnboardingStep.intro:
        return const SocialProofScreen();
      case OnboardingStep.personalInfo:
        return const PersonalInfoScreen();
      case OnboardingStep.imageUpload:
        return const ImageUploadScreen();
      case OnboardingStep.fakeLoading:
        return const FakeLoadingScreen();
      case OnboardingStep.fakeResults:
        return const FakeResultsScreen();
      case OnboardingStep.realResults:
        return const FakeResultsScreen(); // For now, use fake results
    }
  }
}
