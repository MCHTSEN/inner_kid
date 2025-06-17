import 'dart:io';

import 'analysis_question.dart';

/// State model for the first analysis feature
class FirstAnalysisState {
  final File? uploadedImage;
  final List<AnalysisQuestion> questions;
  final int currentQuestionIndex;
  final bool isImageUploaded;
  final bool isCompleted;
  final bool isLoading;
  final bool isAnalyzing; // New: Analysis in progress
  final bool isAnalysisCompleted; // New: Analysis finished
  final bool isPremiumUnlocked; // New: Premium content unlocked
  final Map<String, dynamic>? analysisResults; // New: Analysis results

  const FirstAnalysisState({
    this.uploadedImage,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.isImageUploaded = false,
    this.isCompleted = false,
    this.isLoading = false,
    this.isAnalyzing = false,
    this.isAnalysisCompleted = false,
    this.isPremiumUnlocked = false,
    this.analysisResults,
  });

  FirstAnalysisState copyWith({
    File? uploadedImage,
    List<AnalysisQuestion>? questions,
    int? currentQuestionIndex,
    bool? isImageUploaded,
    bool? isCompleted,
    bool? isLoading,
    bool? isAnalyzing,
    bool? isAnalysisCompleted,
    bool? isPremiumUnlocked,
    Map<String, dynamic>? analysisResults,
  }) {
    return FirstAnalysisState(
      uploadedImage: uploadedImage ?? this.uploadedImage,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isImageUploaded: isImageUploaded ?? this.isImageUploaded,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isAnalysisCompleted: isAnalysisCompleted ?? this.isAnalysisCompleted,
      isPremiumUnlocked: isPremiumUnlocked ?? this.isPremiumUnlocked,
      analysisResults: analysisResults ?? this.analysisResults,
    );
  }

  /// Get the current question being answered
  AnalysisQuestion? get currentQuestion {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  /// Get all answered questions
  List<AnalysisQuestion> get answeredQuestions {
    return questions.where((q) => q.isAnswered).toList();
  }

  /// Check if all questions are answered
  bool get allQuestionsAnswered {
    return questions.every((q) => q.isAnswered);
  }

  /// Get progress as a percentage
  double get progress {
    if (questions.isEmpty) return 0.0;
    return answeredQuestions.length / questions.length;
  }
}
