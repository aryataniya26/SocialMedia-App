import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/post_model.dart';
import '../../core/constants/api_endpoints.dart';

class PostProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // Fetch Home Feed
  Future<void> fetchHomeFeed({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _page = 1;
      _posts = [];
      _hasMore = true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiEndpoints.homeFeed,
        queryParams: {
          'page': _page.toString(),
          'limit': '10',
        },
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final List postsJson = data['posts'] ?? [];

        final newPosts = postsJson.map((json) => PostModel.fromJson(json)).toList();

        if (refresh) {
          _posts = newPosts;
        } else {
          _posts.addAll(newPosts);
        }

        _hasMore = newPosts.length >= 10;
        _page++;
      }
    } catch (e) {
      debugPrint('Error fetching feed: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Like Post
  Future<void> likePost(String postId) async {
    try {
      final index = _posts.indexWhere((p) => p.postId == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = post.copyWith(
          isLiked: !post.isLiked,
          likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
        notifyListeners();

        await _apiService.post(
          ApiEndpoints.likePost(postId),
          requiresAuth: true,
        );
      }
    } catch (e) {
      debugPrint('Error liking post: $e');
    }
  }
}