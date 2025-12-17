import 'dart:convert';
import 'package:clickme_app/data/models/user_model.dart';

import 'api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/follow_model.dart';
import '../models/suggested_user_model.dart';

class FollowService {
  final ApiService _api = ApiService();

  // ==================== SEND FOLLOW REQUEST ====================
  Future<Map<String, dynamic>> sendFollowRequest(String targetUserId) async {
    try {
      print('📤 FollowService: Sending follow request to $targetUserId');

      final response = await _api.post(
        ApiEndpoints.followRequest(targetUserId),
        requiresAuth: true,
      );

      print('✅ Follow Request Response: ${json.encode(response)}');
      return response;
    } catch (e) {
      print('❌ Send Follow Request Error: $e');
      return {
        'success': false,
        'message': 'Failed to send follow request: ${e.toString()}',
      };
    }
  }

  // ==================== ACCEPT FOLLOW REQUEST ====================
  Future<Map<String, dynamic>> acceptFollowRequest(String requestId) async {
    try {
      print('✅ FollowService: Accepting follow request $requestId');

      final response = await _api.post(
        ApiEndpoints.followAccept(requestId),
        requiresAuth: true,
      );

      return response;
    } catch (e) {
      print('❌ Accept Follow Request Error: $e');
      return {
        'success': false,
        'message': 'Failed to accept follow request: ${e.toString()}',
      };
    }
  }

  // ==================== REMOVE FOLLOW REQUEST ====================
  Future<Map<String, dynamic>> removeFollowRequest(String requestId) async {
    try {
      print('🗑️ FollowService: Removing follow request $requestId');

      final response = await _api.post(
        ApiEndpoints.followRemoveRequest(requestId),
        requiresAuth: true,
      );

      return response;
    } catch (e) {
      print('❌ Remove Follow Request Error: $e');
      return {
        'success': false,
        'message': 'Failed to remove follow request: ${e.toString()}',
      };
    }
  }

  // ==================== GET FOLLOW STATUS ====================
  Future<FollowStatus> getFollowStatus(String targetUserId) async {
    try {
      print('🔍 FollowService: Getting follow status for $targetUserId');

      // Since we don't have a dedicated endpoint, we'll check from total followers/following
      // For now, return a default status
      return FollowStatus(
        status: 'not-following',
        isPrivateProfile: false,
        hasPendingRequest: false,
      );
    } catch (e) {
      print('❌ Get Follow Status Error: $e');
      return FollowStatus(
        status: 'not-following',
        isPrivateProfile: false,
        hasPendingRequest: false,
      );
    }
  }

  // ==================== GET FOLLOWERS LIST ====================
  Future<List<UserModel>> getFollowers(String userId, {int page = 1, int limit = 20}) async {
    try {
      print('👥 FollowService: Getting followers for $userId');

      final response = await _api.get(
        ApiEndpoints.followers(userId),
        queryParams: {'page': page.toString(), 'limit': limit.toString()},
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> usersData = response['data'];
        return usersData.map((user) => UserModel.fromJson(user)).toList();
      }

      return [];
    } catch (e) {
      print('❌ Get Followers Error: $e');
      return [];
    }
  }

  // ==================== GET FOLLOWING LIST ====================
  Future<List<UserModel>> getFollowing(String userId, {int page = 1, int limit = 20}) async {
    try {
      print('👥 FollowService: Getting following for $userId');

      final response = await _api.get(
        ApiEndpoints.following(userId),
        queryParams: {'page': page.toString(), 'limit': limit.toString()},
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> usersData = response['data'];
        return usersData.map((user) => UserModel.fromJson(user)).toList();
      }

      return [];
    } catch (e) {
      print('❌ Get Following Error: $e');
      return [];
    }
  }

  // ==================== GET FOLLOW SUGGESTIONS ====================
  Future<List<SuggestedUser>> getFollowSuggestions({int limit = 10, String? cursor}) async {
    try {
      print('💡 FollowService: Getting follow suggestions');

      // For now, return dummy data since API might not be ready
      return _getDummySuggestions(limit);
    } catch (e) {
      print('❌ Get Follow Suggestions Error: $e');
      return [];
    }
  }

  // ==================== DUMMY SUGGESTIONS (Temporary) ====================
  List<SuggestedUser> _getDummySuggestions(int limit) {
    return [
      SuggestedUser(
        id: '1',
        firstName: 'Alex',
        lastName: 'Johnson',
        avatar: null,
        bio: 'Travel enthusiast & photographer',
        mutualFriends: 12,
        reason: 'mutual_friends',
      ),
      SuggestedUser(
        id: '2',
        firstName: 'Sarah',
        lastName: 'Miller',
        avatar: null,
        bio: 'Food blogger | Coffee lover',
        mutualFriends: 8,
        reason: 'same_interest',
      ),
      SuggestedUser(
        id: '3',
        firstName: 'Mike',
        lastName: 'Taylor',
        avatar: null,
        bio: 'Fitness coach & motivator',
        mutualFriends: 5,
        reason: 'popular',
        isVerified: true,
      ),
      SuggestedUser(
        id: '4',
        firstName: 'Emma',
        lastName: 'Wilson',
        avatar: null,
        bio: 'Digital creator',
        mutualFriends: 15,
        reason: 'mutual_friends',
      ),
      SuggestedUser(
        id: '5',
        firstName: 'David',
        lastName: 'Chen',
        avatar: null,
        bio: 'Tech entrepreneur',
        mutualFriends: 3,
        reason: 'same_interest',
        isVerified: true,
      ),
    ].take(limit).toList();
  }

