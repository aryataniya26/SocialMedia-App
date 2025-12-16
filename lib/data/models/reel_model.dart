class ReelModel {
  final String reelId;
  final String userId;
  final String username;
  final String fullName;
  final String? profilePic;
  final String description;
  final String videoUrl;
  final String? thumbnail;
  final String? musicId;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isLiked;
  final DateTime createdAt;

  ReelModel({
    required this.reelId,
    required this.userId,
    required this.username,
    required this.fullName,
    this.profilePic,
    required this.description,
    required this.videoUrl,
    this.thumbnail,
    this.musicId,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return ReelModel(
      reelId: json['reel_id']?.toString() ?? '',
      userId: user['user_id']?.toString() ?? '',
      username: user['username'] ?? '',
      fullName: user['full_name'] ?? '',
      profilePic: user['profile_pic'],
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnail: json['thumbnail'],
      musicId: json['music_id'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  ReelModel copyWith({
    bool? isLiked,
    int? likesCount,
  }) {
    return ReelModel(
      reelId: reelId,
      userId: userId,
      username: username,
      fullName: fullName,
      profilePic: profilePic,
      description: description,
      videoUrl: videoUrl,
      thumbnail: thumbnail,
      musicId: musicId,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      viewsCount: viewsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
    );
  }
}