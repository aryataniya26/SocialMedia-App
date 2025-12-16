import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';

class StoryViewerScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userAvatar;

  const StoryViewerScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final List<String> _storyImages = [
    'https://via.placeholder.com/400x800',
    'https://via.placeholder.com/400x800/FF5733',
    'https://via.placeholder.com/400x800/33FF57',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Story Content
          PageView.builder(
            controller: _pageController,
            itemCount: _storyImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: _storyImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          // Progress Indicator
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              children: List.generate(
                _storyImages.length,
                    (index) => Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: index <= _currentIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // User Info
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.userAvatar != null
                      ? CachedNetworkImageProvider(widget.userAvatar!)
                      : null,
                  backgroundColor: AppColors.cardBackground,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Reply Input
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: SafeArea(
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Reply to story...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}