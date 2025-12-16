class PostModel {
  final String postId;
  final String userId;
  final String username;
  final String fullName;
  final String? profilePic;
  final String caption;
  final String mediaType;
  final String mediaUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    required this.fullName,
    this.profilePic,
    required this.caption,
    required this.mediaType,
    required this.mediaUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return PostModel(
      postId: json['post_id']?.toString() ?? '',
      userId: user['user_id']?.toString() ?? '',
      username: user['username'] ?? '',
      fullName: user['full_name'] ?? '',
      profilePic: user['profile_pic'],
      caption: json['caption'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      mediaUrl: json['media_url'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  PostModel copyWith({
    bool? isLiked,
    int? likesCount,
  }) {
    return PostModel(
      postId: postId,
      userId: userId,
      username: username,
      fullName: fullName,
      profilePic: profilePic,
      caption: caption,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }
}