  // ==================== GET TOTAL FOLLOWERS COUNT ====================
  Future<int> getTotalFollowers() async {
    try {
      final response = await _api.get(
        ApiEndpoints.totalFollowers,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data']['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Get Total Followers Error: $e');
      return 0;
    }
  }

  // ==================== GET TOTAL FOLLOWING COUNT ====================
  Future<int> getTotalFollowing() async {
    try {
      final response = await _api.get(
        ApiEndpoints.totalFollowing,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data']['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Get Total Following Error: $e');
      return 0;
    }
  }
}


// // lib/data/services/follow_service.dart
//
// import '../../core/constants/api_endpoints.dart';
// import 'api_service.dart';
//
// class FollowService {
//   final ApiService _apiService = ApiService();
//
//   // Send Follow Request
//   Future<Map<String, dynamic>> sendFollowRequest(String userId) async {
//     try {
//       final response = await _apiService.post(
//         ApiEndpoints.followRequest(userId),
//         requiresAuth: true,
//       );
//
//       return response;
//     } catch (e) {
//       print('❌ Follow Request Error: $e');
//       return {
//         'success': false,
//         'message': 'Failed to send follow request: ${e.toString()}',
//       };
//     }
//   }
//
//   // Accept Follow Request
//   Future<Map<String, dynamic>> acceptFollowRequest(String requestId) async {
//     try {
//       final response = await _apiService.post(
//         ApiEndpoints.followAccept(requestId),
//         requiresAuth: true,
//       );
//
//       return response;
//     } catch (e) {
//       print('❌ Accept Request Error: $e');
//       return {
//         'success': false,
//         'message': 'Failed to accept request: ${e.toString()}',
//       };
//     }
//   }
//
//   // Remove/Reject Follow Request
//   Future<Map<String, dynamic>> removeFollowRequest(String requestId) async {
//     try {
//       final response = await _apiService.post(
//         ApiEndpoints.followRemoveRequest(requestId),
//         requiresAuth: true,
//       );
//
//       return response;
//     } catch (e) {
//       print('❌ Remove Request Error: $e');
//       return {
//         'success': false,
//         'message': 'Failed to remove request: ${e.toString()}',
//       };
//     }
//   }
//
//   // Unfollow User
//   Future<Map<String, dynamic>> unfollowUser(String userId) async {
//     try {
//       final response = await _apiService.delete(
//         ApiEndpoints.followRequest(userId),
//         requiresAuth: true,
//       );
//
//       return response;
//     } catch (e) {
//       print('❌ Unfollow Error: $e');
//       return {
//         'success': false,
//         'message': 'Failed to unfollow: ${e.toString()}',
//       };
//     }
//   }
//
//   // Get Total Followers Count
//   Future<Map<String, dynamic>> getTotalFollowers() async {
//     try {
//       final response = await _apiService.get(
//         ApiEndpoints.totalFollowers,
//         requiresAuth: true,
//       );
//
//       return response;
//     } catch (e) {
//       print('❌ Get Followers Error: $e');
//       return {
//         'success': false,
//         'message': 'Failed to get followers: ${e.toString()}',
//       };
//     }
//   }
//
//   // Get Total Following Count
//   Future<Map<String, dynamic>> getTotalFollowing() async {
//     try {
//       final response = await _apiService.get(
//         ApiEndpoints.totalFollowing,
//         requiresAuth: true,
//       );
//
//       return response;
//     } catch (e) {
//       print('❌ Get Following Error: $e');
//       return {
//         'success': false,
//         'message': 'Failed to get following: ${e.toString()}',
//       };
//     }
//   }
//
//   // Get Followers List (if you add this endpoint later)
//   Future<Map<String, dynamic>> getFollowersList(String userId) async {
//     try {
//       final response = await _apiService.get(
//         ApiEndpoints.followers(userId),
//         requiresAuth: true,
//       );
//
//       return response;
//     } catch (e) {
//       print('❌ Get Followers List Error: $e');
//       return {
//         'success': false,
//         'message': 'Failed to get followers list: ${e.toString()}',
//       };
//     }
//   }
//
//   // Get Following List
//   Future<Map<String, dynamic>> getFollowingList(String userId) async {
//     try {
//       final response = await _apiService.get(
//         ApiEndpoints.following(userId),
//         requiresAuth: true,
//       );
//
//       return response;
//     } catch (e) {
//       print('❌ Get Following List Error: $e');
//       return {
//         'success': false,
//         'message': 'Failed to get following list: ${e.toString()}',
//       };
//     }
//   }
// }