class DummyData {
  static Map<String, dynamic> getResponse(String endpoint, [Map<String, dynamic>? body]) {
    // Login
    if (endpoint.contains('/auth/login')) {
      return {
        'success': true,
        'message': 'Login successful',
        'data': {
          'access_token': 'dummy_access_token_12345',
          'refresh_token': 'dummy_refresh_token_67890',
          'user': {
            'user_id': '1',
            'full_name': 'Demo User',
            'username': 'demo_user',
            'email': 'demo@clickme.com',
            'mobile': '1234567890',
            'profile_pic': 'https://via.placeholder.com/150',
            'profile_type': 'public',
          }
        }
      };
    }

    // Send OTP
    if (endpoint.contains('/auth/send-otp')) {
      return {
        'success': true,
        'message': 'OTP sent successfully',
        'data': {'otp': '1234'} // Only for testing
      };
    }

    // Verify OTP
    if (endpoint.contains('/auth/verify-otp')) {
      return {
        'success': true,
        'message': 'OTP verified successfully',
        'data': {
          'access_token': 'dummy_access_token_12345',
          'refresh_token': 'dummy_refresh_token_67890',
        }
      };
    }

    // Register
    if (endpoint.contains('/auth/register')) {
      return {
        'success': true,
        'message': 'Registration successful',
        'data': {
          'user_id': '1',
          'message': 'Please verify OTP'
        }
      };
    }

    // Home Feed
    if (endpoint.contains('/feed/home')) {
      return {
        'success': true,
        'data': {
          'posts': List.generate(10, (index) => _getDummyPost(index)),
        }
      };
    }

    // User Profile
    if (endpoint.contains('/user/profile/')) {
      return {
        'success': true,
        'data': {
          'user_id': '1',
          'full_name': 'Demo User',
          'username': 'demo_user',
          'bio': 'This is a demo bio',
          'profile_pic': 'https://via.placeholder.com/150',
          'cover_pic': 'https://via.placeholder.com/600x200',
          'followers_count': 1234,
          'following_count': 567,
          'posts_count': 89,
        }
      };
    }

    // Default success
    return {
      'success': true,
      'message': 'Operation successful',
      'data': {}
    };
  }

  static Map<String, dynamic> _getDummyPost(int index) {
    return {
      'post_id': '${index + 1}',
      'user': {
        'user_id': '${index + 1}',
        'username': 'user_${index + 1}',
        'full_name': 'User ${index + 1}',
        'profile_pic': 'https://via.placeholder.com/50',
      },
      'caption': 'This is post number ${index + 1}',
      'media_type': index % 2 == 0 ? 'image' : 'video',
      'media_url': index % 2 == 0
          ? 'https://via.placeholder.com/400'
          : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'likes_count': (index + 1) * 10,
      'comments_count': (index + 1) * 5,
      'is_liked': index % 3 == 0,
      'created_at': DateTime.now().subtract(Duration(hours: index)).toIso8601String(),
    };
  }
}