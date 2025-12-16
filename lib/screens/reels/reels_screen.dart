import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/reel_provider.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadReels() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReelProvider>(context, listen: false).fetchReels(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ReelProvider>(
        builder: (context, reelProvider, _) {
          if (reelProvider.reels.isEmpty && reelProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (reelProvider.reels.isEmpty) {
            return const Center(
              child: Text(
                'No reels yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reelProvider.reels.length,
            itemBuilder: (context, index) {
              final reel = reelProvider.reels[index];

              return Stack(
                children: [
                  // Video Placeholder
                  Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // User Info & Actions
                  Positioned(
                    bottom: 80,
                    left: 16,
                    right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: reel.profilePic != null
                                  ? NetworkImage(reel.profilePic!)
                                  : null,
                              backgroundColor: AppColors.cardBackground,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              reel.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                              ),
                              child: const Text(
                                'Follow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          reel.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Action Buttons
                  Positioned(
                    bottom: 80,
                    right: 16,
                    child: Column(
                      children: [
                        // Like
                        IconButton(
                          onPressed: () {
                            reelProvider.likeReel(reel.reelId);
                          },
                          icon: Icon(
                            reel.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: reel.isLiked ? Colors.red : Colors.white,
                            size: 32,
                          ),
                        ),
                        Text(
                          '${reel.likesCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Comment
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        Text(
                          '${reel.commentsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Share
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // More
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}