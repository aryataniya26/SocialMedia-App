class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? profileImage;
  final String? coverPhoto;
  final String userType;
  final String? bio;
  final String profileType;
  final String status;
  final bool? isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? accessToken;
  final String? refreshToken;





  static UserModel? fromAuthResponse(Map<String, dynamic> response) {
    try {
      final data = response['data'];
      if (data == null) return null;

      return UserModel(
        id: data['_id']?.toString() ?? '',
        firstName: data['firstName']?.toString() ?? '',
        lastName: data['lastName']?.toString() ?? '',
        email: data['email']?.toString(),
        phone: data['phone']?.toString(),
        avatar: data['avatar']?.toString(),
        profileImage: data['profileImage']?.toString(),
        coverPhoto: data['coverPhoto']?.toString(),
        userType: data['userType']?.toString() ?? 'user',
        bio: data['bio']?.toString(),
        profileType: data['profile_type']?.toString() ?? 'personal',
        status: data['status']?.toString() ?? 'active',
        isPrivate: data['isPrivate'] ?? false,
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'])
            : DateTime.now(),
        updatedAt: data['updatedAt'] != null
            ? DateTime.parse(data['updatedAt'])
            : DateTime.now(),
        accessToken: data['accessToken']?.toString(),
        refreshToken: data['refreshToken']?.toString(),
      );
    } catch (e) {
      print('Error parsing user from auth response: $e');
      return null;
    }
  }




  UserModel({
    required this.id,
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
    required this.createdAt,
    required this.updatedAt,
    this.accessToken,
    this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      profileImage: json['profileImage']?.toString(),
      coverPhoto: json['coverPhoto']?.toString(),
      userType: json['userType']?.toString() ?? 'user',
      bio: json['bio']?.toString(),
      profileType: json['profile_type']?.toString() ?? 'personal',
      status: json['status']?.toString() ?? 'active',
      isPrivate: json['isPrivate'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      accessToken: json['accessToken']?.toString(),
      refreshToken: json['refreshToken']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  String get fullName => '$firstName $lastName';

  UserModel copyWith({
    String? id,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserModel(
      id: id ?? this.id,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}