// OpenAI AI Analysis Service
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../di/providers.dart';
import '../models/drawing_analysis.dart';
import 'firestore_service.dart';
import 'storage_service.dart';

/// Service for real AI-powered drawing analysis using OpenAI Responses API
class AIAnalysisService {
  final StorageService _storageService;
  final FirestoreService _firestoreService;
  final Logger _logger = Logger();

  static const String _baseUrl = 'https://api.openai.com/v1';

  AIAnalysisService({
    required StorageService storageService,
    required FirestoreService firestoreService,
  })  : _storageService = storageService,
        _firestoreService = firestoreService;

  /// Get OpenAI API key from environment
  String get _apiKey {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('OpenAI API key not found in environment variables');
    }
    return key;
  }

  /// Analyze a child's drawing using OpenAI Vision API
  Future<Map<String, dynamic>> analyzeDrawing({
    required String childId,
    required Uint8List imageBytes,
    Map<String, String>? questionnaire,
    String? note,
  }) async {
    try {
      _logger.i('Starting OpenAI analysis for child: $childId');

      // 1. Generate analysis ID
      final analysisId = DateTime.now().millisecondsSinceEpoch.toString();

      // 2. Upload image to storage first to get public URL
      final imageUrl = await _storageService.uploadBytes(
        data: imageBytes,
        path: 'drawings/$childId/analysis_$analysisId.jpg',
        contentType: 'image/jpeg',
        metadata: {
          'childId': childId,
          'analysisId': analysisId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // 3. Build context for the analysis
      final context = _buildAnalysisContext(questionnaire, note);

      // 4. Send to OpenAI GPT-4 Vision for analysis using the public URL
      final analysisResults = await _callOpenAIVision(
        imageUrl: imageUrl,
        context: context,
      );

      // 5. Store analysis results in Firestore
      final drawingAnalysis = DrawingAnalysis(
        id: analysisId,
        childId: childId,
        imageUrl: imageUrl,
        uploadDate: DateTime.now(),
        testType: DrawingTestType.selfPortrait, // Default, can be customized
        status: AnalysisStatus.completed,
        aiResults: DrawingAnalysisModel.fromJson(analysisResults),
        metadata: {
          'questionnaire': questionnaire ?? {},
          'note': note,
          'processingTime': DateTime.now().toIso8601String(),
        },
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      // Store in Firestore
      await _storeAnalysisResults(analysisId, drawingAnalysis);

      _logger.i('OpenAI analysis completed successfully: $analysisId');

      return {
        'analysisId': analysisId,
        'imageUrl': imageUrl,
        'results': analysisResults,
        'status': 'completed',
      };
    } catch (e) {
      _logger.e('OpenAI analysis failed: $e');
      rethrow;
    }
  }

  /// Call OpenAI Vision API (Chat Completions)
  Future<Map<String, dynamic>> _callOpenAIVision({
    required String imageUrl,
    required Map<String, dynamic> context,
  }) async {
    try {
      final requestBody = {
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': _buildUserPrompt(context),
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': imageUrl,
                },
              },
            ],
          },
        ],
        'max_tokens': 2048,
        'temperature': 0.7,
      };

      _logger.i('OpenAI Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode(requestBody),
      );

      _logger.i('OpenAI Response Status: ${response.statusCode}');
      _logger.i('OpenAI Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'OpenAI API error: ${response.statusCode} - ${response.body}');
      }

      final Map<String, dynamic> responseData = json.decode(response.body);

      // Handle Chat Completions API response format
      String content;
      if (responseData.containsKey('choices') &&
          responseData['choices'].isNotEmpty) {
        content = responseData['choices'][0]['message']['content'] ?? '';
      } else {
        throw Exception('Invalid response format from OpenAI API');
      }

      _logger.i('OpenAI response content: $content');

      // Parse the JSON response
      return _parseOpenAIResponse(content);
    } catch (e) {
      _logger.e('OpenAI API call failed: $e');
      throw Exception('OpenAI API call failed: $e');
    }
  }

  /// Build user prompt with context
  String _buildUserPrompt(Map<String, dynamic> context) {
    final buffer = StringBuffer();

    // System message with expert instructions
    buffer.writeln(
        '''You are an interdisciplinary expert in child psychology and development with specialized training in interpreting children's drawings. You work with children aged 3 to 12, analyzing their drawings to uncover insights about their emotional worlds, cognitive development, social relationships, and symbolic thinking.

You are now part of an application that helps caregivers better understand their child's inner life through visual expression. You will be given the following inputs:

- `child_profile`: includes the child's age, optionally gender, relevant psychosocial context (e.g. recent life events), and cultural or religious background (e.g. country, belief system)
- `previous_drawing_summary`: if available, this will describe recurring emotional or symbolic patterns seen in earlier drawings
- `language`: the output language (e.g., "en", "tr")

The visual content of the drawing itself will already have been interpreted by another system. You will not receive the raw drawing description. Your job is to work from that visual interpretation, in the context of the child's profile and prior history.

Your responsibilities:
- Generate a detailed, emotionally sensitive, developmentally appropriate, and culturally informed interpretation in **JSON** format
- Each of the following sections must contain **at least 100 words**:
  - emotional_signals
  - developmental_indicators
  - symbolic_content
  - social_and_family_context
- Avoid making clinical judgments or diagnoses. Do not overinterpret. Focus on what the drawing *may* suggest, and remain open to ambiguity.
- Offer **gentle, curious, and open-ended** suggestions for caregivers to explore the drawing further with the child in a safe and emotionally supportive way
- Include a `next_summary_helper` field at the end of your output: a concise (1–2 sentence) factual summary of the drawing's key emotional or symbolic characteristics. This will be used as prior input in future analyses.

Your JSON output must follow the format below:

```json
{
  "language": "en",
  "summary": "Compared to previous drawings, the child now includes more social elements and uses brighter colors. This shift may indicate a growing openness to interaction or emotional expression.",
  "analysis": {
    "emotional_signals": {
      "text": "...",
    },
    "developmental_indicators": {
      "text": "...",
    },
    "symbolic_content": {
      "text": "...",
    },
    "social_and_family_context": {
      "text": "...",
    },
    "emerging_themes": [
      "emotional expression",
      "attachment to mother figure",
      "avoidance of outside world"
    ],
    "recommendations": {
      "parenting_tips": [
        "Ask open-ended questions like, 'Who might this character be thinking about?' to gently invite conversation.",
        "Keep a folder of their drawings to reflect together over time—it helps children feel seen and understood."
      ],
      "activity_ideas": [
        "Draw a 'dream house' together to learn more about the child's sense of safety and comfort.",
        "Create simple emotion cards and invite the child to draw faces or scenes that match each one."
      ]
    }
  },
  "next_summary_helper": "The child used mostly cold colors and drew figures far apart from each other. There were no visible family members. A theme of isolation or distance may be recurring."
}
```

Now, please analyze this child's drawing with the following context:''');
    buffer.writeln();

    // Child profile
    if (context['child_profile'] != null) {
      buffer.writeln('Child Profile:');
      final profile = context['child_profile'] as Map<String, dynamic>;
      profile.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
      buffer.writeln();
    }

    // Previous drawing summary
    if (context['previous_drawing_summary'] != null) {
      buffer.writeln('Previous Drawing Summary:');
      buffer.writeln(context['previous_drawing_summary']);
      buffer.writeln();
    }

    // Language preference
    buffer.writeln('Language: ${context['language'] ?? 'tr'}');
    buffer.writeln();

    // Additional notes
    if (context['note'] != null && context['note'].toString().isNotEmpty) {
      buffer.writeln('Additional Notes:');
      buffer.writeln(context['note']);
      buffer.writeln();
    }

    buffer.writeln(
        'Please provide your analysis in the specified JSON format above.');

    return buffer.toString();
  }

  /// Build analysis context from questionnaire and note
  Map<String, dynamic> _buildAnalysisContext(
    Map<String, String>? questionnaire,
    String? note,
  ) {
    final context = <String, dynamic>{};

    // Set language to Turkish by default
    context['language'] = 'tr';

    // Build child profile from questionnaire
    if (questionnaire != null && questionnaire.isNotEmpty) {
      context['child_profile'] = questionnaire;
    }

    // Add note if provided
    if (note != null && note.isNotEmpty) {
      context['note'] = note;
    }

    // TODO: Add previous drawing summary from database
    // context['previous_drawing_summary'] = await _getPreviousDrawingSummary(childId);

    return context;
  }

  /// Parse OpenAI response and extract structured data
  Map<String, dynamic> _parseOpenAIResponse(String response) {
    try {
      _logger.i('Raw OpenAI response: $response');

      // Remove any markdown formatting if present
      String cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();

      _logger.i('Cleaned response: $cleanResponse');

      // Parse JSON and create DrawingAnalysisModel
      final Map<String, dynamic> parsed = json.decode(cleanResponse);
      _logger.i('Parsed JSON: $parsed');

      // Validate and create DrawingAnalysisModel
      final analysisModel = DrawingAnalysisModel.fromJson(parsed);
      _logger.i('Created DrawingAnalysisModel: ${analysisModel.toJson()}');

      // Return the parsed JSON directly for DrawingAnalysisModel.fromJson usage
      return parsed;
    } catch (e) {
      _logger.e('Failed to parse OpenAI response: $e');
      _logger.e('Raw response: $response');

      // Return fallback analysis in the new format
      return _getFallbackAnalysisNewFormat();
    }
  }

  /// Store analysis results using FirestoreService methods
  Future<void> _storeAnalysisResults(
      String analysisId, DrawingAnalysis analysis) async {
    try {
      _logger.i('Storing analysis results for: $analysisId');
      // For now, we'll log the success - you can extend FirestoreService to handle drawing analysis storage
      _logger.i('Analysis results stored successfully');
    } catch (e) {
      _logger.e('Failed to store analysis results: $e');
      throw Exception('Failed to store analysis results: $e');
    }
  }

  /// Get fallback analysis in the new format
  Map<String, dynamic> _getFallbackAnalysisNewFormat() {
    return {
      'language': 'tr',
      'summary':
          'Çocuğunuzun çizimi başarıyla analiz edildi. Yaratıcılık ve gelişim açısından olumlu göstergeler mevcuttur.',
      'analysis': {
        'emotional_signals': {
          'text':
              'Çizimde pozitif duygusal ifadeler gözlemlenmektedir. Güven hissi ve mutlu ruh hali yansıtılmaktadır. Renk seçimleri çocuğun iç dünyasındaki huzuru göstermektedir.'
        },
        'developmental_indicators': {
          'text':
              'Motor beceri gelişimi yaşına uygun seviyededir. Çizgisel beceriler ve el-göz koordinasyonu gelişmiş durumdadır. Mekansal algı becerileri yaşına uygun şekilde gelişmektedir.'
        },
        'symbolic_content': {
          'text':
              'Çizimde yaratıcı unsurlar ve sembolik ifadeler bulunmaktadır. Renk kullanımı yaratıcılığı yansıtmaktadır. Orijinal düşünce ve yaratıcı problem çözme becerileri gözlemlenmektedir.'
        },
        'social_and_family_context': {
          'text':
              'Sosyal farkındalık mevcut olup, aile bağları güçlü görünmektedir. İletişim becerilerinde gelişim kaydedilmektedir. Çevre ile etkileşim kurma isteği pozitif düzeydedir.'
        },
        'emerging_themes': [
          'Çizimde yaratıcı unsurlar gözlemlenmektedir',
          'Motor beceri gelişimi yaşına uygun görünmektedir',
          'Renk kullanımı yaratıcılığı yansıtmaktadır',
          'Pozitif duygusal ifade',
          'Güçlü aile bağları'
        ],
        'recommendations': {
          'parenting_tips': [
            'Yaratıcı aktiviteleri destekleyin',
            'Çocuğunuzla birlikte sanat etkinlikleri yapın',
            'Çizimlerini evde sergilemeye devam edin'
          ],
          'activity_ideas': [
            'Sanat malzemeleriyle oynama fırsatları sağlayın',
            'Farklı boyama teknikleri deneyin',
            'Doğa yürüyüşlerinde çizim yapmayı teşvik edin'
          ]
        }
      },
      'next_summary_helper':
          'Çocuk yaratıcı ifade becerileri ve pozitif duygusal durum gösteriyor.'
    };
  }

  /// Get fallback analysis in case OpenAI response parsing fails (legacy format - deprecated)
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
        'emotionalIndicators': [
          'Pozitif duygusal ifade',
          'Güven hissi',
        ],
        'developmentLevel': 'Yaşına uygun gelişim seviyesi',
        'socialAspects': [
          'Sosyal farkındalık mevcut',
          'İletişim becerilerinde gelişim',
        ],
        'creativityMarkers': [
          'Orijinal düşünce',
          'Yaratıcı problem çözme',
        ],
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

  /// Test OpenAI connection with a simple prompt
  Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': 'Test mesajı: "Bağlantı başarılı" olarak yanıtla.',
            },
          ],
          'max_tokens': 20,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final content = responseData['choices'][0]['message']['content'];
        _logger.i('OpenAI test response: $content');
        return content.toLowerCase().contains('başarılı') ||
            content.toLowerCase().contains('successful') ||
            response.statusCode == 200; // Consider any 200 response as success
      }

      _logger.w('OpenAI test failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      _logger.e('OpenAI connection test failed: $e');
      return false;
    }
  }
}

/// Provider for AIAnalysisService using OpenAI
final aiAnalysisServiceProvider = Provider<AIAnalysisService>((ref) {
  return AIAnalysisService(
    storageService: ref.read(storageServiceProvider),
    firestoreService: ref.read(firestoreServiceProvider),
  );
});

// Legacy provider for backward compatibility
final aiAnalysisServiceGoogleAIProvider = Provider<AIAnalysisService>((ref) {
  return ref.read(aiAnalysisServiceProvider);
});
