import 'package:inner_kid/core/models/child_profile.dart';

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
}
