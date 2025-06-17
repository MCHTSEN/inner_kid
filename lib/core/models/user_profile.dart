// User Profile Model
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final bool isSubscriptionActive;
  final DateTime? subscriptionExpiry;
  final String subscriptionTier; // 'free', 'premium', 'family'
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalInfo;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.isSubscriptionActive,
    this.subscriptionExpiry,
    required this.subscriptionTier,
    required this.createdAt,
    required this.updatedAt,
    this.additionalInfo,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      isSubscriptionActive: map['isSubscriptionActive'] ?? false,
      subscriptionExpiry: map['subscriptionExpiry']?.toDate(),
      subscriptionTier: map['subscriptionTier'] ?? 'free',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      additionalInfo: Map<String, dynamic>.from(map['additionalInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'isSubscriptionActive': isSubscriptionActive,
      'subscriptionExpiry': subscriptionExpiry,
      'subscriptionTier': subscriptionTier,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'additionalInfo': additionalInfo,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    bool? isSubscriptionActive,
    DateTime? subscriptionExpiry,
    String? subscriptionTier,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalInfo,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, name: $name, subscriptionTier: $subscriptionTier)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
