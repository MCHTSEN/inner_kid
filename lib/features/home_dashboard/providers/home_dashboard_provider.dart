import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_kid/core/models/drawing_analysis.dart';
import 'package:inner_kid/features/home_dashboard/views/home_dashboard_page.dart';

// Mock data provider for dashboard
final homeDashboardProvider = FutureProvider<DashboardData>((ref) async {
  // Simulate API call delay
  await Future.delayed(const Duration(seconds: 1));

  return _getMockDashboardData();
});

DashboardData _getMockDashboardData() {
  final now = DateTime.now();

  // Mock recent analyses
  final analyses = [
    DrawingAnalysis(
      id: '1',
      childId: '1',
      imageUrl: 'https://via.placeholder.com/300x200/667EEA/FFFFFF?text=Çizim1',
      uploadDate: now.subtract(const Duration(days: 2)),
      testType: DrawingTestType.familyDrawing,
      status: AnalysisStatus.completed,
      aiResults: {
        'primaryInsight': 'Ahmet ailesiyle güçlü bağlara sahip görünüyor',
        'emotionalScore': 85,
        'creativityScore': 92,
        'developmentScore': 78,
        'keyFindings': [
          'Pozitif aile dinamikleri',
          'Yüksek yaratıcılık seviyesi',
          'Duygusal güvenlik',
        ],
      },
      recommendations: [
        'Aile aktivitelerine devam edin',
        'Yaratıcı oyunları destekleyin',
      ],
      createdAt: now.subtract(const Duration(days: 2)),
      completedAt: now.subtract(const Duration(days: 1)),
    ),
    DrawingAnalysis(
      id: '2',
      childId: '2',
      imageUrl: 'https://via.placeholder.com/300x200/38B2AC/FFFFFF?text=Çizim2',
      uploadDate: now.subtract(const Duration(days: 5)),
      testType: DrawingTestType.selfPortrait,
      status: AnalysisStatus.completed,
      aiResults: {
        'primaryInsight': 'Ayşe kendini mutlu ve özgüvenli hissediyor',
        'emotionalScore': 92,
        'creativityScore': 88,
        'developmentScore': 85,
      },
      recommendations: [
        'Özgüven geliştiren aktiviteler',
        'Sosyal etkileşimi artırın',
      ],
      createdAt: now.subtract(const Duration(days: 5)),
      completedAt: now.subtract(const Duration(days: 4)),
    ),
    DrawingAnalysis(
      id: '3',
      childId: '1',
      imageUrl: 'https://via.placeholder.com/300x200/ED8936/FFFFFF?text=Çizim3',
      uploadDate: now.subtract(const Duration(days: 7)),
      testType: DrawingTestType.houseTreePerson,
      status: AnalysisStatus.processing,
      createdAt: now.subtract(const Duration(days: 7)),
    ),
  ];

  return DashboardData(
    dailyInsight:
        'Çocuklarınız bu hafta yaratıcı çizimler yapıyor ve duygusal gelişimleri olumlu yönde ilerliyor.',
    recentAnalyses: analyses,
    dailyRecommendations: [
      'Çocuğunuzla birlikte resim yapma zamanı ayırın',
      'Çizimlerini sergilemeyi önerin, özgüvenini artırır',
      'Farklı renk ve materyallerle deneyim yapmalarını sağlayın',
      'Çizimlerini hikayeler ile desteklemelerini isteyin',
      'Yaratıcı oyunlar için zaman ayırın',
    ],
  );
}
