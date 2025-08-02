import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';

import '../models/onboarding_state.dart';

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final Logger _logger = Logger();
  final ImagePicker _picker = ImagePicker();

  // Questions list as static constant
  static const List<Map<String, dynamic>> questions = [
    {
      'question': 'Çocuğunuzun adı nedir?',
      'type': 'text',
      'field': 'name',
    },
    {
      'question': 'Kaç yaşında?',
      'type': 'number',
      'field': 'age',
    },
    {
      'question': 'Cinsiyeti nedir?',
      'type': 'gender',
      'field': 'gender',
    },
    {
      'question': 'Kaç kardeşi var?',
      'type': 'number',
      'field': 'siblings',
    },
    {
      'question': 'Anaokuluna veya okula gidiyor mu?',
      'type': 'boolean',
      'field': 'school',
    },
  ];

  OnboardingViewModel() : super(OnboardingState.initial());

  // Personal Info Screen Methods
  void initializePageController() {
    if (state.pageController == null) {
      final pageController = PageController();
      state = state.copyWith(pageController: pageController);

      // Initialize with existing data if available
      int initialPage = 0;
      if (state.childName != null) initialPage = 1;
      if (state.childAge != null) initialPage = 2;
      if (state.childGender != null) initialPage = 3;
      if (state.siblingCount != null) initialPage = 4;
      if (state.attendsSchool != null) initialPage = 5;

      if (initialPage > 0) {
        state = state.copyWith(currentPageIndex: initialPage);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          pageController.jumpToPage(initialPage);
        });
      }
    }
  }

  Future<void> initializeVideoController() async {
    if (state.videoController == null) {
      final videoController =
          VideoPlayerController.asset('assets/video/girl_drawing.mp4');
      state = state.copyWith(videoController: videoController);

      await videoController.initialize();
      videoController.play();

      // Loop video
      videoController.addListener(() {
        if (videoController.value.position >= videoController.value.duration) {
          videoController.seekTo(Duration.zero);
          videoController.play();
        }
      });
    }
  }

  void disposeVideoController() {
    state.videoController?.dispose();
    state = state.copyWith(videoController: null);
  }

  void nextPage() {
    // Check if we're on the last question
    if (state.currentPageIndex == questions.length - 1) {
      // Last question answered, move to social proof section
      state = state.copyWith(currentPageIndex: state.currentPageIndex + 1);
      state.pageController?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (state.currentPageIndex < questions.length) {
      // Regular page navigation
      state = state.copyWith(currentPageIndex: state.currentPageIndex + 1);
      state.pageController?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (state.currentPageIndex == questions.length) {
      // Social proof section, move to next step
      if (state.isPersonalInfoComplete) {
        nextStep();
      }
    }
  }

  void previousPage() {
    if (state.currentPageIndex > 0) {
      state = state.copyWith(currentPageIndex: state.currentPageIndex - 1);
      state.pageController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      previousStep();
    }
  }

  void nextStep() {
    _logger.d('Next step called. Current step: ${state.currentStep}');

    switch (state.currentStep) {
      case OnboardingStep.intro:
        state = state.copyWith(currentStep: OnboardingStep.personalInfo);
        break;
      case OnboardingStep.personalInfo:
        if (state.isPersonalInfoComplete) {
          // Use replacement navigation to prevent going back
          _replaceWithImageUpload();
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

  void _replaceWithImageUpload() {
    // Reset the navigation stack and go directly to image upload
    state = state.copyWith(currentStep: OnboardingStep.imageUpload);
    _logger.d('Replaced navigation stack with image upload');
  }

  void previousStep() {
    _logger.d('Previous step called. Current step: ${state.currentStep}');

    switch (state.currentStep) {
      case OnboardingStep.personalInfo:
        state = state.copyWith(currentStep: OnboardingStep.intro);
        break;
      case OnboardingStep.imageUpload:
        // Cannot go back from image upload
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

  @override
  void dispose() {
    disposeVideoController();
    state.pageController?.dispose();
    super.dispose();
  }
}

final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) {
  return OnboardingViewModel();
});
