import 'dart:math';

/// A/B Testing configuration for success header messages
///
/// This enum defines different message variants for A/B testing
/// to optimize user engagement and conversion rates.
enum SuccessHeaderVariant {
  /// Emotional revelation message
  emotional(
      'Çocuğunuzun çiziminde gizli kalan duygular, artık görünür hale geliyor.'),

  /// Scientific insight message
  scientific('Bilimsel analiz ile çocuğunuzun iç dünyasını keşfedin.'),

  /// Development focused message
  development(
      'Çocuğunuzun gelişim yolculuğunda size rehber olacak önemli ipuçları.'),

  /// Achievement focused message
  achievement('Çocuğunuzun yaratıcı potansiyeli ortaya çıktı!');

  const SuccessHeaderVariant(this.message);

  /// The message text to display
  final String message;
}

/// Service for managing A/B testing variants and analytics
class ABTestingService {
  static const String _defaultUserIdPrefix = 'user_';

  /// Get a variant based on user ID or other criteria for A/B testing
  ///
  /// This uses a hash-based selection to ensure consistent variant assignment
  /// for the same user across sessions.
  ///
  /// In production, this can be replaced with a more sophisticated A/B testing
  /// framework like Firebase Remote Config, Optimizely, or Amplitude.
  static SuccessHeaderVariant getVariantForUser({
    String? userId,
    DateTime? timestamp,
  }) {
    final String hashSource = userId ??
        '$_defaultUserIdPrefix${timestamp?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}';

    final hash = hashSource.hashCode;
    const variants = SuccessHeaderVariant.values;

    return variants[hash.abs() % variants.length];
  }

  /// Get random variant for testing purposes
  static SuccessHeaderVariant getRandomVariant() {
    final random = Random();
    const variants = SuccessHeaderVariant.values;
    return variants[random.nextInt(variants.length)];
  }

  /// Track A/B test analytics event
  ///
  /// This method should be connected to your analytics service
  /// (Firebase Analytics, Mixpanel, etc.)
  static Future<void> trackVariantEvent({
    required SuccessHeaderVariant variant,
    required String eventName,
    String? userId,
    Map<String, dynamic>? additionalData,
  }) async {
    // TODO: Implement actual analytics tracking
    final eventData = {
      'variant': variant.name,
      'variant_message': variant.message,
      'user_id': userId,
      'timestamp': DateTime.now().toIso8601String(),
      ...?additionalData,
    };

    // For now, just print to console (replace with actual analytics call)
    print('A/B Test Event: $eventName - $eventData');

    // Example integration points:
    // - Firebase Analytics: FirebaseAnalytics.instance.logEvent()
    // - Mixpanel: Mixpanel.track()
    // - Custom analytics endpoint: http.post()
  }

  /// Track conversion event (when user upgrades to premium)
  static Future<void> trackConversion({
    required SuccessHeaderVariant variant,
    String? userId,
    String? conversionTrigger,
    Duration? timeToConvert,
  }) async {
    await trackVariantEvent(
      variant: variant,
      eventName: 'premium_conversion',
      userId: userId,
      additionalData: {
        'conversion_trigger': conversionTrigger,
        'time_to_convert_seconds': timeToConvert?.inSeconds,
      },
    );
  }

  /// Track page view event
  static Future<void> trackPageView({
    required SuccessHeaderVariant variant,
    String? userId,
    bool isPremium = false,
  }) async {
    await trackVariantEvent(
      variant: variant,
      eventName: 'analysis_results_view',
      userId: userId,
      additionalData: {
        'is_premium': isPremium,
      },
    );
  }

  /// Track paywall shown event
  static Future<void> trackPaywallShown({
    required SuccessHeaderVariant variant,
    String? userId,
    required String trigger,
  }) async {
    await trackVariantEvent(
      variant: variant,
      eventName: 'paywall_shown',
      userId: userId,
      additionalData: {
        'trigger': trigger, // 'auto', 'blur_click', 'button_click'
      },
    );
  }

  /// Get variant configuration for testing
  ///
  /// This can be used to override variants in test environments
  /// or for manual testing of different variants
  static Map<String, SuccessHeaderVariant> getTestVariants() {
    return {
      for (var variant in SuccessHeaderVariant.values) variant.name: variant,
    };
  }

  /// Calculate variant distribution for analytics
  ///
  /// This method can be used to analyze the distribution of variants
  /// across your user base for statistical analysis
  static Map<SuccessHeaderVariant, double> calculateVariantDistribution(
    List<String> userIds,
  ) {
    final variantCounts = <SuccessHeaderVariant, int>{};

    for (final userId in userIds) {
      final variant = getVariantForUser(userId: userId);
      variantCounts[variant] = (variantCounts[variant] ?? 0) + 1;
    }

    final total = userIds.length;
    return variantCounts.map(
      (variant, count) => MapEntry(variant, count / total),
    );
  }
}
