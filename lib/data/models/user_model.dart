class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? profileImage;
  final String? coverPhoto;
  final String userType;
  final String? bio;
  final String profileType; // personal or business
  final String status; // active, inactive, suspended
  final bool? isPrivate;
  final int loginAttempts;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed properties
  String get fullName => '$firstName $lastName';
  String get username => email?.split('@').first ?? firstName.toLowerCase();

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.avatar,
    this.profileImage,
    this.coverPhoto,
    this.userType = 'user',
    this.bio,
    this.profileType = 'personal',
    this.status = 'active',
    this.isPrivate,
    this.loginAttempts = 0,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['_id']?.toString() ?? json['userId']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      profileImage: json['profileImage'],
      coverPhoto: json['coverPhoto'],
      userType: json['userType'] ?? 'user',
      bio: json['bio'],
      profileType: json['profile_type'] ?? 'personal',
      status: json['status'] ?? 'active',
      isPrivate: json['isPrivate'],
      loginAttempts: json['loginAttempts'] ?? 0,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
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
      '_id': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'profileImage': profileImage,
      'coverPhoto': coverPhoto,
      'userType': userType,
      'bio': bio,
      'profile_type': profileType,
      'status': status,
      'isPrivate': isPrivate,
      'loginAttempts': loginAttempts,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatar,
    String? profileImage,
    String? coverPhoto,
    String? userType,
    String? bio,
    String? profileType,
    String? status,
    bool? isPrivate,
    int? loginAttempts,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      profileImage: profileImage ?? this.profileImage,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      userType: userType ?? this.userType,
      bio: bio ?? this.bio,
      profileType: profileType ?? this.profileType,
      status: status ?? this.status,
      isPrivate: isPrivate ?? this.isPrivate,
      loginAttempts: loginAttempts ?? this.loginAttempts,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


// class UserModel {
//   final String userId;
//   final String fullName;
//   final String username;
//   final String? email;
//   final String? mobile;
//   final String? profilePic;
//   final String? coverPic;
//   final String? bio;
//   final String? gender;
//   final String? dob;
//   final String? category;
//   final String profileType;
//   final int followersCount;
//   final int followingCount;
//   final int postsCount;
//   final DateTime createdAt;
//
//   UserModel({
//     required this.userId,
//     required this.fullName,
//     required this.username,
//     this.email,
//     this.mobile,
//     this.profilePic,
//     this.coverPic,
//     this.bio,
//     this.gender,
//     this.dob,
//     this.category,
//     this.profileType = 'public',
//     this.followersCount = 0,
//     this.followingCount = 0,
//     this.postsCount = 0,
//     required this.createdAt,
//   });
//
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       userId: json['user_id']?.toString() ?? '',
//       fullName: json['full_name'] ?? '',
//       username: json['username'] ?? '',
//       email: json['email'],
//       mobile: json['mobile'],
//       profilePic: json['profile_pic'],
//       coverPic: json['cover_pic'],
//       bio: json['bio'],
//       gender: json['gender'],
//       dob: json['dob'],
//       category: json['category'],
//       profileType: json['profile_type'] ?? 'public',
//       followersCount: json['followers_count'] ?? 0,
//       followingCount: json['following_count'] ?? 0,
//       postsCount: json['posts_count'] ?? 0,
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'])
//           : DateTime.now(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'user_id': userId,
//       'full_name': fullName,
//       'username': username,
//       'email': email,
//       'mobile': mobile,
//       'profile_pic': profilePic,
//       'cover_pic': coverPic,
//       'bio': bio,
//       'gender': gender,
//       'dob': dob,
//       'category': category,
//       'profile_type': profileType,
//       'followers_count': followersCount,
//       'following_count': followingCount,
//       'posts_count': postsCount,
//       'created_at': createdAt.toIso8601String(),
//     };
//   }
// }