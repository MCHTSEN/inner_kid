class ChildProfile {
  final String id;
  final String userId; // Parent user ID
  final String name;
  final DateTime birthDate;
  final String gender;
  final String? avatarUrl;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChildProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.avatarUrl,
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  int get ageInYears {
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      return age - 1;
    }
    return age;
  }

  int get ageInMonths {
    final now = DateTime.now();
    return (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
  }

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory ChildProfile.fromMap(Map<String, dynamic> map, String id) {
    return ChildProfile(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      birthDate: map['birthDate']?.toDate() ?? DateTime.now(),
      gender: map['gender'] ?? '',
      avatarUrl: map['avatarUrl'],
      additionalInfo: Map<String, dynamic>.from(map['additionalInfo'] ?? {}),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'avatarUrl': avatarUrl,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'birthDate': birthDate,
      'gender': gender,
      'avatarUrl': avatarUrl,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ChildProfile copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? avatarUrl,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
