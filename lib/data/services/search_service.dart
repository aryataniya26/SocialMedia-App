// lib/data/services/search_service.dart

import 'package:flutter/foundation.dart';
import '../../core/constants/api_endpoints.dart';
import 'api_service.dart';

class SearchService {
  final ApiService _api = ApiService();

  // ==================== GLOBAL SEARCH ====================
  Future<Map<String, dynamic>> globalSearch(String query) async {
    try {
      final response = await _api.get(
        ApiEndpoints.searchGlobal,
        queryParams: {'q': query, 'limit': '20'},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        debugPrint('✅ Global search successful');
      } else {
        debugPrint('❌ Global search failed: ${response['message']}');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Global search error: $e');
      return {
        'success': false,
        'message': 'Search failed: $e',
        'data': {'users': [], 'posts': [], 'hashtags': []},
      };
    }
  }

  // ==================== SEARCH USERS ====================
  Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      final response = await _api.get(
        ApiEndpoints.searchUsers,
        queryParams: {'q': query, 'limit': '20'},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        debugPrint('✅ User search successful');
      } else {
        debugPrint('❌ User search failed: ${response['message']}');
      }

      return response;
    } catch (e) {
      debugPrint('❌ User search error: $e');
      return {
        'success': false,
        'message': 'User search failed: $e',
        'data': [],
      };
    }
  }

  // ==================== SEARCH POSTS ====================
  Future<Map<String, dynamic>> searchPosts(String query) async {
    try {
      final response = await _api.get(
        'api/v1/search/posts',
        queryParams: {'q': query, 'limit': '20'},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        debugPrint('✅ Post search successful');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Post search error: $e');
      return {
        'success': false,
        'message': 'Post search failed: $e',
        'data': [],
      };
    }
  }

  // ==================== SEARCH HASHTAGS ====================
  Future<Map<String, dynamic>> searchHashtags(String query) async {
    try {
      final response = await _api.get(
        'api/v1/search/hashtags',
        queryParams: {'q': query, 'limit': '20'},
        requiresAuth: true,
      );

      if (response['success'] == true) {
        debugPrint('✅ Hashtag search successful');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Hashtag search error: $e');
      return {
        'success': false,
        'message': 'Hashtag search failed: $e',
        'data': [],
      };
    }
  }

  // ==================== GET TRENDING ====================
  Future<Map<String, dynamic>> getTrending() async {
    try {
      final response = await _api.get(
        'api/v1/search/trending',
        requiresAuth: true,
      );

      if (response['success'] == true) {
        debugPrint('✅ Trending fetched successfully');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Get trending error: $e');
      return {
        'success': false,
        'message': 'Failed to get trending: $e',
        'data': [],
      };
    }
  }

  // ==================== RECENT SEARCHES ====================
  Future<List<String>> getRecentSearches() async {
    // TODO: Store in local storage
    return [];
  }

  Future<void> saveRecentSearch(String query) async {
    // TODO: Save to local storage
    debugPrint('💾 Saving recent search: $query');
  }

  Future<void> clearRecentSearches() async {
    // TODO: Clear from local storage
    debugPrint('🗑️ Clearing recent searches');
  }
}