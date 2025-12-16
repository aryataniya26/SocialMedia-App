class ChatThreadModel {
  final String threadId;
  final String user1Id;
  final String user2Id;
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;

  ChatThreadModel({
    required this.threadId,
    required this.user1Id,
    required this.user2Id,
    this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.createdAt,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    return ChatThreadModel(
      threadId: json['thread_id']?.toString() ?? '',
      user1Id: json['user1']?.toString() ?? '',
      user2Id: json['user2']?.toString() ?? '',
      otherUserName: json['other_user_name'],
      otherUserAvatar: json['other_user_avatar'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class ChatMessageModel {
  final String messageId;
  final String threadId;
  final String senderId;
  final String message;
  final String? mediaUrl;
  final String type;
  final DateTime createdAt;
  final bool isSeen;

  ChatMessageModel({
    required this.messageId,
    required this.threadId,
    required this.senderId,
    required this.message,
    this.mediaUrl,
    required this.type,
    required this.createdAt,
    this.isSeen = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['message_id']?.toString() ?? '',
      threadId: json['thread_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      message: json['message'] ?? '',
      mediaUrl: json['media_url'],
      type: json['type'] ?? 'text',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isSeen: json['is_seen'] ?? false,
    );
  }
}