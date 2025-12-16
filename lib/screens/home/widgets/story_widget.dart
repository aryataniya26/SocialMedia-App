import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../story/story_viewer_screen.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStory(context);
          }
          return _buildStoryItem(context, index);
        },
      ),
    );
  }

  Widget _buildAddStory(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Create story
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: AppColors.textLight,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add Story',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context, int index) {
    final names = ['Erica Greens', 'Miles Smith', 'Jane Doe', 'John Smith', 'Sarah'];
    final images = [
      'https://i.pravatar.cc/150?img=${index + 1}',
      'https://i.pravatar.cc/150?img=${index + 10}',
      'https://i.pravatar.cc/150?img=${index + 20}',
      'https://i.pravatar.cc/150?img=${index + 30}',
      'https://i.pravatar.cc/150?img=${index + 40}',
    ];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryViewerScreen(
              userId: '${index + 1}',
              userName: names[index % names.length],
              userAvatar: images[index % images.length],
            ),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 3),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(
                    image: NetworkImage(images[index % images.length]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              names[index % names.length],
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
