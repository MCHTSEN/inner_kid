import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/first_analysis_state.dart';
import '../models/analysis_question.dart';

/// ViewModel for managing the first analysis feature state
class FirstAnalysisViewModel extends StateNotifier<FirstAnalysisState> {
  FirstAnalysisViewModel() : super(const FirstAnalysisState()) {
    _initializeQuestions();
  }

  final ImagePicker _picker = ImagePicker();

  /// Initialize predefined questions
  void _initializeQuestions() {
    final questions = [
      const AnalysisQuestion(
        id: '1',
        question: 'Çocuğunuzun yaşı nedir?',
        options: ['3-5 yaş', '6-8 yaş', '9-12 yaş', '13+ yaş'],
      ),
      const AnalysisQuestion(
        id: '2',
        question: 'Bu çizim hangi duygusal durumda yapıldı?',
        options: ['Mutlu', 'Sakin', 'Heyecanlı', 'Üzgün', 'Emin değilim'],
      ),
      const AnalysisQuestion(
        id: '3',
        question: 'Çocuğunuz bu çizimi ne kadar sürede tamamladı?',
        options: ['5-10 dakika', '10-20 dakika', '20-30 dakika', '30+ dakika'],
      ),
      const AnalysisQuestion(
        id: '4',
        question: 'Çizim yaparken çocuğunuzun davranışı nasıldı?',
        options: ['Odaklanmış', 'Aceleci', 'Sakin', 'Kararsız', 'Eğlenceli'],
      ),
    ];

    state = state.copyWith(questions: questions);
  }

  /// Upload image from gallery
  Future<void> uploadImageFromGallery() async {
    try {
      state = state.copyWith(isLoading: true);

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        state = state.copyWith(
          uploadedImage: imageFile,
          isImageUploaded: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error - could add error state to model
    }
  }

  /// Upload image from camera
  Future<void> uploadImageFromCamera() async {
    try {
      state = state.copyWith(isLoading: true);

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        state = state.copyWith(
          uploadedImage: imageFile,
          isImageUploaded: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error - could add error state to model
    }
  }

  /// Answer a question
  void answerQuestion(String questionId, String answer) {
    final updatedQuestions = state.questions.map((question) {
      if (question.id == questionId) {
        return question.copyWith(selectedAnswer: answer);
      }
      return question;
    }).toList();

    // Move to next question if current question is answered
    int nextIndex = state.currentQuestionIndex;
    if (state.currentQuestion?.id == questionId) {
      nextIndex = state.currentQuestionIndex + 1;
    }

    state = state.copyWith(
      questions: updatedQuestions,
      currentQuestionIndex: nextIndex,
      isCompleted: updatedQuestions.every((q) => q.isAnswered),
    );
  }

  /// Reset the analysis
  void reset() {
    state = const FirstAnalysisState();
    _initializeQuestions();
  }

  /// Submit the analysis
  Future<void> submitAnalysis() async {
    if (!state.allQuestionsAnswered || state.uploadedImage == null) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Here you would typically send data to your backend
      // For now, we'll just mark as completed
      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }
}

/// Provider for the FirstAnalysisViewModel
final firstAnalysisViewModelProvider =
    StateNotifierProvider<FirstAnalysisViewModel, FirstAnalysisState>(
  (ref) => FirstAnalysisViewModel(),
);
