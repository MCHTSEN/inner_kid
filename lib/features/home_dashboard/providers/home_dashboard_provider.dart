import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_kid/core/di/providers.dart';
import 'package:inner_kid/core/models/drawing_analysis.dart';
import 'package:inner_kid/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:inner_kid/features/home_dashboard/views/home_dashboard_page.dart';

// Real dashboard provider that fetches from Firebase
final homeDashboardProvider = FutureProvider<DashboardData>((ref) async {
  final authState = ref.watch(authViewModelProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  if (!authState.isAuthenticated || authState.userProfile == null) {
    return _getMockDashboardData(); // Fallback to mock data
  }

  try {
    final userId = authState.firebaseUser!.uid;

    // Fetch real analyses from Firebase
    final analyses = await firestoreService.getUserAnalyses(userId);

    // If no real analyses, return mock data for demonstration
    if (analyses.isEmpty) {
      return _getMockDashboardData();
    }

    // Generate dynamic insights based on real data
    final dailyInsight = _generateDailyInsight(analyses);
    final recommendations = _generateRecommendations(analyses);

    return DashboardData(
      dailyInsight: dailyInsight,
      recentAnalyses: analyses, // Use real analyses
      dailyRecommendations: recommendations,
    );
  } catch (e) {
    // Log error and fallback to mock data
    debugPrint('❌ Error fetching dashboard data: $e');
    return _getMockDashboardData();
  }
});

String _generateDailyInsight(List<DrawingAnalysis> analyses) {
  if (analyses.isEmpty) {
    return 'Çocuğunuzun ilk çizimini analiz etmeye hazırız! Yaratıcılığını keşfetmek için bir çizim yükleyin.';
  }

  final completedAnalyses =
      analyses.where((a) => a.status == AnalysisStatus.completed).toList();
  if (completedAnalyses.isEmpty) {
    return 'Analizleriniz işleniyor. Sonuçlar hazır olduğunda size bildirim göndereceğiz.';
  }

  final avgEmotionalScore =
      completedAnalyses.map((a) => a.emotionalScore).reduce((a, b) => a + b) /
          completedAnalyses.length;
  final avgCreativityScore =
      completedAnalyses.map((a) => a.creativityScore).reduce((a, b) => a + b) /
          completedAnalyses.length;

  if (avgEmotionalScore > 80 && avgCreativityScore > 80) {
    return 'Harika! Çocuğunuz duygusal olarak dengeli ve son derece yaratıcı çizimler yapıyor. Bu hafta özellikle güçlü bir gelişim gösteriyor.';
  } else if (avgEmotionalScore > 70) {
    return 'Çocuğunuz duygusal olarak iyi durumda ve çizimlerinde pozitif belirtiler gösteriyor. Yaratıcılığını destekleyici aktivitelere odaklanabilirsiniz.';
  } else {
    return 'Çocuğunuzun çizimleri değerli ipuçları veriyor. Duygusal destek ve yaratıcı aktivitelerle gelişimini destekleyebilirsiniz.';
  }
}

List<String> _generateRecommendations(List<DrawingAnalysis> analyses) {
  if (analyses.isEmpty) {
    return [
      'İlk çizim analizini yapmak için çocuğunuzla birlikte resim yapın',
      'Farklı çizim türlerini deneyin: aile çizimi, kendini çizme, ev-ağaç-insan',
      'Çizim yaparken çocuğunuzla konuşun ve hikayeler oluşturun',
    ];
  }

  final recommendations = <String>[];
  final completedAnalyses =
      analyses.where((a) => a.status == AnalysisStatus.completed).toList();

  if (completedAnalyses.isNotEmpty) {
    final avgCreativity = completedAnalyses
            .map((a) => a.creativityScore)
            .reduce((a, b) => a + b) /
        completedAnalyses.length;
    final avgEmotional =
        completedAnalyses.map((a) => a.emotionalScore).reduce((a, b) => a + b) /
            completedAnalyses.length;

    if (avgCreativity < 70) {
      recommendations.addAll([
        'Yaratıcılığı desteklemek için farklı sanat malzemeleri deneyin',
        'Müzik eşliğinde serbest çizim yapmasını teşvik edin',
        'Doğa gözlemi yaparak çizim ilhamı almasını sağlayın',
      ]);
    }

    if (avgEmotional < 70) {
      recommendations.addAll([
        'Çocuğunuzla duygular hakkında konuşmaya zaman ayırın',
        'Çizimlerindeki karakterlerin hislerini sorgulamasını teşvik edin',
        'Rahatlatıcı aktiviteler ve oyunlar planlayın',
      ]);
    }

    if (avgCreativity > 80) {
      recommendations.add(
          'Harika yaratıcılık! Sanat kursları veya atölyeler düşünebilirsiniz');
    }
  }

  // Her zaman genel öneriler ekle
  recommendations.addAll([
    'Çizimlerini sergilemeyi sürdürün, özgüvenini artırır',
    'Haftalık çizim rutini oluşturun',
    'Çizimlerini hikayelerle desteklemesini isteyin',
  ]);

  return recommendations.take(5).toList();
}

DashboardData _getEnhancedMockDashboardData() {
  final now = DateTime.now();

  // Enhanced mock analyses with more detail
  final analyses = [
    DrawingAnalysis(
      id: '1',
      childId: '1',
      imageUrl: 'mock_image_1',
      uploadDate: now.subtract(const Duration(days: 1)),
      testType: DrawingTestType.familyDrawing,
      status: AnalysisStatus.completed,
      aiResults: {
        'primaryInsight':
            'Ahmet ailesiyle güçlü bağlara sahip görünüyor ve kendini güvende hissediyor',
        'emotionalScore': 88,
        'creativityScore': 92,
        'developmentScore': 85,
        'keyFindings': [
          'Aile üyeleri arasında pozitif bağlantı',
          'Renk kullanımında duygusal denge',
          'Figürlerin boyutları sağlıklı aile dinamiklerini gösteriyor',
          'Detaylara verilen önem dikkat gelişimini yansıtıyor',
          'Kompozisyon dengeli ve organize'
        ],
        'detailedAnalysis': {
          'emotionalIndicators': [
            'Pozitif duygu durumu - figürlerin yüz ifadeleri gülümsüyor',
            'Güven hissi - aile üyeleri birbirine yakın çizilmiş',
            'Bağlılık - el ele tutuşan figürler',
            'Mutluluk - parlak ve canlı renkler kullanılmış'
          ],
          'developmentLevel':
              'Yaşına uygun gelişim, hatta bazı alanlarda üstünde',
          'socialAspects': [
            'Aile bağları güçlü',
            'Sosyal farkındalık mevcut',
            'Empati becerileri gelişmiş',
            'İletişim becerilerine odaklı'
          ],
          'creativityMarkers': [
            'Orijinal düşünce - benzersiz detaylar eklemiş',
            'Detay odaklılık - arka plan elemanları zengin',
            'Renk duyarlılığı - uyumlu renk paleti',
            'Kompozisyon becerisi - dengeli yerleştirme'
          ],
          'psychologicalInsights': [
            'Güvenli bağlanma stiline sahip',
            'Aile içi rolleri net şekilde algılıyor',
            'Kendini aile sisteminin değerli bir parçası olarak görüyor',
            'Duygusal düzenleme becerileri yaşına uygun'
          ]
        },
      },
      recommendations: [
        'Aile aktivitelerine devam edin, çocuğunuz bu bağlantıdan güç alıyor',
        'Yaratıcı oyunları destekleyin, hayal gücü çok gelişmiş',
        'Çizimlerini evde sergilemeye devam edin',
        'Hikaye anlatma aktiviteleri ile yaratıcılığını besleyin',
        'Aile fotoğrafları çekerek anıları güçlendirin'
      ],
      createdAt: now.subtract(const Duration(days: 1)),
      completedAt: now.subtract(const Duration(hours: 2)),
    ),
    DrawingAnalysis(
      id: '2',
      childId: '1',
      imageUrl: 'mock_image_2',
      uploadDate: now.subtract(const Duration(days: 3)),
      testType: DrawingTestType.selfPortrait,
      status: AnalysisStatus.completed,
      aiResults: {
        'primaryInsight':
            'Çocuk kendini pozitif ve özgüvenli şekilde ifade ediyor, benlik algısı sağlıklı',
        'emotionalScore': 91,
        'creativityScore': 87,
        'developmentScore': 89,
        'keyFindings': [
          'Güçlü benlik algısı ve özgüven',
          'Detaylı yüz ifadesi - kendini tanıma becerileri',
          'Vücut oranları yaşına uygun gelişim gösteriyor',
          'Renk seçimleri pozitif duygu durumunu yansıtıyor',
          'Çizim kalitesi motor becerilerin iyi gelişimini gösteriyor'
        ],
        'detailedAnalysis': {
          'emotionalIndicators': [
            'Yüksek öz saygı - kendini büyük ve merkezi çizmiş',
            'Pozitif benlik algısı - gülümseyen yüz ifadesi',
            'Duygusal güvenlik - rahat ve doğal duruş',
            'İyimserlik - parlak renkler ve neşeli atmosfer'
          ],
          'developmentLevel':
              'Yaşının üzerinde gelişim gösteren alanlar mevcut',
          'socialAspects': [
            'Sosyal etkileşime açık',
            'Kendini ifade etme becerileri güçlü',
            'Çevresiyle uyumlu ilişkiler kurabiliyor'
          ],
          'creativityMarkers': [
            'Özgün stil geliştirmeye başlamış',
            'Detay zenginliği dikkat çekici',
            'Renk kombinasyonları yaratıcı',
            'Perspektif kullanımı gelişiyor'
          ]
        },
      },
      recommendations: [
        'Özgüven geliştiren aktivitelere devam edin',
        'Sanat ve yaratıcılık odaklı hobiler destekleyin',
        'Kendini ifade etme fırsatları yaratın',
        'Başarılarını kutlayın ve teşvik edin'
      ],
      createdAt: now.subtract(const Duration(days: 3)),
      completedAt: now.subtract(const Duration(days: 2)),
    ),
    DrawingAnalysis(
      id: '3',
      childId: '1',
      imageUrl: 'mock_image_3',
      uploadDate: now.subtract(const Duration(days: 5)),
      testType: DrawingTestType.houseTreePerson,
      status: AnalysisStatus.completed,
      aiResults: {
        'primaryInsight':
            'Çevre algısı ve güvenlik hissi güçlü, yaşam alanını pozitif şekilde değerlendiriyor',
        'emotionalScore': 84,
        'creativityScore': 90,
        'developmentScore': 87,
        'keyFindings': [
          'Güvenli yaşam alanı algısı',
          'Doğayla bağlantı kurma isteği',
          'Detaylı ve organize çizim yaklaşımı',
          'Sembolik düşünme becerileri gelişmiş',
          'Çevresel farkındalık yüksek'
        ],
        'detailedAnalysis': {
          'emotionalIndicators': [
            'Güvenlik hissi - sağlam ev temeli çizilmiş',
            'Huzur - ağaç ve doğa elemanları bol',
            'Kararlılık - net çizgiler ve form',
            'Umut - yeşil ve mavi tonlar baskın'
          ],
          'developmentLevel': 'Mekânsal zeka ve planlama becerileri gelişmiş',
          'socialAspects': [
            'Çevre bilinci yüksek',
            'Yaşam alanına karşı pozitif tutum',
            'Gelecek planlaması yapabiliyor'
          ],
          'creativityMarkers': [
            'Sembolik düşünme - her eleman anlamlı',
            'Kompozisyon becerisi üst düzey',
            'Detay odaklılık - arka plan zengin',
            'Renk harmonisi gelişmiş'
          ]
        },
      },
      recommendations: [
        'Doğa aktivitelerine katılımını artırın',
        'Çevre bilinci geliştiren projeler yapın',
        'Mekânsal zeka oyunları oynayın',
        'Bahçıvanlık gibi pratik aktiviteler deneyin'
      ],
      createdAt: now.subtract(const Duration(days: 5)),
      completedAt: now.subtract(const Duration(days: 4)),
    ),
    DrawingAnalysis(
      id: '4',
      childId: '1',
      imageUrl: 'mock_image_4',
      uploadDate: now.subtract(const Duration(days: 7)),
      testType: DrawingTestType.narrativeDrawing,
      status: AnalysisStatus.completed,
      aiResults: {
        'primaryInsight':
            'Hikaye anlatma becerisi ve hayal gücü çok gelişmiş, karmaşık duygusal durumları anlayabiliyor',
        'emotionalScore': 89,
        'creativityScore': 95,
        'developmentScore': 91,
        'keyFindings': [
          'Üstün hayal gücü ve yaratıcılık',
          'Karmaşık hikaye yapıları kurabilme',
          'Duygusal derinlik ve empati',
          'Detaylı karakter geliştirme',
          'Sebep-sonuç ilişkilerini anlama'
        ],
      },
      recommendations: [
        'Hikaye yazma aktivitelerini teşvik edin',
        'Tiyatro ve drama çalışmaları yapın',
        'Yaratıcı yazım atölyeleri düşünün',
        'Kitap okuma alışkanlığını destekleyin'
      ],
      createdAt: now.subtract(const Duration(days: 7)),
      completedAt: now.subtract(const Duration(days: 6)),
    ),
    DrawingAnalysis(
      id: '5',
      childId: '1',
      imageUrl: 'mock_image_5',
      uploadDate: now.subtract(const Duration(days: 10)),
      testType: DrawingTestType.emotionalStates,
      status: AnalysisStatus.processing,
      createdAt: now.subtract(const Duration(days: 10)),
    ),
  ];

  return DashboardData(
    dailyInsight: _generateDailyInsight(analyses),
    recentAnalyses: analyses,
    dailyRecommendations: _generateRecommendations(analyses),
  );
}

// Keep the original mock data as fallback
DashboardData _getMockDashboardData() {
  return _getEnhancedMockDashboardData();
}
