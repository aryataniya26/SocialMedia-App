import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FollowingScreen extends StatefulWidget {
  final String userId;

  const FollowingScreen({super.key, required this.userId});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final List<Map<String, dynamic>> _following = List.generate(
    40,
        (index) => {
      'id': '${index + 1}',
      'name': 'User ${index + 1}',
      'username': '@user${index + 1}',
      'avatar': 'https://i.pravatar.cc/150?img=${index + 10}',
    },
  );

  void _unfollow(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unfollow'),
          content: Text('Unfollow ${_following[index]['username']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _following.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unfollowed successfully')),
                );
              },
              child: const Text(
                'Unfollow',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Following',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search following...',
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
          // Following List
          Expanded(
            child: ListView.builder(
              itemCount: _following.length,
              itemBuilder: (context, index) {
                final user = _following[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(user['avatar']),
                  ),
                  title: Text(
                    user['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    user['username'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: SizedBox(
                    width: 100,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _unfollow(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardBackground,
                        foregroundColor: AppColors.textPrimary,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Following',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}