import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/app_colors.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<Map<String, dynamic>> _chats = List.generate(
    30,
        (index) => {
      'id': '${index + 1}',
      'name': 'User ${index + 1}',
      'avatar': 'https://i.pravatar.cc/150?img=${index + 1}',
      'lastMessage': _getLastMessage(index),
      'time': DateTime.now().subtract(Duration(hours: index)),
      'unreadCount': index % 5 == 0 ? index % 10 : 0,
      'isOnline': index % 3 == 0,
    },
  );

  static String _getLastMessage(int index) {
    final messages = [
      'Hey! How are you?',
      'That sounds great!',
      'See you tomorrow 👋',
      'Thanks for sharing!',
      'LOL 😂',
      'Let\'s catch up soon',
      'Awesome! 🎉',
      'Got it, thanks!',
      'What time works for you?',
      'Perfect! 👍',
    ];
    return messages[index % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Chats List
          Expanded(
            child: ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                final unreadCount = chat['unreadCount'] as int;
                final isOnline = chat['isOnline'] as bool;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(chat['avatar']),
                      ),
                      if (isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    chat['name'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    chat['lastMessage'],
                    style: TextStyle(
                      fontSize: 13,
                      color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeago.format(chat['time'], locale: 'en_short'),
                        style: TextStyle(
                          fontSize: 12,
                          color: unreadCount > 0 ? AppColors.primary : AppColors.textLight,
                          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Center(
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          userId: chat['id'],
                          userName: chat['name'],
                          userAvatar: chat['avatar'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}