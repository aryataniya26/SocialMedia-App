// lib/data/providers/post_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../models/post_model.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();

  // State variables
  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isUploading = false;
  bool _hasMore = true;
  int _page = 1;
  String? _errorMessage;

  // Getters
  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  // ==================== UPLOAD POST ====================
  Future<bool> uploadPost({
    required List<File> files,
    required String caption,
    String? location,
    String visibility = 'public',
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _postService.uploadPost(
        files: files,
        caption: caption,
        location: location,
        visibility: visibility,
      );

      if (response['success'] == true) {
        debugPrint('✅ Post uploaded successfully');

        // Optionally refresh feed after upload
        await fetchHomeFeed(refresh: true);

        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Upload failed';
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Upload error in provider: $e');
      _errorMessage = 'Upload failed: ${e.toString()}';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== FETCH HOME FEED ====================
  Future<void> fetchHomeFeed({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _page = 1;
      _posts = [];
      _hasMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call when backend endpoint is ready
      // For now using dummy data
      await Future.delayed(const Duration(seconds: 1));

      final dummyPosts = _generateDummyPosts(_page);

      if (refresh) {
        _posts = dummyPosts;
      } else {
        _posts.addAll(dummyPosts);
      }

      _hasMore = dummyPosts.length >= 10;
      _page++;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching feed: $e');
      _errorMessage = 'Failed to load feed';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== LIKE POST ====================
  Future<void> likePost(String postId) async {
    try {
      final index = _posts.indexWhere((p) => p.postId == postId);
      if (index != -1) {
        final post = _posts[index];
        final wasLiked = post.isLiked;

        // Optimistic update
        _posts[index] = post.copyWith(
          isLiked: !wasLiked,
          likesCount: wasLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
        notifyListeners();

        // API call
        final response = wasLiked
            ? await _postService.unlikePost(postId)
            : await _postService.likePost(postId);

        if (response['success'] != true) {
          // Revert on failure
          _posts[index] = post;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ Error liking post: $e');
    }
  }

  // ==================== DELETE POST ====================
  Future<bool> deletePost(String postId) async {
    try {
      final response = await _postService.deletePost(postId);

      if (response['success'] == true) {
        _posts.removeWhere((p) => p.postId == postId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to delete post';
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting post: $e');
      _errorMessage = 'Delete failed: ${e.toString()}';
      return false;
    }
  }

  // ==================== COMMENT ON POST ====================
  Future<bool> commentOnPost(String postId, String comment) async {
    try {
      final response = await _postService.commentOnPost(
        postId: postId,
        comment: comment,
      );

      if (response['success'] == true) {
        // Update comment count
        final index = _posts.indexWhere((p) => p.postId == postId);
        if (index != -1) {
          final post = _posts[index];
          _posts[index] = PostModel(
            postId: post.postId,
            userId: post.userId,
            username: post.username,
            fullName: post.fullName,
            profilePic: post.profilePic,
            caption: post.caption,
            mediaType: post.mediaType,
            mediaUrl: post.mediaUrl,
            likesCount: post.likesCount,
            commentsCount: post.commentsCount + 1,
            isLiked: post.isLiked,
            createdAt: post.createdAt,
          );
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to add comment';
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error commenting: $e');
      _errorMessage = 'Comment failed: ${e.toString()}';
      return false;
    }
  }

  // ==================== CLEAR ERROR ====================
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== CLEAR ALL DATA ====================
  void clear() {
    _posts.clear();
    _page = 1;
    _hasMore = true;
    _isLoading = false;
    _isUploading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== DUMMY DATA GENERATOR ====================
  List<PostModel> _generateDummyPosts(int page) {
    return List.generate(10, (index) {
      final offset = (page - 1) * 10 + index;
      return PostModel(
        postId: 'post_$offset',
        userId: 'user_${offset % 5}',
        username: 'user${offset % 5}',
        fullName: 'User ${offset % 5}',
        profilePic: 'https://i.pravatar.cc/150?img=${offset % 50}',
        caption: 'This is post #$offset. Check out this amazing content!',
        mediaType: 'image',
        mediaUrl: 'https://picsum.photos/400/400?random=$offset',
        likesCount: (offset * 13) % 100,
        commentsCount: (offset * 7) % 50,
        isLiked: offset % 3 == 0,
        createdAt: DateTime.now().subtract(Duration(hours: offset)),
      );
    });
  }
}