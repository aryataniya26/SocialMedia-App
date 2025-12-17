// lib/data/services/post_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_endpoints.dart';
import 'storage_service.dart';

class PostService {
  // ==================== UPLOAD POST ====================
  Future<Map<String, dynamic>> uploadPost({
    required List<File> files,
    required String caption,
    String? location,
    String visibility = 'public',
  }) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token not found',
        };
      }

      final url = Uri.parse(ApiEndpoints.getFullUrl(ApiEndpoints.uploadPost));
      final request = http.MultipartRequest('POST', url);

      // Add Authorization Header
      request.headers['Authorization'] = 'Bearer $token';

      // Add Files (images or videos)
      for (var file in files) {
        final mimeType = _getMimeType(file.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            'files', // Backend expects 'files' field
            file.path,
            contentType: http.MediaType.parse(mimeType),
          ),
        );
      }

      // Add Form Fields
      request.fields['caption'] = caption;
      if (location != null && location.isNotEmpty) {
        request.fields['location'] = location;
      }
      request.fields['visibility'] = visibility;

      debugPrint('🔵 Uploading post to: $url');
      debugPrint('📦 Files count: ${files.length}');
      debugPrint('📝 Caption: $caption');
      debugPrint('📍 Location: $location');

      // Send Request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          throw Exception('Upload timeout. Please check your connection.');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('🔥 Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Post uploaded successfully',
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to upload post',
        };
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return {
        'success': false,
        'message': 'Upload failed: ${e.toString()}',
      };
    }
  }

  // ==================== DELETE POST ====================
  Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl(ApiEndpoints.deletePost(postId)),
      );

      debugPrint('🔵 Deleting post: $url');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('🔥 Response Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Post deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete post',
        };
      }
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      return {
        'success': false,
        'message': 'Delete failed: ${e.toString()}',
      };
    }
  }

  // ==================== GET POST DETAILS ====================
  Future<Map<String, dynamic>> getPostDetails(String postId) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl(ApiEndpoints.getPost(postId)),
      );

      debugPrint('🔵 Getting post details: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch post',
        };
      }
    } catch (e) {
      debugPrint('❌ Fetch error: $e');
      return {
        'success': false,
        'message': 'Fetch failed: ${e.toString()}',
      };
    }
  }

  // ==================== LIKE POST ====================
  Future<Map<String, dynamic>> likePost(String postId) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl(ApiEndpoints.likePost(postId)),
      );

      debugPrint('🔵 Liking post: $url');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Post liked'};
      } else {
        return {'success': false, 'message': 'Failed to like post'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // ==================== UNLIKE POST ====================
  Future<Map<String, dynamic>> unlikePost(String postId) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl(ApiEndpoints.unlikePost(postId)),
      );

      debugPrint('🔵 Unliking post: $url');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Post unliked'};
      } else {
        return {'success': false, 'message': 'Failed to unlike post'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // ==================== COMMENT ON POST ====================
  Future<Map<String, dynamic>> commentOnPost({
    required String postId,
    required String comment,
  }) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl(ApiEndpoints.commentPost(postId)),
      );

      debugPrint('🔵 Commenting on post: $url');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'comment': comment}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Comment added',
          'data': data['data'],
        };
      } else {
        return {'success': false, 'message': 'Failed to add comment'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // ==================== DELETE COMMENT ====================
  Future<Map<String, dynamic>> deleteComment(String commentId) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl(ApiEndpoints.deleteComment(commentId)),
      );

      debugPrint('🔵 Deleting comment: $url');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Comment deleted'};
      } else {
        return {'success': false, 'message': 'Failed to delete comment'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // ==================== HELPER: GET MIME TYPE ====================
  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'application/octet-stream';
    }
  }
}