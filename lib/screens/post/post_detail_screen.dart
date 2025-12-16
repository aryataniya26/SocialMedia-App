import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/app_colors.dart';
import '../../data/models/post_model.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadComments() {
    // TODO: Load from API
    setState(() {
      _comments.addAll(
        List.generate(
          10,
              (index) => {
            'id': '${index + 1}',
            'user': 'User ${index + 1}',
            'avatar': 'https://i.pravatar.cc/150?img=${index + 1}',
            'comment': 'This is comment ${index + 1}',
            'time': DateTime.now().subtract(Duration(hours: index)),
          },
        ),
      );
    });
  }

  void _postComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.insert(0, {
        'id': '${_comments.length + 1}',
        'user': 'You',
        'avatar': 'https://i.pravatar.cc/150?img=1',
        'comment': _commentController.text.trim(),
        'time': DateTime.now(),
      });
    });

    _commentController.clear();
    FocusScope.of(context).unfocus();
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
          'Post',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Post Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: widget.post.profilePic != null
                              ? CachedNetworkImageProvider(widget.post.profilePic!)
                              : null,
                          backgroundColor: AppColors.cardBackground,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.fullName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                timeago.format(widget.post.createdAt),
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
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // Caption
                  if (widget.post.caption.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.post.caption,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Post Image
                  if (widget.post.mediaType == 'image')
                    CachedNetworkImage(
                      imageUrl: widget.post.mediaUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  // Actions
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          widget.post.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.post.isLiked
                              ? Colors.red
                              : AppColors.textPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text('${widget.post.likesCount}'),
                        const SizedBox(width: 24),
                        const Icon(Icons.chat_bubble_outline),
                        const SizedBox(width: 6),
                        Text('${widget.post.commentsCount}'),
                        const Spacer(),
                        const Icon(Icons.share_outlined),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Comments Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Comments (${_comments.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(comment['avatar']),
                        ),
                        title: Text(
                          comment['user'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment['comment'],
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeago.format(comment['time']),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Comment Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _postComment,
                    icon: const Icon(
                      Icons.send,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}