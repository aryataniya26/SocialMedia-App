// lib/data/services/chat_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_endpoints.dart';
import 'storage_service.dart';

class ChatService {
  // ==================== GET CHAT THREADS ====================
  Future<Map<String, dynamic>> getChatThreads() async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl(ApiEndpoints.chatThreads),
      );

      debugPrint('🔵 Getting chat threads: $url');

      final response = await http.get(
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
          'data': data['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get chat threads',
        };
      }
    } catch (e) {
      debugPrint('❌ Get chat threads error: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'data': [],
      };
    }
  }

  // ==================== GET CHAT MESSAGES ====================
  Future<Map<String, dynamic>> getChatMessages(String threadId) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl(ApiEndpoints.chatMessages(threadId)),
      );

      debugPrint('🔵 Getting messages for thread: $threadId');

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
          'data': data['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get messages',
        };
      }
    } catch (e) {
      debugPrint('❌ Get messages error: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'data': [],
      };
    }
  }

  // ==================== SEND MESSAGE ====================
  Future<Map<String, dynamic>> sendMessage({
    required String threadId,
    required String message,
    File? attachment,
  }) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl(ApiEndpoints.sendMessage(threadId)),
      );

      debugPrint('🔵 Sending message to thread: $threadId');

      Map<String, dynamic> body = {'message': message};

      // If there's an attachment, use multipart request
      if (attachment != null) {
        final request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['message'] = message;

        request.files.add(
          await http.MultipartFile.fromPath(
            'attachment',
            attachment.path,
          ),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = json.decode(response.body);
          return {
            'success': true,
            'data': data['data'],
          };
        }
      } else {
        // Regular JSON request
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(body),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = json.decode(response.body);
          return {
            'success': true,
            'data': data['data'],
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to send message',
      };
    } catch (e) {
      debugPrint('❌ Send message error: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ==================== DELETE MESSAGE ====================
  Future<Map<String, dynamic>> deleteMessage(String messageId) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl('api/v1/chat/message/$messageId'),
      );

      debugPrint('🔵 Deleting message: $messageId');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Message deleted'};
      }

      return {'success': false, 'message': 'Failed to delete message'};
    } catch (e) {
      debugPrint('❌ Delete message error: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // ==================== MARK MESSAGES AS SEEN ====================
  Future<Map<String, dynamic>> markAsSeen(String threadId) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl('api/v1/chat/messages/seen/$threadId'),
      );

      debugPrint('🔵 Marking messages as seen: $threadId');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true};
      }

      return {'success': false};
    } catch (e) {
      debugPrint('❌ Mark as seen error: $e');
      return {'success': false};
    }
  }

  // ==================== START NEW CHAT ====================
  Future<Map<String, dynamic>> startChat(String userId) async {
    try {
      final token = StorageService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(
        ApiEndpoints.getFullUrl('api/v1/chat/start/$userId'),
      );

      debugPrint('🔵 Starting new chat with: $userId');

      final response = await http.post(
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
      }

      return {'success': false, 'message': 'Failed to start chat'};
    } catch (e) {
      debugPrint('❌ Start chat error: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}