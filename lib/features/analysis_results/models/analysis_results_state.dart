import 'dart:io';
import '../services/ab_testing_service.dart';

/// State model for Analysis Results feature
///
/// Manages all state related to analysis results display,
/// premium status, animations, and A/B testing.
class AnalysisResultsState {
  final File? analyzedImage;
  final Map<String, String>? analysisData;
  final bool isPremiumUnlocked;
  final bool isBlurred;
  final SuccessHeaderVariant headerVariant;
  final String? userId;
  final DateTime pageLoadTime;
  final bool isAnimationCompleted;

  const AnalysisResultsState({
    this.analyzedImage,
    this.analysisData,
    this.isPremiumUnlocked = false,
    this.isBlurred = false,
    required this.headerVariant,
    this.userId,
    required this.pageLoadTime,
    this.isAnimationCompleted = false,
  });

  /// Create initial state with A/B testing variant selection
  factory AnalysisResultsState.initial({
    File? analyzedImage,
    Map<String, String>? analysisData,
    bool isBlurred = false,
    String? userId,
    SuccessHeaderVariant? variant,
  }) {
    return AnalysisResultsState(
      analyzedImage: analyzedImage,
      analysisData: analysisData,
      isPremiumUnlocked: !isBlurred,
      isBlurred: isBlurred,
      headerVariant:
          variant ?? ABTestingService.getVariantForUser(userId: userId),
      userId: userId,
      pageLoadTime: DateTime.now(),
    );
  }

  /// Copy state with updates
  AnalysisResultsState copyWith({
    File? analyzedImage,
    Map<String, String>? analysisData,
    bool? isPremiumUnlocked,
    bool? isBlurred,
    SuccessHeaderVariant? headerVariant,
    String? userId,
    DateTime? pageLoadTime,
    bool? isAnimationCompleted,
  }) {
    return AnalysisResultsState(
      analyzedImage: analyzedImage ?? this.analyzedImage,
      analysisData: analysisData ?? this.analysisData,
      isPremiumUnlocked: isPremiumUnlocked ?? this.isPremiumUnlocked,
      isBlurred: isBlurred ?? this.isBlurred,
      headerVariant: headerVariant ?? this.headerVariant,
      userId: userId ?? this.userId,
      pageLoadTime: pageLoadTime ?? this.pageLoadTime,
      isAnimationCompleted: isAnimationCompleted ?? this.isAnimationCompleted,
    );
  }

  /// Calculate time elapsed since page load
  Duration get timeElapsed => DateTime.now().difference(pageLoadTime);

  /// Check if user should see premium content
  bool get shouldShowPremiumContent => isPremiumUnlocked;

  /// Check if blur overlay should be shown
  bool get shouldShowBlurOverlay => isBlurred && !isPremiumUnlocked;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnalysisResultsState &&
        other.analyzedImage == analyzedImage &&
        other.analysisData == analysisData &&
        other.isPremiumUnlocked == isPremiumUnlocked &&
        other.isBlurred == isBlurred &&
        other.headerVariant == headerVariant &&
        other.userId == userId &&
        other.pageLoadTime == pageLoadTime &&
        other.isAnimationCompleted == isAnimationCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      analyzedImage,
      analysisData,
      isPremiumUnlocked,
      isBlurred,
      headerVariant,
      userId,
      pageLoadTime,
      isAnimationCompleted,
    );
  }

  @override
  String toString() {
    return 'AnalysisResultsState('
        'isPremiumUnlocked: $isPremiumUnlocked, '
        'isBlurred: $isBlurred, '
        'headerVariant: ${headerVariant.name}, '
        'userId: $userId, '
        'isAnimationCompleted: $isAnimationCompleted'
        ')';
  }
}
