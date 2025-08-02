import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/personal_info/personal_info_header.dart';
import '../components/personal_info/personal_info_navigation.dart';
import '../components/personal_info/question_page_view.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize controllers when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingViewModelProvider.notifier).initializePageController();
      ref
          .read(onboardingViewModelProvider.notifier)
          .initializeVideoController();
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightGreenAccent.withValues(alpha: 0.3),
              Colors.lightGreenAccent.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress indicator
              const PersonalInfoHeader(),

              // Page view for questions
              const Expanded(
                child: QuestionPageView(),
              ),

              // Navigation buttons
              const PersonalInfoNavigation(),
            ],
          ),
        ),
      ),
    );
  }
}
