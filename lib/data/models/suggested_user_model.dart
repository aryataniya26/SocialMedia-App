class SuggestedUser {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String? profileImage;
  final String? bio;
  final bool isVerified;
  final int mutualFriends;
  final String reason; // 'mutual_friends', 'same_interest', 'popular'

  SuggestedUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.profileImage,
    this.bio,
    this.isVerified = false,
    this.mutualFriends = 0,
    this.reason = 'mutual_friends',
  });

  factory SuggestedUser.fromJson(Map<String, dynamic> json) {
    return SuggestedUser(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      profileImage: json['profileImage']?.toString(),
      bio: json['bio']?.toString(),
      isVerified: json['isVerified'] ?? false,
      mutualFriends: json['mutualFriends'] ?? 0,
      reason: json['reason']?.toString() ?? 'mutual_friends',
    );
  }

  String get fullName => '$firstName $lastName';
}