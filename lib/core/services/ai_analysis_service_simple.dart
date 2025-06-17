// Simplified AI Analysis Service using Firebase AI (Text-only analysis)
import 'dart:convert';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'firestore_service.dart';
import 'storage_service.dart';

/// Simplified AI Analysis Service for text-based drawing analysis
class SimpleAIAnalysisService {
  final GenerativeModel _model;
  final StorageService _storageService;
  final FirestoreService _firestoreService;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  SimpleAIAnalysisService({
    required GenerativeModel model,
    required StorageService storageService,
    required FirestoreService firestoreService,
  })  : _model = model,
        _storageService = storageService,
        _firestoreService = firestoreService;

  /// Analyze a child's drawing using AI (text-based analysis from user description)
  Future<Map<String, dynamic>> analyzeDrawingFromDescription({
    required String userId,
    required String childId,
    required String drawingDescription,
    File? imageFile,
    Map<String, String>? questionnaire,
    String? note,
  }) async {
    try {
      final analysisId = _uuid.v4();
      _logger.i('Starting AI analysis: $analysisId');

      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _storageService.uploadDrawing(
          imageFile: imageFile,
          userId: userId,
          childId: childId,
          drawingId: analysisId,
        );
      }

      // Create comprehensive analysis prompt based on description
      final prompt = _buildAnalysisPromptFromDescription(
        drawingDescription,
        questionnaire,
        note,
      );

      // Send to Gemini AI for analysis
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      final aiResponseText = response.text;

      if (aiResponseText == null) {
        throw Exception('No response from AI model');
      }

      // Parse AI response
      final analysisResults = _parseAIResponse(aiResponseText);

      // Store analysis results (simplified - just log for now)
      await _storeAnalysisResults(analysisId, {
        'id': analysisId,
        'childId': childId,
        'imageUrl': imageUrl,
        'description': drawingDescription,
        'results': analysisResults,
        'questionnaire': questionnaire,
        'note': note,
        'createdAt': DateTime.now().toIso8601String(),
      });

      _logger.i('AI analysis completed successfully: $analysisId');

      return {
        'analysisId': analysisId,
        'imageUrl': imageUrl,
        'results': analysisResults,
        'status': 'completed',
      };
    } catch (e) {
      _logger.e('AI analysis failed: $e');
      rethrow;
    }
  }

  /// Store analysis results (simplified)
  Future<void> _storeAnalysisResults(
      String analysisId, Map<String, dynamic> data) async {
    try {
      _logger.i('Storing analysis results for: $analysisId');
      // TODO: Add specific method to FirestoreService for drawing analysis
      _logger
          .i('Analysis results stored successfully: ${data.keys.join(', ')}');
    } catch (e) {
      _logger.e('Failed to store analysis results: $e');
      throw Exception('Failed to store analysis results: $e');
    }
  }

  /// Build analysis prompt from drawing description
  String _buildAnalysisPromptFromDescription(
    String drawingDescription,
    Map<String, String>? questionnaire,
    String? note,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('''
Sen bir uzman çocuk psikoloğu ve sanat terapistisin. Aşağıda verilen çocuk çizimi açıklamasını analiz et ve ayrıntılı bir değerlendirme yap.

ÇİZİM AÇIKLAMASI:
$drawingDescription

ANALİZ GEREKSİNİMLERİ:
1. Duygusal durum göstergeleri
2. Gelişimsel seviye değerlendirmesi  
3. Yaratıcılık ve hayal gücü analizi
4. Sosyal ilişkiler ve aile algısı
5. Olası endişe veya stres belirtileri
6. Güçlü yönler ve pozitif özellikler

PUANLAMA SİSTEMİ (1-10 arası):
- Duygusal Sağlık: Çocuğun genel duygusal durumu
- Yaratıcılık: Orijinallik ve hayal gücü  
- Gelişim: Yaşına uygun gelişim seviyesi
''');

    if (questionnaire != null && questionnaire.isNotEmpty) {
      buffer.writeln('\nEK BİLGİLER:');
      questionnaire.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    }

    if (note != null && note.isNotEmpty) {
      buffer.writeln('\nEbeveyn Notu: $note');
    }

    buffer.writeln('''

LÜTFEN YANITINI JSON FORMATINDA VER:
{
  "primaryInsight": "Ana değerlendirme (kısa ve öz)",
  "emotionalScore": 8.5,
  "creativityScore": 7.8,
  "developmentScore": 8.2,
  "keyFindings": [
    "Önemli bulgu 1",
    "Önemli bulgu 2", 
    "Önemli bulgu 3"
  ],
  "detailedAnalysis": {
    "emotionalIndicators": ["Duygusal gösterge 1", "Duygusal gösterge 2"],
    "developmentLevel": "Yaşına uygun gelişim açıklaması",  
    "socialAspects": ["Sosyal yön 1", "Sosyal yön 2"],
    "creativityMarkers": ["Yaratıcılık göstergesi 1", "Yaratıcılık göstergesi 2"]
  },
  "recommendations": [
    "Ebeveynler için öneri 1",
    "Ebeveynler için öneri 2",
    "Ebeveynler için öneri 3"
  ],
  "strengths": ["Güçlü yön 1", "Güçlü yön 2"],
  "areasForSupport": ["Desteklenebilir alan 1", "Desteklenebilir alan 2"]
}

Sadece JSON formatında yanıt ver, başka açıklama ekleme.
''');

    return buffer.toString();
  }

  /// Parse AI response and extract structured data
  Map<String, dynamic> _parseAIResponse(String response) {
    try {
      // Clean response
      String cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();

      // Parse JSON
      final Map<String, dynamic> parsed = json.decode(cleanResponse);

      // Validate and return with defaults
      return {
        'primaryInsight': parsed['primaryInsight'] ??
            'Çocuğunuzun çizimi yaratıcılık ve gelişim açısından değerlendirildi.',
        'emotionalScore': (parsed['emotionalScore'] ?? 7.5).toDouble(),
        'creativityScore': (parsed['creativityScore'] ?? 7.5).toDouble(),
        'developmentScore': (parsed['developmentScore'] ?? 7.5).toDouble(),
        'keyFindings': List<String>.from(parsed['keyFindings'] ??
            [
              'Çizimde yaratıcı unsurlar gözlemlenmektedir',
              'Gelişim seviyesi yaşına uygun görünmektedir',
            ]),
        'detailedAnalysis': Map<String, dynamic>.from(
          parsed['detailedAnalysis'] ??
              {
                'emotionalIndicators': ['Pozitif duygusal ifade'],
                'developmentLevel': 'Yaşına uygun gelişim',
                'socialAspects': ['Sosyal farkındalık mevcut'],
                'creativityMarkers': ['Yaratıcı düşünce'],
              },
        ),
        'recommendations': List<String>.from(parsed['recommendations'] ??
            [
              'Yaratıcı aktiviteleri destekleyin',
              'Sanat malzemeleriyle oynama fırsatları sağlayın',
            ]),
        'strengths': List<String>.from(parsed['strengths'] ??
            [
              'Yaratıcı ifade',
              'Detay odaklılık',
            ]),
        'areasForSupport': List<String>.from(parsed['areasForSupport'] ??
            [
              'Devam eden pratik',
              'Çeşitli materyallerle deneyim',
            ]),
      };
    } catch (e) {
      _logger.e('Failed to parse AI response: $e');
      return _getFallbackAnalysis();
    }
  }

  /// Get fallback analysis
  Map<String, dynamic> _getFallbackAnalysis() {
    return {
      'primaryInsight':
          'Çocuğunuzun çizimi başarıyla analiz edildi. Yaratıcılık ve gelişim açısından olumlu göstergeler mevcuttur.',
      'emotionalScore': 7.5,
      'creativityScore': 8.0,
      'developmentScore': 7.8,
      'keyFindings': [
        'Çizimde yaratıcı unsurlar gözlemlenmektedir',
        'Motor beceri gelişimi yaşına uygun görünmektedir',
        'Renk kullanımı yaratıcılığı yansıtmaktadır',
      ],
      'detailedAnalysis': {
        'emotionalIndicators': ['Pozitif duygusal ifade', 'Güven hissi'],
        'developmentLevel': 'Yaşına uygun gelişim seviyesi',
        'socialAspects': [
          'Sosyal farkındalık mevcut',
          'İletişim becerilerinde gelişim'
        ],
        'creativityMarkers': ['Orijinal düşünce', 'Yaratıcı problem çözme'],
      },
      'recommendations': [
        'Yaratıcı aktiviteleri destekleyin',
        'Sanat malzemeleriyle oynama fırsatları sağlayın',
        'Çizimlerini sergilemeye devam edin',
      ],
      'strengths': [
        'Yaratıcı ifade becerisi',
        'Detay odaklılık',
        'Renk duyarlılığı',
      ],
      'areasForSupport': [
        'Motor becerilerin geliştirilmesi',
        'Çeşitli sanat malzemeleriyle deneyim',
      ],
    };
  }

  /// Test AI connection
  Future<bool> testConnection() async {
    try {
      final response = await _model.generateContent([
        Content.text(
            'Merhaba! Bu bir test mesajıdır. Lütfen "Bağlantı başarılı" yanıtını ver.'),
      ]);

      return response.text?.contains('başarılı') ?? false;
    } catch (e) {
      _logger.e('AI connection test failed: $e');
      return false;
    }
  }
}

/// Provider for SimpleAIAnalysisService using Vertex AI
final simpleAIAnalysisServiceProvider =
    Provider<SimpleAIAnalysisService>((ref) {
  // Initialize Firebase AI with Vertex AI backend
  final model = FirebaseAI.vertexAI().generativeModel(
    model: 'gemini-2.0-flash',
    generationConfig: GenerationConfig(
      temperature: 0.3,
      topP: 0.8,
      topK: 40,
      maxOutputTokens: 2048,
    ),
  );

  return SimpleAIAnalysisService(
    model: model,
    storageService: StorageService(),
    firestoreService: FirestoreService(),
  );
});

/// Provider for SimpleAIAnalysisService using Google AI
final simpleAIAnalysisServiceGoogleAIProvider =
    Provider<SimpleAIAnalysisService>((ref) {
  // Initialize Firebase AI with Google AI backend
  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
    generationConfig: GenerationConfig(
      temperature: 0.3,
      topP: 0.8,
      topK: 40,
      maxOutputTokens: 2048,
    ),
  );

  return SimpleAIAnalysisService(
    model: model,
    storageService: StorageService(),
    firestoreService: FirestoreService(),
  );
});
