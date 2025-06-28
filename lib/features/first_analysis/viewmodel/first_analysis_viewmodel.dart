import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inner_kid/core/services/firestore_service.dart';
import 'package:inner_kid/core/services/storage_service.dart';
import 'package:inner_kid/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:uuid/uuid.dart';

import '../models/analysis_question.dart';
import '../models/first_analysis_state.dart';

/// ViewModel for managing the first analysis feature state
class FirstAnalysisViewModel extends StateNotifier<FirstAnalysisState> {
  final StorageService _storageService;
  final FirestoreService _firestoreService;
  final Ref _ref;

  FirstAnalysisViewModel({
    required StorageService storageService,
    required FirestoreService firestoreService,
    required Ref ref,
  })  : _storageService = storageService,
        _firestoreService = firestoreService,
        _ref = ref,
        super(const FirstAnalysisState()) {
    _initializeQuestions();
  }

  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

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

  /// Submit the analysis with Firebase Storage integration
  Future<void> submitAnalysis() async {
    if (!state.allQuestionsAnswered || state.uploadedImage == null) {
      return;
    }

    try {
      // Start analysis process
      state = state.copyWith(
        isAnalyzing: true,
        isLoading: false,
        isCompleted: true,
      );

      // Get authenticated user
      final authState = _ref.read(authViewModelProvider);
      if (!authState.isAuthenticated || authState.userProfile == null) {
        throw Exception('User must be authenticated');
      }

      final userId = authState.firebaseUser!.uid;
      final drawingId = _uuid.v4();
      final childId = 'default_child'; // TODO: Get from selected child

      // Upload image to Firebase Storage
      final imageUrl = await _storageService.uploadDrawing(
        imageFile: state.uploadedImage!,
        userId: userId,
        childId: childId,
        drawingId: drawingId,
      );

      // Create analysis record in Firestore (placeholder)
      // TODO: Create proper drawing analysis model and save to Firestore

      // For now, just mark as completed
      state = state.copyWith(
        isAnalyzing: false,
        isAnalysisCompleted: true,
        analysisResults: {
          'drawingId': drawingId,
          'imageUrl': imageUrl,
          'answers': Map.fromEntries(
            state.questions.map((q) => MapEntry(q.id, q.selectedAnswer ?? '')),
          ),
        },
      );
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        isLoading: false,
      );
      // Handle error
      rethrow;
    }
  }

  /// Unlock premium content after payment
  void unlockPremium() {
    state = state.copyWith(isPremiumUnlocked: true);
  }

  /// Reset premium status (for testing)
  void resetPremium() {
    state = state.copyWith(isPremiumUnlocked: false);
  }
}

/// Provider for the FirstAnalysisViewModel
final firstAnalysisViewModelProvider =
    StateNotifierProvider<FirstAnalysisViewModel, FirstAnalysisState>(
  (ref) => FirstAnalysisViewModel(
    storageService: ref.watch(storageServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
    ref: ref,
  ),
);

// Import providers from auth viewmodel
final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());
