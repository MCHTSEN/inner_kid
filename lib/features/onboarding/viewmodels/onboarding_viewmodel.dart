import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/onboarding_state.dart';

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final Logger _logger = Logger();
  final ImagePicker _picker = ImagePicker();

  OnboardingViewModel() : super(OnboardingState.initial());

  void nextStep() {
    _logger.d('Next step called. Current step: ${state.currentStep}');
    
    switch (state.currentStep) {
      case OnboardingStep.intro:
        state = state.copyWith(currentStep: OnboardingStep.personalInfo);
        break;
      case OnboardingStep.personalInfo:
        if (state.isPersonalInfoComplete) {
          state = state.copyWith(currentStep: OnboardingStep.imageUpload);
        }
        break;
      case OnboardingStep.imageUpload:
        if (state.imageUrl != null) {
          state = state.copyWith(currentStep: OnboardingStep.fakeLoading);
          _simulateFakeLoading();
        }
        break;
      case OnboardingStep.fakeLoading:
        state = state.copyWith(currentStep: OnboardingStep.fakeResults);
        break;
      case OnboardingStep.fakeResults:
        state = state.copyWith(currentStep: OnboardingStep.realResults);
        break;
      case OnboardingStep.realResults:
        // This is the final step, navigation should be handled by the UI
        break;
    }
  }

  void previousStep() {
    _logger.d('Previous step called. Current step: ${state.currentStep}');
    
    switch (state.currentStep) {
      case OnboardingStep.personalInfo:
        state = state.copyWith(currentStep: OnboardingStep.intro);
        break;
      case OnboardingStep.imageUpload:
        state = state.copyWith(currentStep: OnboardingStep.personalInfo);
        break;
      case OnboardingStep.fakeLoading:
        state = state.copyWith(currentStep: OnboardingStep.imageUpload);
        break;
      case OnboardingStep.fakeResults:
        state = state.copyWith(currentStep: OnboardingStep.fakeLoading);
        break;
      case OnboardingStep.realResults:
        state = state.copyWith(currentStep: OnboardingStep.fakeResults);
        break;
      case OnboardingStep.intro:
        // Cannot go back from intro
        break;
    }
  }

  void updateChildName(String name) {
    state = state.copyWith(childName: name);
  }

  void updateChildAge(int age) {
    state = state.copyWith(childAge: age);
  }

  void updateChildGender(String gender) {
    state = state.copyWith(childGender: gender);
  }

  void updateSiblingCount(int count) {
    state = state.copyWith(siblingCount: count);
  }

  void updateAttendsSchool(bool attends) {
    state = state.copyWith(attendsSchool: attends);
  }

  Future<void> pickImage() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        state = state.copyWith(
          imageUrl: image.path,
          isLoading: false,
        );
        nextStep(); // Auto-advance to next step after image selection
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      _logger.e('Error picking image: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Görsel seçilirken bir hata oluştu',
      );
    }
  }

  void _simulateFakeLoading() {
    Future.delayed(const Duration(seconds: 3), () {
      if (state.currentStep == OnboardingStep.fakeLoading) {
        nextStep();
      }
    });
  }

  void reset() {
    state = OnboardingState.initial();
  }
}

final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) {
  return OnboardingViewModel();
});
