/// Model class representing an analysis question
class AnalysisQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String? selectedAnswer;

  const AnalysisQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.selectedAnswer,
  });

  AnalysisQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    String? selectedAnswer,
  }) {
    return AnalysisQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
    );
  }

  bool get isAnswered => selectedAnswer != null;
}
