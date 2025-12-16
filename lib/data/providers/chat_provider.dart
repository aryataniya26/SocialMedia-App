import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/chat_model.dart';
import '../../core/constants/api_endpoints.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ChatThreadModel> _threads = [];
  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;

  List<ChatThreadModel> get threads => _threads;
  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  // Fetch Chat Threads
  Future<void> fetchThreads() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/chat/threads',
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final List threadsJson = data['threads'] ?? [];

        _threads = threadsJson
            .map((json) => ChatThreadModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching threads: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch Messages for Thread
  Future<void> fetchMessages(String threadId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/chat/messages/$threadId',
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final List messagesJson = data['messages'] ?? [];

        _messages = messagesJson
            .map((json) => ChatMessageModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Send Message
  Future<bool> sendMessage(String threadId, String message) async {
    try {
      final response = await _apiService.post(
        '/chat/message/send/$threadId',
        body: {
          'message': message,
          'type': 'text',
        },
        requiresAuth: true,
      );

      if (response['success'] == true) {
        // Add message to local list
        final newMessage = ChatMessageModel.fromJson(response['data']);
        _messages.add(newMessage);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }
}