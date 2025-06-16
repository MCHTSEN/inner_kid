import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_results_state.dart';
import '../services/ab_testing_service.dart';
import 'base_analysis_results_viewmodel.dart';

/// Riverpod provider for Analysis Results ViewModel
final analysisResultsViewModelProvider =
    ChangeNotifierProvider.autoDispose<AnalysisResultsViewModel>(
  (ref) {
    print('🔵 Riverpod: Creating AnalysisResultsViewModel instance');
    final viewModel = AnalysisResultsViewModel();
    print('🟢 Riverpod: AnalysisResultsViewModel created: $viewModel');
    return viewModel;
  },
);

/// Concrete implementation of Analysis Results ViewModel
///
/// Manages state for analysis results page including premium status,
/// A/B testing, analytics tracking, and user interactions.
class AnalysisResultsViewModel extends BaseAnalysisResultsViewModel {
  AnalysisResultsState _state = AnalysisResultsState(
    headerVariant: SuccessHeaderVariant.emotional,
    pageLoadTime: DateTime.now(),
  );

  AnalysisResultsViewModel() {
    print('🔵 AnalysisResultsViewModel: Constructor called');
  }

  @override
  AnalysisResultsState get state {
    print(
        '🟢 AnalysisResultsViewModel: state getter called, returning: $_state');
    return _state;
  }

  @override
  void initialize({
    File? analyzedImage,
    Map<String, String>? analysisData,
    bool isBlurred = false,
    String? userId,
    SuccessHeaderVariant? variant,
  }) {
    print('🟡 AnalysisResultsViewModel: initialize called with:');
    print('  - analyzedImage: $analyzedImage');
    print('  - analysisData: $analysisData');
    print('  - isBlurred: $isBlurred');
    print('  - userId: $userId');
    print('  - variant: $variant');

    try {
      _state = AnalysisResultsState.initial(
        analyzedImage: analyzedImage,
        analysisData: analysisData,
        isBlurred: isBlurred,
        userId: userId,
        variant: variant,
      );

      print(
          '🟢 AnalysisResultsViewModel: State initialized successfully: $_state');

      // Track initial page view
      trackPageView();

      notifyListeners();
      print('🟢 AnalysisResultsViewModel: notifyListeners called');
    } catch (e, stackTrace) {
      print('🔴 AnalysisResultsViewModel: Error in initialize: $e');
      print('🔴 StackTrace: $stackTrace');
    }
  }

  @override
  Future<void> unlockPremium() async {
    if (_state.isPremiumUnlocked) return;

    // Calculate time to convert for analytics
    final timeToConvert = _state.timeElapsed;

    _state = _state.copyWith(
      isPremiumUnlocked: true,
      isBlurred: false,
    );

    // Track conversion event
    await trackConversion(
      trigger: 'premium_unlock',
      timeToConvert: timeToConvert,
    );

    notifyListeners();
  }

  @override
  Future<void> showPaywall({String trigger = 'manual'}) async {
    // Track paywall shown event
    await ABTestingService.trackPaywallShown(
      variant: _state.headerVariant,
      userId: _state.userId,
      trigger: trigger,
    );

    // The actual paywall display is handled by the UI
    // This method is for analytics tracking
  }

  @override
  Future<void> trackEvent(String eventName,
      {Map<String, dynamic>? data}) async {
    await ABTestingService.trackVariantEvent(
      variant: _state.headerVariant,
      eventName: eventName,
      userId: _state.userId,
      additionalData: data,
    );
  }

  @override
  Future<void> shareResults() async {
    if (!_state.isPremiumUnlocked) {
      await showPaywall(trigger: 'share_button');
      return;
    }

    await trackEvent('share_results');

    // TODO: Implement actual sharing functionality
    // This could integrate with Flutter's share_plus package
    // Share.share('Check out my child\'s analysis results!');
  }

  @override
  Future<void> downloadReport() async {
    if (!_state.isPremiumUnlocked) {
      await showPaywall(trigger: 'download_button');
      return;
    }

    await trackEvent('download_report');

    // TODO: Implement actual PDF generation and download
    // This could integrate with pdf package and file system
  }

  @override
  void completeAnimation() {
    _state = _state.copyWith(isAnimationCompleted: true);
    notifyListeners();
  }

  @override
  Future<void> trackPageView() async {
    await ABTestingService.trackPageView(
      variant: _state.headerVariant,
      userId: _state.userId,
      isPremium: _state.isPremiumUnlocked,
    );
  }

  @override
  Future<void> trackConversion({
    String? trigger,
    Duration? timeToConvert,
  }) async {
    await ABTestingService.trackConversion(
      variant: _state.headerVariant,
      userId: _state.userId,
      conversionTrigger: trigger,
      timeToConvert: timeToConvert,
    );
  }

  /// Handle blur area click
  Future<void> onBlurAreaClicked() async {
    await showPaywall(trigger: 'blur_click');
  }

  /// Handle premium button click
  Future<void> onPremiumButtonClicked() async {
    await showPaywall(trigger: 'cta_button');
  }

  /// Handle auto paywall trigger
  Future<void> onAutoPaywallTrigger() async {
    if (_state.shouldShowBlurOverlay) {
      await showPaywall(trigger: 'auto');
    }
  }

  /// Reset premium status for testing
  void resetPremium() {
    _state = _state.copyWith(
      isPremiumUnlocked: false,
      isBlurred: true,
    );
    notifyListeners();
  }

  /// Update A/B testing variant (for testing purposes)
  void updateVariant(SuccessHeaderVariant variant) {
    _state = _state.copyWith(headerVariant: variant);
    notifyListeners();
  }

  /// Get analytics data for debugging
  Map<String, dynamic> getAnalyticsData() {
    return {
      'variant': _state.headerVariant.name,
      'variant_message': _state.headerVariant.message,
      'user_id': _state.userId,
      'is_premium': _state.isPremiumUnlocked,
      'is_blurred': _state.isBlurred,
      'page_load_time': _state.pageLoadTime.toIso8601String(),
      'time_elapsed_seconds': _state.timeElapsed.inSeconds,
    };
  }

  @override
  void dispose() {
    // Clean up any subscriptions or resources
    super.dispose();
  }
}
