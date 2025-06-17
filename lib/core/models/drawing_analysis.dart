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

class DrawingAnalysis {
  final String id;
  final String childId;
  final String imageUrl;
  final DateTime uploadDate;
  final DrawingTestType testType;
  final AnalysisStatus status;
  final Map<String, dynamic>? aiResults;
  final String? expertComments;
  final List<String> recommendations;
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
    this.expertComments,
    this.recommendations = const [],
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  // Analysis insights from AI results
  String get primaryInsight {
    if (aiResults == null) return 'Analiz henüz tamamlanmadı';
    return aiResults!['primaryInsight'] ?? 'Genel değerlendirme yapılıyor';
  }

  int get emotionalScore {
    if (aiResults == null) return 0;
    final score = aiResults!['emotionalScore'] ?? 0;
    return score is int ? score : (score as double).round();
  }

  int get creativityScore {
    if (aiResults == null) return 0;
    final score = aiResults!['creativityScore'] ?? 0;
    return score is int ? score : (score as double).round();
  }

  int get developmentScore {
    if (aiResults == null) return 0;
    final score = aiResults!['developmentScore'] ?? 0;
    return score is int ? score : (score as double).round();
  }

  List<String> get keyFindings {
    if (aiResults == null) return [];
    return List<String>.from(aiResults!['keyFindings'] ?? []);
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
      aiResults: json['aiResults'] as Map<String, dynamic>?,
      expertComments: json['expertComments'] as String?,
      recommendations: List<String>.from(json['recommendations'] ?? []),
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
      'aiResults': aiResults,
      'expertComments': expertComments,
      'recommendations': recommendations,
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
    Map<String, dynamic>? aiResults,
    String? expertComments,
    List<String>? recommendations,
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
      expertComments: expertComments ?? this.expertComments,
      recommendations: recommendations ?? this.recommendations,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
