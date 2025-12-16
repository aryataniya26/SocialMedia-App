import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;

  const FollowersScreen({super.key, required this.userId});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final List<Map<String, dynamic>> _followers = List.generate(
    50,
        (index) => {
      'id': '${index + 1}',
      'name': 'User ${index + 1}',
      'username': '@user${index + 1}',
      'avatar': 'https://i.pravatar.cc/150?img=${index + 1}',
      'isFollowing': index % 3 == 0,
    },
  );

  void _toggleFollow(int index) {
    setState(() {
      _followers[index]['isFollowing'] = !_followers[index]['isFollowing'];
    });
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
          'Followers',
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
                hintText: 'Search followers...',
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
          // Followers List
          Expanded(
            child: ListView.builder(
              itemCount: _followers.length,
              itemBuilder: (context, index) {
                final follower = _followers[index];
                final isFollowing = follower['isFollowing'] as bool;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(follower['avatar']),
                  ),
                  title: Text(
                    follower['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    follower['username'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: SizedBox(
                    width: 100,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _toggleFollow(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing
                            ? AppColors.cardBackground
                            : AppColors.primary,
                        foregroundColor: isFollowing
                            ? AppColors.textPrimary
                            : Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      child: Text(
                        isFollowing ? 'Following' : 'Follow',
                        style: const TextStyle(fontSize: 12),
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