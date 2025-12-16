import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = List.generate(
    20,
        (index) => {
      'id': index,
      'user': 'User ${index + 1}',
      'type': ['like', 'comment', 'follow', 'mention'][index % 4],
      'message': _getMessage(index),
      'time': DateTime.now().subtract(Duration(hours: index)),
      'isRead': index % 3 == 0,
      'avatar': 'https://i.pravatar.cc/150?img=${index + 1}',
    },
  );

  static String _getMessage(int index) {
    final types = ['like', 'comment', 'follow', 'mention'];
    final type = types[index % 4];

    switch (type) {
      case 'like':
        return 'liked your post';
      case 'comment':
        return 'commented on your post';
      case 'follow':
        return 'started following you';
      case 'mention':
        return 'mentioned you in a post';
      default:
        return '';
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'follow':
        return Icons.person_add;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'follow':
        return AppColors.primary;
      case 'mention':
        return Colors.orange;
      default:
        return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification['isRead'] = true;
                }
              });
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          final isRead = notification['isRead'] as bool;

          return Container(
            color: isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(notification['avatar']),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getIconColor(notification['type']),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _getIcon(notification['type']),
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              title: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: '${notification['user']} ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: notification['message']),
                  ],
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  timeago.format(notification['time'], locale: 'en_short'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              trailing: notification['type'] == 'follow'
                  ? SizedBox(
                width: 100,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              )
                  : null,
              onTap: () {
                setState(() {
                  notification['isRead'] = true;
                });
              },
            ),
          );
        },
      ),
    );
  }
}