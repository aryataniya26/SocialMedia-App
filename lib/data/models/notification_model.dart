class NotificationModel {
  final String notificationId;
  final String receiverId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String? postId;
  final String? reelId;
  final String type;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.notificationId,
    required this.receiverId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    this.postId,
    this.reelId,
    required this.type,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderName: json['sender_name'] ?? '',
      senderAvatar: json['sender_avatar'],
      postId: json['post_id']?.toString(),
      reelId: json['reel_id']?.toString(),
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }
}