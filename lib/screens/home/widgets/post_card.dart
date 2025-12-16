import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/app_colors.dart';
import '../../../data/models/post_model.dart';
import '../../../data/providers/post_provider.dart';
import '../../post/post_detail_screen.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.profilePic != null
                      ? CachedNetworkImageProvider(post.profilePic!)
                      : null,
                  backgroundColor: AppColors.cardBackground,
                  child: post.profilePic == null
                      ? const Icon(Icons.person, color: AppColors.textLight)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.fullName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      Text(
                        timeago.format(post.createdAt, locale: 'en_short'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showPostOptions(context);
                  },
                ),
              ],
            ),
          ),
          // Caption
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                post.caption,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 8),
          // Post Image - ADD TAP TO OPEN DETAILS
          if (post.mediaType == 'image')
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
                  ),
                );
              },
              child: CachedNetworkImage(
                imageUrl: post.mediaUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 400,
                  color: AppColors.cardBackground,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 400,
                  color: AppColors.cardBackground,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: () {
                    Provider.of<PostProvider>(context, listen: false)
                        .likePost(post.postId);
                  },
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: post.isLiked ? Colors.red : AppColors.textPrimary,
                        size: 26,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likesCount}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Comment Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.commentsCount}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Share Button
                GestureDetector(
                  onTap: () {
                    // TODO: Share post
                  },
                  child: const Icon(
                    Icons.share_outlined,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                const Spacer(),
                // Save Button
                GestureDetector(
                  onTap: () {
                    // TODO: Save post
                  },
                  child: const Icon(
                    Icons.bookmark_border,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copy Link'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: const Text('Report'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}