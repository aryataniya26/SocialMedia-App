class FollowRequest {
  final String id;
  final String requesterId;
  final String targetUserId;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final DateTime updatedAt;

  FollowRequest({
    required this.id,
    required this.requesterId,
    required this.targetUserId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FollowRequest.fromJson(Map<String, dynamic> json) {
    return FollowRequest(
      id: json['_id']?.toString() ?? '',
      requesterId: json['requesterId']?.toString() ?? '',
      targetUserId: json['targetUserId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'requesterId': requesterId,
      'targetUserId': targetUserId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class FollowStatus {
  final String status; // 'not-following', 'following', 'requested', 'follower', 'follow-back'
  final bool isPrivateProfile;
  final bool hasPendingRequest;
  final String? requestId;

  FollowStatus({
    required this.status,
    required this.isPrivateProfile,
    required this.hasPendingRequest,
    this.requestId,
  });

  factory FollowStatus.fromJson(Map<String, dynamic> json) {
    return FollowStatus(
      status: json['status']?.toString() ?? 'not-following',
      isPrivateProfile: json['isPrivateProfile'] ?? false,
      hasPendingRequest: json['hasPendingRequest'] ?? false,
      requestId: json['requestId']?.toString(),
    );
  }

  bool get isFollowing => status == 'following';
  bool get isNotFollowing => status == 'not-following';
  bool get isRequested => status == 'requested';
  bool get isFollower => status == 'follower';
  bool get canFollowBack => status == 'follow-back';
}

class UserFollowStats {
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final bool isFollowedBy;

  UserFollowStats({
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    required this.isFollowedBy,
  });

  factory UserFollowStats.fromJson(Map<String, dynamic> json) {
    return UserFollowStats(
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
      isFollowedBy: json['isFollowedBy'] ?? false,
    );
  }
}


// // lib/data/models/follow_model.dart
//
// class FollowRequest {
//   final String id;
//   final String followerId;
//   final String followingId;
//   final String status; // 'pending', 'accepted', 'rejected'
//   final DateTime createdAt;
//
//   FollowRequest({
//     required this.id,
//     required this.followerId,
//     required this.followingId,
//     required this.status,
//     required this.createdAt,
//   });
//
//   factory FollowRequest.fromJson(Map<String, dynamic> json) {
//     return FollowRequest(
//       id: json['_id'] ?? '',
//       followerId: json['follower_id'] ?? '',
//       followingId: json['following_id'] ?? '',
//       status: json['status'] ?? 'pending',
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'])
//           : DateTime.now(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'follower_id': followerId,
//       'following_id': followingId,
//       'status': status,
//       'created_at': createdAt.toIso8601String(),
//     };
//   }
// }
//
// class FollowStats {
//   final int followersCount;
//   final int followingCount;
//
//   FollowStats({
//     required this.followersCount,
//     required this.followingCount,
//   });
//
//   factory FollowStats.fromJson(Map<String, dynamic> json) {
//     return FollowStats(
//       followersCount: json['followersCount'] ?? 0,
//       followingCount: json['followingCount'] ?? 0,
//     );
//   }
// }
//
// class FollowUser {
//   final String id;
//   final String firstName;
//   final String lastName;
//   final String? profileImage;
//   final String? bio;
//   final bool isPrivate;
//
//   FollowUser({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     this.profileImage,
//     this.bio,
//     this.isPrivate = false,
//   });
//
//   String get fullName => '$firstName $lastName';
//
//   factory FollowUser.fromJson(Map<String, dynamic> json) {
//     return FollowUser(
//       id: json['_id'] ?? '',
//       firstName: json['firstName'] ?? '',
//       lastName: json['lastName'] ?? '',
//       profileImage: json['profileImage'],
//       bio: json['bio'],
//       isPrivate: json['isPrivate'] ?? false,
//     );
//   }
// }