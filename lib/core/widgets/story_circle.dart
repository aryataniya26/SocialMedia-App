import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/story_model.dart';

class StoryCircle extends StatelessWidget {
  final StoryModel story;
  final bool isCurrentUser;
  final double size;
  final VoidCallback onTap;

  const StoryCircle({
    super.key,
    required this.story,
    this.isCurrentUser = false,
    this.size = 68,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Story Circle
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isCurrentUser
                  ? const LinearGradient(
                colors: [Colors.grey, Colors.grey],
              )
                  : story.isViewed
                  ? const LinearGradient(
                colors: [Color(0xFFDBDBDB), Color(0xFFDBDBDB)],
              )
                  : const LinearGradient(
                colors: [
                  Color(0xFF833AB4),
                  Color(0xFFFD1D1D),
                  Color(0xFFF77737),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: CircleAvatar(
                radius: (size - 10) / 2,
                backgroundColor: AppColors.cardBackground,
                backgroundImage: _getBackgroundImage(),
                child: _getChild(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Username
          SizedBox(
            width: size,
            child: Text(
              isCurrentUser ? 'Your Story' : story.username,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (isCurrentUser) {
      return null;
    }

    if (story.userAvatar != null && story.userAvatar!.isNotEmpty) {
      return CachedNetworkImageProvider(story.userAvatar!);
    }

    return null;
  }

  Widget? _getChild() {
    if (isCurrentUser) {
      return const Icon(
        Icons.add,
        color: Colors.black,
        size: 24,
      );
    }

    if (story.userAvatar == null || story.userAvatar!.isEmpty) {
      return Text(
        story.username[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }

    return null;
  }
}