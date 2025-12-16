import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/notification_model.dart';
import '../../core/constants/api_endpoints.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  // Fetch Notifications
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiEndpoints.notificationsList,
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final List notificationsJson = data['notifications'] ?? [];

        _notifications = notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        _unreadCount = _notifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mark as Read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.put(
        '/notifications/read/$notificationId',
        requiresAuth: true,
      );

      final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          notificationId: _notifications[index].notificationId,
          receiverId: _notifications[index].receiverId,
          senderId: _notifications[index].senderId,
          senderName: _notifications[index].senderName,
          senderAvatar: _notifications[index].senderAvatar,
          postId: _notifications[index].postId,
          reelId: _notifications[index].reelId,
          type: _notifications[index].type,
          message: _notifications[index].message,
          createdAt: _notifications[index].createdAt,
          isRead: true,
        );
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  // Mark All as Read
  Future<void> markAllAsRead() async {
    try {
      await _apiService.put(
        ApiEndpoints.readAll,
        requiresAuth: true,
      );

      _notifications = _notifications.map((n) {
        return NotificationModel(
          notificationId: n.notificationId,
          receiverId: n.receiverId,
          senderId: n.senderId,
          senderName: n.senderName,
          senderAvatar: n.senderAvatar,
          postId: n.postId,
          reelId: n.reelId,
          type: n.type,
          message: n.message,
          createdAt: n.createdAt,
          isRead: true,
        );
      }).toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }
}