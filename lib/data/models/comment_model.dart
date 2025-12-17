class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String? userAvatar;
  final String text;
  final List<CommentModel> replies;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.text,
    this.replies = const [],
    this.likesCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? 'User',
      userAvatar: json['userAvatar']?.toString(),
      text: json['text']?.toString() ?? '',
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'postId': postId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'text': text,
      'likesCount': likesCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? username,
    String? userAvatar,
    String? text,
    List<CommentModel>? replies,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      text: text ?? this.text,
      replies: replies ?? this.replies,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}