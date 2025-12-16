import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'create_post_screen.dart';
import 'create_story_screen.dart';
import 'create_reel_screen.dart';
import 'go_live_screen.dart';

class CreateMenuScreen extends StatelessWidget {
  const CreateMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Create',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCreateOption(
              context,
              icon: Icons.photo_library_rounded,
              title: 'Create Post',
              description: 'Share photos and videos',
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCreateOption(
              context,
              icon: Icons.auto_awesome_rounded,
              title: 'Create Story',
              description: 'Share a moment that disappears in 24h',
              gradient: const LinearGradient(
                colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCreateOption(
              context,
              icon: Icons.video_library_rounded,
              title: 'Create Reel',
              description: 'Make a short entertaining video',
              gradient: const LinearGradient(
                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateReelScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCreateOption(
              context,
              icon: Icons.live_tv_rounded,
              title: 'Go Live',
              description: 'Stream live video to your followers',
              gradient: const LinearGradient(
                colors: [Color(0xFFFA709A), Color(0xFFFEE140)],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GoLiveScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required Gradient gradient,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}