import 'package:flutter/material.dart';
import '../services/follow_service.dart';
import '../models/follow_model.dart';
import '../models/user_model.dart';
import '../models/suggested_user_model.dart';

class FollowProvider with ChangeNotifier {
  final FollowService _followService = FollowService();

  // State
  Map<String, FollowStatus> _followStatus = {};
  Map<String, List<UserModel>> _followers = {};
  Map<String, List<UserModel>> _following = {};
  List<SuggestedUser> _suggestions = [];
  bool _isLoading = false;
  String? _error;

  int _followersCount = 0;
  int _followingCount = 0;


  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SuggestedUser> get suggestions => _suggestions;

  int get followersCount => _followersCount;
  int get followingCount => _followingCount;


  // Helper method
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
  // ==================== FETCH FOLLOW COUNTS ====================
  Future<void> fetchFollowCounts() async {
    _setLoading(true);

    try {
      final stats = await getFollowStats();

      // You can store these in separate variables if needed
      print('📊 Follow Stats: $stats');

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      print('❌ Error fetching follow counts: $e');
    }
  }

  // ==================== SEND FOLLOW REQUEST ====================
  Future<Map<String, dynamic>> sendFollowRequest(String targetUserId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _followService.sendFollowRequest(targetUserId);

      _setLoading(false);

      if (response['success'] == true) {
        // Update local state
        _followStatus[targetUserId] = FollowStatus(
          status: 'requested',
          isPrivateProfile: _followStatus[targetUserId]?.isPrivateProfile ?? false,
          hasPendingRequest: true,
          requestId: response['data']?['requestId'],
        );
        notifyListeners();

        return {
          'success': true,
          'message': response['message'] ?? 'Follow request sent',
        };
      } else {
        _setError(response['message'] ?? 'Failed to send follow request');
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to send follow request',
        };
      }
    } catch (e) {
      _setLoading(false);
      _setError('Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ==================== ACCEPT FOLLOW REQUEST ====================
  Future<Map<String, dynamic>> acceptFollowRequest(String requestId, String requesterId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _followService.acceptFollowRequest(requestId);

      _setLoading(false);

      if (response['success'] == true) {
        // Update local state
        _followStatus[requesterId] = FollowStatus(
          status: 'following',
          isPrivateProfile: false,
          hasPendingRequest: false,
        );
        notifyListeners();

        return {
          'success': true,
          'message': response['message'] ?? 'Follow request accepted',
        };
      } else {
        _setError(response['message'] ?? 'Failed to accept follow request');
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to accept follow request',
        };
      }
    } catch (e) {
      _setLoading(false);
      _setError('Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ==================== UNFOLLOW USER ====================
  Future<Map<String, dynamic>> unfollowUser(String targetUserId) async {
    _setLoading(true);
    _setError(null);

    try {
      // We'll use remove follow request endpoint for now
      // In real API, there should be an unfollow endpoint
      final response = await _followService.removeFollowRequest(targetUserId);

      _setLoading(false);

      if (response['success'] == true) {
        // Update local state
        _followStatus[targetUserId] = FollowStatus(
          status: 'not-following',
          isPrivateProfile: _followStatus[targetUserId]?.isPrivateProfile ?? false,
          hasPendingRequest: false,
        );
        notifyListeners();

        return {
          'success': true,
          'message': response['message'] ?? 'Unfollowed successfully',
        };
      } else {
        _setError(response['message'] ?? 'Failed to unfollow');
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to unfollow',
        };
      }
    } catch (e) {
      _setLoading(false);
      _setError('Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ==================== GET FOLLOW STATUS ====================
  Future<FollowStatus> getFollowStatus(String targetUserId) async {
    // Return cached status if available
    if (_followStatus.containsKey(targetUserId)) {
      return _followStatus[targetUserId]!;
    }

    try {
      final status = await _followService.getFollowStatus(targetUserId);
      _followStatus[targetUserId] = status;
      return status;
    } catch (e) {
      print('Error getting follow status: $e');
      return FollowStatus(
        status: 'not-following',
        isPrivateProfile: false,
        hasPendingRequest: false,
      );
    }
  }

  // ==================== GET FOLLOWERS ====================
  Future<List<UserModel>> getFollowers(String userId, {bool refresh = false}) async {
    if (!refresh && _followers.containsKey(userId)) {
      return _followers[userId]!;
    }

    try {
      final followers = await _followService.getFollowers(userId);
      _followers[userId] = followers;
      return followers;
    } catch (e) {
      print('Error getting followers: $e');
      return [];
    }
  }

  // ==================== GET FOLLOWING ====================
  Future<List<UserModel>> getFollowing(String userId, {bool refresh = false}) async {
    if (!refresh && _following.containsKey(userId)) {
      return _following[userId]!;
    }

    try {
      final following = await _followService.getFollowing(userId);
      _following[userId] = following;
      return following;
    } catch (e) {
      print('Error getting following: $e');
      return [];
    }
  }

  // ==================== GET FOLLOW SUGGESTIONS ====================
  Future<List<SuggestedUser>> getFollowSuggestions({bool refresh = false}) async {
    if (!refresh && _suggestions.isNotEmpty) {
      return _suggestions;
    }

    _setLoading(true);
    _setError(null);

    try {
      final suggestions = await _followService.getFollowSuggestions();
      _suggestions = suggestions;
      _setLoading(false);
      return suggestions;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load suggestions');
      return [];
    }
  }

  // ==================== GET FOLLOW STATS ====================
  Future<Map<String, int>> getFollowStats() async {
    try {
      _followersCount = await _followService.getTotalFollowers();
      _followingCount = await _followService.getTotalFollowing();

      notifyListeners(); // Important: notify UI to update

      return {
        'followers': _followersCount,
        'following': _followingCount,
      };
    } catch (e) {
      print('❌ Error getting follow stats: $e');
      return {'followers': 0, 'following': 0};
    }
  }
  // ==================== CLEAR ERROR ====================
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== CLEAR CACHE ====================
  void clearCache() {
    _followStatus.clear();
    _followers.clear();
    _following.clear();
    _suggestions.clear();
    notifyListeners();
  }
}
