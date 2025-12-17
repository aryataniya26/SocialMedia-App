class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String? mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String? caption;
  final String? location;
  final List<String>? viewers;
  final int viewsCount;
  final bool isViewed;
  final bool isExpired;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String visibility; // 'public', 'friends', 'private'

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    this.mediaUrl,
    this.mediaType = 'image',
    this.caption,
    this.location,
    this.viewers,
    this.viewsCount = 0,
    this.isViewed = false,
    this.isExpired = false,
    required this.createdAt,
    required this.expiresAt,
    this.visibility = 'public',
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? 'User',
      userAvatar: json['userAvatar']?.toString(),
      mediaUrl: json['mediaUrl']?.toString(),
      mediaType: json['mediaType']?.toString() ?? 'image',
      caption: json['caption']?.toString(),
      location: json['location']?.toString(),
      viewers: json['viewers'] != null
          ? List<String>.from(json['viewers'])
          : null,
      viewsCount: json['viewsCount'] ?? 0,
      isViewed: json['isViewed'] ?? false,
      isExpired: json['isExpired'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(hours: 24)),
      visibility: json['visibility']?.toString() ?? 'public',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'location': location,
      'viewers': viewers,
      'viewsCount': viewsCount,
      'isViewed': isViewed,
      'isExpired': isExpired,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'visibility': visibility,
    };
  }

  // Check if story is active (not expired)
  bool get isActive => !isExpired && DateTime.now().isBefore(expiresAt);

  // Time remaining for story
  Duration get timeRemaining => expiresAt.difference(DateTime.now());

  // Formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inHours > 24) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  StoryModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? mediaUrl,
    String? mediaType,
    String? caption,
    String? location,
    List<String>? viewers,
    int? viewsCount,
    bool? isViewed,
    bool? isExpired,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? visibility,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      caption: caption ?? this.caption,
      location: location ?? this.location,
      viewers: viewers ?? this.viewers,
      viewsCount: viewsCount ?? this.viewsCount,
      isViewed: isViewed ?? this.isViewed,
      isExpired: isExpired ?? this.isExpired,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      visibility: visibility ?? this.visibility,
    );
  }
}

// class StoryModel {
//   final String storyId;
//   final String userId;
//   final String username;
//   final String fullName;
//   final String? profilePic;
//   final String mediaUrl;
//   final String mediaType;
//   final DateTime createdAt;
//   final DateTime expiryAt;
//   final bool isSeen;
//
//   StoryModel({
//     required this.storyId,
//     required this.userId,
//     required this.username,
//     required this.fullName,
//     this.profilePic,
//     required this.mediaUrl,
//     required this.mediaType,
//     required this.createdAt,
//     required this.expiryAt,
//     this.isSeen = false,
//   });
//
//   factory StoryModel.fromJson(Map<String, dynamic> json) {
//     return StoryModel(
//       storyId: json['story_id']?.toString() ?? '',
//       userId: json['user_id']?.toString() ?? '',
//       username: json['username'] ?? '',
//       fullName: json['full_name'] ?? '',
//       profilePic: json['profile_pic'],
//       mediaUrl: json['media_url'] ?? '',
//       mediaType: json['media_type'] ?? 'image',
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'])
//           : DateTime.now(),
//       expiryAt: json['expiry_at'] != null
//           ? DateTime.parse(json['expiry_at'])
//           : DateTime.now().add(const Duration(hours: 24)),
//       isSeen: json['is_seen'] ?? false,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'story_id': storyId,
//       'user_id': userId,
//       'username': username,
//       'full_name': fullName,
//       'profile_pic': profilePic,
//       'media_url': mediaUrl,
//       'media_type': mediaType,
//       'created_at': createdAt.toIso8601String(),
//       'expiry_at': expiryAt.toIso8601String(),
//       'is_seen': isSeen,
//     };
//   }
// }