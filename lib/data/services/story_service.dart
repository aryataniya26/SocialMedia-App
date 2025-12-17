import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/story_model.dart';

class StoryService {
  final ApiService _api = ApiService();

  // ==================== UPLOAD STORY ====================
  Future<Map<String, dynamic>> uploadStory({
    required File mediaFile,
    String? caption,
    String? location,
    String visibility = 'public',
  }) async {
    try {
      print('📤 StoryService: Uploading story');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_buildUrl('api/v1/story/upload')),
      );

      // Add media file
      final fileStream = http.ByteStream(mediaFile.openRead());
      final length = await mediaFile.length();
      final multipartFile = http.MultipartFile(
        'media',
        fileStream,
        length,
        filename: 'story_${DateTime.now().millisecondsSinceEpoch}.${mediaFile.path.split('.').last}',
      );
      request.files.add(multipartFile);

      // Add other fields
      if (caption != null && caption.isNotEmpty) {
        request.fields['caption'] = caption;
      }
      if (location != null && location.isNotEmpty) {
        request.fields['location'] = location;
      }
      request.fields['visibility'] = visibility;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📤 Upload Story Response: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Upload Story Error: $e');
      return {
        'success': false,
        'message': 'Failed to upload story: ${e.toString()}',
      };
    }
  }

  // ==================== GET STORIES FEED ====================
  Future<List<StoryModel>> getStoriesFeed() async {
    try {
      print('📚 StoryService: Getting stories feed');

      // For testing - return dummy stories
      return _getDummyStories();
    } catch (e) {
      print('❌ Get Stories Feed Error: $e');
      return _getDummyStories();
    }
  }

  // ==================== GET USER STORIES ====================
  Future<List<StoryModel>> getUserStories(String userId) async {
    try {
      print('👤 StoryService: Getting stories for user $userId');

      // For testing - return empty list
      return [];
    } catch (e) {
      print('❌ Get User Stories Error: $e');
      return [];
    }
  }

  // ==================== DELETE STORY ====================
  Future<Map<String, dynamic>> deleteStory(String storyId) async {
    try {
      print('🗑️ StoryService: Deleting story $storyId');

      // For testing - simulate success
      await Future.delayed(const Duration(seconds: 1));

      return {
        'success': true,
        'message': 'Story deleted successfully',
      };
    } catch (e) {
      print('❌ Delete Story Error: $e');
      return {
        'success': false,
        'message': 'Failed to delete story: ${e.toString()}',
      };
    }
  }

  // ==================== MARK STORY AS VIEWED ====================
  Future<Map<String, dynamic>> markAsViewed(String storyId) async {
    try {
      print('👀 StoryService: Marking story $storyId as viewed');

      // For testing - simulate success
      await Future.delayed(const Duration(milliseconds: 500));

      return {
        'success': true,
        'message': 'Story marked as viewed',
      };
    } catch (e) {
      print('❌ Mark Story Viewed Error: $e');
      return {
        'success': false,
        'message': 'Failed to mark as viewed: ${e.toString()}',
      };
    }
  }

  // ==================== DUMMY STORIES FOR TESTING ====================
  List<StoryModel> _getDummyStories() {
    final now = DateTime.now();
    return [
      // Current user story (first - for adding new)
      StoryModel(
        id: 'current_user',
        userId: 'current_user',
        username: 'You',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        mediaUrl: null,
        mediaType: 'image',
        viewsCount: 0,
        isViewed: false,
        isExpired: false,
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
        visibility: 'public',
      ),
      // Friend stories
      StoryModel(
        id: '1',
        userId: 'user1',
        username: 'John',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        mediaUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
        mediaType: 'image',
        caption: 'Morning vibes ☕️',
        viewsCount: 124,
        isViewed: false,
        isExpired: false,
        createdAt: now.subtract(const Duration(hours: 2)),
        expiresAt: now.add(const Duration(hours: 22)),
        visibility: 'public',
      ),
      StoryModel(
        id: '2',
        userId: 'user2',
        username: 'Sarah',
        userAvatar: 'https://i.pravatar.cc/150?img=5',
        mediaUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba',
        mediaType: 'image',
        caption: 'Sunset views 🌅',
        viewsCount: 89,
        isViewed: true,
        isExpired: false,
        createdAt: now.subtract(const Duration(hours: 5)),
        expiresAt: now.add(const Duration(hours: 19)),
        visibility: 'public',
      ),
      StoryModel(
        id: '3',
        userId: 'user3',
        username: 'Mike',
        userAvatar: 'https://i.pravatar.cc/150?img=8',
        mediaUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b',
        mediaType: 'video',
        caption: 'New song alert! 🎵',
        viewsCount: 256,
        isViewed: false,
        isExpired: false,
        createdAt: now.subtract(const Duration(hours: 1)),
        expiresAt: now.add(const Duration(hours: 23)),
        visibility: 'public',
      ),
    ];
  }

  // ==================== HANDLE RESPONSE ====================
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final statusCode = response.statusCode;

      if (response.body.isEmpty) {
        if (statusCode >= 200 && statusCode < 300) {
          return {'success': true, 'message': 'Success'};
        } else {
          return {
            'success': false,
            'message': 'Request failed with status: $statusCode',
            'code': statusCode,
          };
        }
      }

      final body = json.decode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        return {'success': true, ...body};
      } else {
        return {
          'success': false,
          'message': body['message'] ?? body['error'] ?? 'Something went wrong',
          'code': statusCode,
        };
      }
    } catch (e) {
      print('❌ Response Parse Error: $e');
      return {
        'success': false,
        'message': 'Failed to parse response: ${e.toString()}',
      };
    }
  }

  // Helper method to build URL
  String _buildUrl(String endpoint) {
    final cleanEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    return 'https://your-api-base.com/$cleanEndpoint'; // Replace with your base URL
  }
}