import 'package:flutter/material.dart';
import 'package:inner_kid/core/models/child_profile.dart';
import 'package:video_player/video_player.dart';

import '../viewmodels/onboarding_viewmodel.dart';

enum OnboardingStep {
  intro,
  personalInfo,
  imageUpload,
  fakeLoading,
  fakeResults,
  realResults,
}

class OnboardingState {
  final OnboardingStep currentStep;
  final String? childName;
  final int? childAge;
  final String? childGender;
  final int? siblingCount;
  final bool? attendsSchool;
  final String? imageUrl;
  final bool isLoading;
  final String? errorMessage;

  // Personal Info Screen State
  final int currentPageIndex;
  final PageController? pageController;
  final VideoPlayerController? videoController;

  OnboardingState({
    required this.currentStep,
    this.childName,
    this.childAge,
    this.childGender,
    this.siblingCount,
    this.attendsSchool,
    this.imageUrl,
    this.isLoading = false,
    this.errorMessage,
    this.currentPageIndex = 0,
    this.pageController,
    this.videoController,
  });

  factory OnboardingState.initial() {
    return OnboardingState(
      currentStep: OnboardingStep.intro,
    );
  }

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    String? childName,
    int? childAge,
    String? childGender,
    int? siblingCount,
    bool? attendsSchool,
    String? imageUrl,
    bool? isLoading,
    String? errorMessage,
    int? currentPageIndex,
    PageController? pageController,
    VideoPlayerController? videoController,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      childName: childName ?? this.childName,
      childAge: childAge ?? this.childAge,
      childGender: childGender ?? this.childGender,
      siblingCount: siblingCount ?? this.siblingCount,
      attendsSchool: attendsSchool ?? this.attendsSchool,
      imageUrl: imageUrl ?? this.imageUrl,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      pageController: pageController ?? this.pageController,
      videoController: videoController ?? this.videoController,
    );
  }

  ChildProfile? get childProfile {
    if (childName == null || childAge == null || childGender == null) {
      return null;
    }

    // Calculate birth date based on age
    final now = DateTime.now();
    final birthDate = DateTime(now.year - childAge!, now.month, now.day);

    return ChildProfile(
      id: '', // Will be set when saved
      userId: '', // Will be set when saved
      name: childName!,
      birthDate: birthDate,
      gender: childGender!,
      createdAt: now,
      updatedAt: now,
    );
  }

  bool get isPersonalInfoComplete {
    return childName != null &&
        childAge != null &&
        childGender != null &&
        siblingCount != null &&
        attendsSchool != null;
  }

  bool isCurrentPageValid() {
    // Social proof section (index 4) doesn't require answers
    if (currentPageIndex == 4) {
      return true;
    }

    // Adjust index for social proof section
    int questionIndex = currentPageIndex;
    if (questionIndex > 4) questionIndex--;

    if (questionIndex < 0 ||
        questionIndex >= OnboardingViewModel.questions.length) {
      return true; // Social proof section doesn't require answers
    }

    final question = OnboardingViewModel.questions[questionIndex];

    switch (question['field']) {
      case 'name':
        return childName != null && childName!.isNotEmpty;
      case 'age':
        return childAge != null && childAge! > 0;
      case 'gender':
        return childGender != null && childGender!.isNotEmpty;
      case 'siblings':
        return siblingCount != null;
      case 'school':
        return attendsSchool != null;
      default:
        return false;
    }
  }
}
