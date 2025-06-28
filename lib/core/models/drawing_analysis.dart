enum DrawingTestType {
  selfPortrait('self_portrait', 'Kendini Çizme'),
  familyDrawing('family_drawing', 'Aile Çizimi'),
  houseTreePerson('house_tree_person', 'Ev-Ağaç-İnsan'),
  narrativeDrawing('narrative_drawing', 'Hikaye Çizimi'),
  emotionalStates('emotional_states', 'Duygusal Durumlar');

  const DrawingTestType(this.id, this.displayName);
  final String id;
  final String displayName;
}

enum AnalysisStatus {
  pending('pending', 'Bekliyor'),
  processing('processing', 'İşleniyor'),
  completed('completed', 'Tamamlandı'),
  failed('failed', 'Başarısız');

  const AnalysisStatus(this.id, this.displayName);
  final String id;
  final String displayName;
}

class DrawingAnalysisModel {
  final String language;
  final String summary;
  final Analysis analysis;
  final String nextSummaryHelper;

  DrawingAnalysisModel({
    required this.language,
    required this.summary,
    required this.analysis,
    required this.nextSummaryHelper,
  });

  factory DrawingAnalysisModel.fromJson(Map<String, dynamic> json) {
    return DrawingAnalysisModel(
      language: json['language'] as String,
      summary: json['summary'] as String,
      analysis: Analysis.fromJson(json['analysis'] as Map<String, dynamic>),
      nextSummaryHelper: json['next_summary_helper'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'summary': summary,
      'analysis': analysis.toJson(),
      'next_summary_helper': nextSummaryHelper,
    };
  }
}

class Analysis {
  final String emotionalSignals;
  final String developmentalIndicators;
  final String symbolicContent;
  final String socialAndFamilyContext;
  final List<String> emergingThemes;
  final Recommendations recommendations;

  Analysis({
    required this.emotionalSignals,
    required this.developmentalIndicators,
    required this.symbolicContent,
    required this.socialAndFamilyContext,
    required this.emergingThemes,
    required this.recommendations,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      emotionalSignals: json['emotional_signals']['text'] as String,
      developmentalIndicators:
          json['developmental_indicators']['text'] as String,
      symbolicContent: json['symbolic_content']['text'] as String,
      socialAndFamilyContext:
          json['social_and_family_context']['text'] as String,
      emergingThemes: List<String>.from(json['emerging_themes'] ?? []),
      recommendations: Recommendations.fromJson(json['recommendations']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotional_signals': {'text': emotionalSignals},
      'developmental_indicators': {'text': developmentalIndicators},
      'symbolic_content': {'text': symbolicContent},
      'social_and_family_context': {'text': socialAndFamilyContext},
      'emerging_themes': emergingThemes,
      'recommendations': recommendations.toJson(),
    };
  }
}

class Recommendations {
  final List<String> parentingTips;
  final List<String> activityIdeas;

  Recommendations({
    required this.parentingTips,
    required this.activityIdeas,
  });

  factory Recommendations.fromJson(Map<String, dynamic> json) {
    return Recommendations(
      parentingTips: List<String>.from(json['parenting_tips'] ?? []),
      activityIdeas: List<String>.from(json['activity_ideas'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parenting_tips': parentingTips,
      'activity_ideas': activityIdeas,
    };
  }
}

class DrawingAnalysis {
  final String id;
  final String childId;
  final String imageUrl;
  final DateTime uploadDate;
  final DrawingTestType testType;
  final AnalysisStatus status;
  final DrawingAnalysisModel? aiResults;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  DrawingAnalysis({
    required this.id,
    required this.childId,
    required this.imageUrl,
    required this.uploadDate,
    required this.testType,
    required this.status,
    this.aiResults,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  // Analysis insights from AI results
  String get primaryInsight {
    if (aiResults == null) return 'Analiz henüz tamamlanmadı';
    return aiResults!.summary;
  }

  String get emotionalSignals {
    if (aiResults == null) return 'Duygusal analiz henüz tamamlanmadı';
    return aiResults!.analysis.emotionalSignals;
  }

  String get developmentalIndicators {
    if (aiResults == null) return 'Gelişimsel analiz henüz tamamlanmadı';
    return aiResults!.analysis.developmentalIndicators;
  }

  String get symbolicContent {
    if (aiResults == null) return 'Sembolik analiz henüz tamamlanmadı';
    return aiResults!.analysis.symbolicContent;
  }

  String get socialAndFamilyContext {
    if (aiResults == null) return 'Sosyal ve aile analizi henüz tamamlanmadı';
    return aiResults!.analysis.socialAndFamilyContext;
  }

  List<String> get emergingThemes {
    if (aiResults == null) return [];
    return aiResults!.analysis.emergingThemes;
  }

  List<String> get parentingTips {
    if (aiResults == null) return [];
    return aiResults!.analysis.recommendations.parentingTips;
  }

  List<String> get activityIdeas {
    if (aiResults == null) return [];
    return aiResults!.analysis.recommendations.activityIdeas;
  }

  // Backward compatibility - these methods now derive scores from the text analysis
  int get emotionalScore {
    if (aiResults == null) return 0;
    // You might want to implement a scoring algorithm based on the emotional signals text
    // For now, returning a default value
    return 85; // This could be calculated based on the analysis content
  }

  int get creativityScore {
    if (aiResults == null) return 0;
    // You might want to implement a scoring algorithm based on the analysis content
    return 80; // This could be calculated based on the analysis content
  }

  int get developmentScore {
    if (aiResults == null) return 0;
    // You might want to implement a scoring algorithm based on the analysis content
    return 75; // This could be calculated based on the analysis content
  }

  List<String> get keyFindings {
    if (aiResults == null) return [];
    return aiResults!.analysis.emergingThemes;
  }

  factory DrawingAnalysis.fromJson(Map<String, dynamic> json) {
    return DrawingAnalysis(
      id: json['id'] as String,
      childId: json['childId'] as String,
      imageUrl: json['imageUrl'] as String,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      testType: DrawingTestType.values.firstWhere(
        (type) => type.id == json['testType'],
      ),
      status: AnalysisStatus.values.firstWhere(
        (status) => status.id == json['status'],
      ),
      aiResults: json['aiResults'] != null
          ? DrawingAnalysisModel.fromJson(
              json['aiResults'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'imageUrl': imageUrl,
      'uploadDate': uploadDate.toIso8601String(),
      'testType': testType.id,
      'status': status.id,
      'aiResults': aiResults?.toJson(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  DrawingAnalysis copyWith({
    String? id,
    String? childId,
    String? imageUrl,
    DateTime? uploadDate,
    DrawingTestType? testType,
    AnalysisStatus? status,
    DrawingAnalysisModel? aiResults,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return DrawingAnalysis(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      imageUrl: imageUrl ?? this.imageUrl,
      uploadDate: uploadDate ?? this.uploadDate,
      testType: testType ?? this.testType,
      status: status ?? this.status,
      aiResults: aiResults ?? this.aiResults,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
