import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../models/analysis_state.dart';

class AnalysisViewModel extends StateNotifier<AnalysisState> {
  final StorageService _storageService;
  final FirestoreService _firestoreService;
  final Ref _ref;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  Timer? _progressTimer;
  StreamSubscription? _progressSubscription;

  AnalysisViewModel({
    required StorageService storageService,
    required FirestoreService firestoreService,
    required Ref ref,
  })  : _storageService = storageService,
        _firestoreService = firestoreService,
        _ref = ref,
        super(const AnalysisState());

  @override
  void dispose() {
    _progressTimer?.cancel();
    _progressSubscription?.cancel();
    super.dispose();
  }

  /// Start analysis from image file
  Future<void> startAnalysis({
    required File imageFile,
    String? childId,
    Map<String, String>? questionnaire,
  }) async {
    try {
      // Get authenticated user
      final authState = _ref.read(authViewModelProvider);
      if (!authState.isAuthenticated || authState.userProfile == null) {
        throw Exception('User must be authenticated');
      }

      final userId = authState.firebaseUser!.uid;
      final analysisId = _uuid.v4();
      final finalChildId = childId ?? 'default_child';

      _logger.i('Starting analysis: $analysisId');

      // Set initial state
      state = state.copyWith(
        status: AnalysisStatus.uploading,
        selectedImage: imageFile,
        analysisId: analysisId,
        canCancel: true,
        isLoading: true,
        errorMessage: null,
      );

      // Step 1: Upload image to Firebase Storage
      await _updateProgress(0.1, 'Görsel yükleniyor...');

      final imageUrl = await _storageService.uploadDrawing(
        imageFile: imageFile,
        userId: userId,
        childId: finalChildId,
        drawingId: analysisId,
      );

      await _updateProgress(0.3, 'Görsel yüklendi, analiz başlatılıyor...');

      // Step 2: Create analysis record in Firestore
      final analysisData = {
        'id': analysisId,
        'userId': userId,
        'childId': finalChildId,
        'imageUrl': imageUrl,
        'uploadDate': DateTime.now().toIso8601String(),
        'testType': 'family_drawing',
        'status': 'analyzing',
        'questionnaire': questionnaire ?? {},
        'recommendations': <String>[],
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _firestoreService.batchWrite([
        {
          'type': 'create',
          'collection': 'analyses',
          'docId': analysisId,
          'data': analysisData,
        }
      ]);

      // Step 3: Start AI analysis (mock for now)
      state = state.copyWith(status: AnalysisStatus.analyzing);
      await _performMockAnalysis(analysisId, imageUrl, userId, finalChildId);
    } catch (e) {
      _logger.e('Analysis error: $e');
      state = state.copyWith(
        status: AnalysisStatus.failed,
        errorMessage: 'Analiz sırasında bir hata oluştu: ${e.toString()}',
        isLoading: false,
        canCancel: false,
      );
    }
  }

  /// Perform mock AI analysis with realistic progress
  Future<void> _performMockAnalysis(
    String analysisId,
    String imageUrl,
    String userId,
    String childId,
  ) async {
    try {
      final steps = [
        (0.4, 'Görsel işleniyor...'),
        (0.5, 'AI analizi başlatılıyor...'),
        (0.6, 'Duygusal belirtiler analiz ediliyor...'),
        (0.7, 'Gelişimsel özellikler değerlendiriliyor...'),
        (0.8, 'Yaratıcılık faktörleri hesaplanıyor...'),
        (0.9, 'Öneriler oluşturuluyor...'),
        (0.95, 'Sonuçlar hazırlanıyor...'),
      ];

      for (final (progress, message) in steps) {
        if (state.status == AnalysisStatus.cancelled) return;

        await _updateProgress(progress, message);
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // Generate mock insights
      final insights = _generateMockInsights();

      // Create results
      final results = AnalysisResults(
        id: analysisId,
        childId: childId,
        userId: userId,
        imageUrl: imageUrl,
        insights: insights,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      // Update Firestore with results
      await _firestoreService.batchWrite([
        {
          'type': 'update',
          'collection': 'analyses',
          'docId': analysisId,
          'data': {
            'status': 'completed',
            'insights': insights.toMap(),
            'completedAt': DateTime.now().toIso8601String(),
          },
        }
      ]);

      await _updateProgress(1.0, 'Analiz tamamlandı!');

      // Set completed state
      state = state.copyWith(
        status: AnalysisStatus.completed,
        results: results,
        isLoading: false,
        canCancel: false,
      );

      _logger.i('Analysis completed: $analysisId');
    } catch (e) {
      _logger.e('Mock analysis error: $e');
      state = state.copyWith(
        status: AnalysisStatus.failed,
        errorMessage: 'Analiz tamamlanamadı: ${e.toString()}',
        isLoading: false,
        canCancel: false,
      );
    }
  }

  /// Generate mock AI insights
  AnalysisInsights _generateMockInsights() {
    final emotions = [
      'Çocuğunuz duygusal olarak dengeli bir profil sergiliyor',
      'Çizimde pozitif duygusal belirtiler gözlemlenmektedir',
      'Çocuk kendini güvende hissettiğini ifade ediyor',
      'Duygusal gelişim yaşına uygun seviyededir',
    ];

    final findings = [
      'Renk kullanımı yaratıcılığı gösteriyor',
      'Çizgi kalitesi motor beceri gelişimini yansıtıyor',
      'Kompozisyon dengeli ve organize',
      'Detaylara verilen önem dikkat gelişimini gösteriyor',
      'Figür çizimleri sosyal farkındalığı yansıtıyor',
    ];

    final recommendations = [
      'Yaratıcılık aktivitelerini destekleyin',
      'Sanat malzemeleriyle oynama fırsatları verin',
      'Çizimlerini sergilemeye devam edin',
      'Duygusal ifade becerilerini geliştiren oyunlar oynayın',
      'Hikaye anlatma aktiviteleri ile hayal gücünü besleyin',
    ];

    return AnalysisInsights(
      primaryInsight: emotions[DateTime.now().millisecond % emotions.length],
      emotionalScore: 7.5 + (DateTime.now().millisecond % 25) / 10,
      creativityScore: 8.0 + (DateTime.now().millisecond % 20) / 10,
      developmentScore: 7.8 + (DateTime.now().millisecond % 22) / 10,
      keyFindings: findings.take(4).toList(),
      detailedAnalysis: {
        'emotionalIndicators': [
          'Pozitif duygu durumu',
          'Güven hissi',
          'Yaratıcı ifade'
        ],
        'developmentLevel': 'Yaşına uygun gelişim',
        'socialAspects': ['Aile bağları güçlü', 'Sosyal farkındalık mevcut'],
        'creativityMarkers': [
          'Orijinal düşünce',
          'Detay odaklılık',
          'Renk duyarlılığı'
        ],
      },
      recommendations: recommendations.take(3).toList(),
      createdAt: DateTime.now(),
    );
  }

  /// Update progress with animation
  Future<void> _updateProgress(double progress, String message) async {
    state = state.copyWith(
      progress: AnalysisProgress(
        progress: progress,
        currentStep: message,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Cancel ongoing analysis
  Future<void> cancelAnalysis() async {
    if (!state.canCancel) return;

    try {
      _logger.i('Cancelling analysis: ${state.analysisId}');

      // Update Firestore
      if (state.analysisId != null) {
        await _firestoreService.batchWrite([
          {
            'type': 'update',
            'collection': 'analyses',
            'docId': state.analysisId!,
            'data': {
              'status': 'cancelled',
              'cancelledAt': DateTime.now().toIso8601String(),
            },
          }
        ]);
      }

      state = state.copyWith(
        status: AnalysisStatus.cancelled,
        isLoading: false,
        canCancel: false,
        errorMessage: null,
      );
    } catch (e) {
      _logger.e('Cancel analysis error: $e');
    }
  }

  /// Load existing analysis results
  Future<void> loadAnalysisResults(String analysisId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // TODO: Implement getAnalysis method in FirestoreService
      // For now, just set completed state
      state = state.copyWith(
        analysisId: analysisId,
        status: AnalysisStatus.completed,
        isLoading: false,
      );
    } catch (e) {
      _logger.e('Load results error: $e');
      state = state.copyWith(
        errorMessage: 'Sonuçlar yüklenemedi: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Generate PDF report (mock)
  Future<void> generatePDF() async {
    if (state.results == null) return;

    try {
      state = state.copyWith(isLoading: true);

      // Mock PDF generation delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement real PDF generation

      state = state.copyWith(isLoading: false);

      _logger.i('PDF generated for analysis: ${state.analysisId}');
    } catch (e) {
      _logger.e('PDF generation error: $e');
      state = state.copyWith(
        errorMessage: 'PDF oluşturulamadı: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Share analysis results (mock)
  Future<void> shareResults() async {
    if (state.results == null) return;

    try {
      // TODO: Implement real sharing functionality

      _logger.i('Results shared for analysis: ${state.analysisId}');
    } catch (e) {
      _logger.e('Share results error: $e');
    }
  }

  /// Reset analysis state
  void resetAnalysis() {
    _progressTimer?.cancel();
    _progressSubscription?.cancel();

    state = const AnalysisState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for AnalysisViewModel
final analysisViewModelProvider =
    StateNotifierProvider<AnalysisViewModel, AnalysisState>((ref) {
  return AnalysisViewModel(
    storageService: ref.watch(storageServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
    ref: ref,
  );
});
