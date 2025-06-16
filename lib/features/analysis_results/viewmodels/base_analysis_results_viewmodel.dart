import 'dart:io';
import 'package:flutter/material.dart';
import '../models/analysis_results_state.dart';
import '../services/ab_testing_service.dart';

/// Abstract base viewmodel for Analysis Results
///
/// Defines the contract for managing analysis results state,
/// premium functionality, and A/B testing integration.
abstract class BaseAnalysisResultsViewModel extends ChangeNotifier {
  /// Current state of the analysis results
  AnalysisResultsState get state;

  /// Initialize the viewmodel with required data
  void initialize({
    File? analyzedImage,
    Map<String, String>? analysisData,
    bool isBlurred = false,
    String? userId,
    SuccessHeaderVariant? variant,
  });

  /// Unlock premium features
  Future<void> unlockPremium();

  /// Show paywall to user
  Future<void> showPaywall({String trigger = 'manual'});

  /// Track analytics events
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? data});

  /// Share analysis results
  Future<void> shareResults();

  /// Download analysis report
  Future<void> downloadReport();

  /// Complete page animation
  void completeAnimation();

  /// Track page view for A/B testing
  Future<void> trackPageView();

  /// Track conversion event
  Future<void> trackConversion({
    String? trigger,
    Duration? timeToConvert,
  });

  /// Get success header message based on A/B testing variant
  String get successHeaderMessage => state.headerVariant.message;

  /// Check if premium features are unlocked
  bool get isPremiumUnlocked => state.isPremiumUnlocked;

  /// Check if content should be blurred
  bool get shouldShowBlurOverlay => state.shouldShowBlurOverlay;

  /// Get current A/B testing variant
  SuccessHeaderVariant get currentVariant => state.headerVariant;

  /// Clean up resources
  @override
  void dispose();
}
