import 'dart:io';

/// Analysis status enum
enum AnalysisStatus {
  idle,
  uploading,
  analyzing,
  completed,
  failed,
  cancelled,
}

/// Analysis progress data
class AnalysisProgress {
  final double progress; // 0.0 to 1.0
  final String currentStep;
  final String? message;
  final DateTime timestamp;

  const AnalysisProgress({
    required this.progress,
    required this.currentStep,
    this.message,
    required this.timestamp,
  });

  AnalysisProgress copyWith({
    double? progress,
    String? currentStep,
    String? message,
    DateTime? timestamp,
  }) {
    return AnalysisProgress(
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Analysis insights data
class AnalysisInsights {
  final String primaryInsight;
  final double emotionalScore; // 1-10
  final double creativityScore; // 1-10
  final double developmentScore; // 1-10
  final List<String> keyFindings;
  final Map<String, dynamic> detailedAnalysis;
  final List<String> recommendations;
  final DateTime createdAt;

  const AnalysisInsights({
    required this.primaryInsight,
    required this.emotionalScore,
    required this.creativityScore,
    required this.developmentScore,
    required this.keyFindings,
    required this.detailedAnalysis,
    required this.recommendations,
    required this.createdAt,
  });

  factory AnalysisInsights.fromMap(Map<String, dynamic> map) {
    return AnalysisInsights(
      primaryInsight: map['primaryInsight'] ?? '',
      emotionalScore: (map['emotionalScore'] ?? 0).toDouble(),
      creativityScore: (map['creativityScore'] ?? 0).toDouble(),
      developmentScore: (map['developmentScore'] ?? 0).toDouble(),
      keyFindings: List<String>.from(map['keyFindings'] ?? []),
      detailedAnalysis:
          Map<String, dynamic>.from(map['detailedAnalysis'] ?? {}),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryInsight': primaryInsight,
      'emotionalScore': emotionalScore,
      'creativityScore': creativityScore,
      'developmentScore': developmentScore,
      'keyFindings': keyFindings,
      'detailedAnalysis': detailedAnalysis,
      'recommendations': recommendations,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Analysis results data
class AnalysisResults {
  final String id;
  final String childId;
  final String userId;
  final String imageUrl;
  final AnalysisInsights insights;
  final String? reportUrl;
  final DateTime createdAt;
  final DateTime? completedAt;

  const AnalysisResults({
    required this.id,
    required this.childId,
    required this.userId,
    required this.imageUrl,
    required this.insights,
    this.reportUrl,
    required this.createdAt,
    this.completedAt,
  });

  factory AnalysisResults.fromMap(Map<String, dynamic> map, String id) {
    return AnalysisResults(
      id: id,
      childId: map['childId'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      insights: AnalysisInsights.fromMap(map['insights'] ?? {}),
      reportUrl: map['reportUrl'],
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'userId': userId,
      'imageUrl': imageUrl,
      'insights': insights.toMap(),
      'reportUrl': reportUrl,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

/// Main analysis state
class AnalysisState {
  final AnalysisStatus status;
  final File? selectedImage;
  final String? analysisId;
  final AnalysisProgress? progress;
  final AnalysisResults? results;
  final String? errorMessage;
  final bool isLoading;
  final bool canCancel;

  const AnalysisState({
    this.status = AnalysisStatus.idle,
    this.selectedImage,
    this.analysisId,
    this.progress,
    this.results,
    this.errorMessage,
    this.isLoading = false,
    this.canCancel = false,
  });

  AnalysisState copyWith({
    AnalysisStatus? status,
    File? selectedImage,
    String? analysisId,
    AnalysisProgress? progress,
    AnalysisResults? results,
    String? errorMessage,
    bool? isLoading,
    bool? canCancel,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      selectedImage: selectedImage ?? this.selectedImage,
      analysisId: analysisId ?? this.analysisId,
      progress: progress ?? this.progress,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      canCancel: canCancel ?? this.canCancel,
    );
  }

  // Helper getters
  bool get hasError => errorMessage != null;
  bool get isIdle => status == AnalysisStatus.idle;
  bool get isUploading => status == AnalysisStatus.uploading;
  bool get isAnalyzing => status == AnalysisStatus.analyzing;
  bool get isCompleted => status == AnalysisStatus.completed;
  bool get isFailed => status == AnalysisStatus.failed;
  bool get isCancelled => status == AnalysisStatus.cancelled;
  bool get isProcessing => isUploading || isAnalyzing;
  bool get hasResults => results != null;

  double get overallProgress => progress?.progress ?? 0.0;
  String get currentStepMessage => progress?.currentStep ?? '';
}
