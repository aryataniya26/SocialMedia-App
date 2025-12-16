class StoryModel {
  final String storyId;
  final String userId;
  final String username;
  final String fullName;
  final String? profilePic;
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;
  final DateTime expiryAt;
  final bool isSeen;

  StoryModel({
    required this.storyId,
    required this.userId,
    required this.username,
    required this.fullName,
    this.profilePic,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
    required this.expiryAt,
    this.isSeen = false,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      storyId: json['story_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      profilePic: json['profile_pic'],
      mediaUrl: json['media_url'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      expiryAt: json['expiry_at'] != null
          ? DateTime.parse(json['expiry_at'])
          : DateTime.now().add(const Duration(hours: 24)),
      isSeen: json['is_seen'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'story_id': storyId,
      'user_id': userId,
      'username': username,
      'full_name': fullName,
      'profile_pic': profilePic,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'created_at': createdAt.toIso8601String(),
      'expiry_at': expiryAt.toIso8601String(),
      'is_seen': isSeen,
    };
  }
}