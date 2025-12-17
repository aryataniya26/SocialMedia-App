import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/post_provider.dart';
import '../search/search_screen.dart';
import '../chat/chat_list_screen.dart';
import '../notifications/notifications_screen.dart';
import 'widgets/story_widget.dart';
import 'widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFeed();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadFeed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchHomeFeed(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      if (!postProvider.isLoading && postProvider.hasMore) {
        postProvider.fetchHomeFeed();
      }
    }
  }

  Future<void> _onRefresh() async {
    await Provider.of<PostProvider>(context, listen: false)
        .fetchHomeFeed(refresh: true);
  }

  void _openSearch() {
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _openMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatListScreen()),
    );
  }

  void _showMenu() {
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
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
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
        toolbarHeight: 60,
        title: Row(
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'click',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'ME',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
        actions: [
          // Notifications Icon
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
              color: AppColors.textPrimary,
              size: 26,
            ),
            onPressed: _openNotifications,
          ),
          // Messages Icon
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.textPrimary,
              size: 26,
            ),
            onPressed: _openMessages,
          ),
          // Menu Icon
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: AppColors.textPrimary,
              size: 26,
            ),
            onPressed: _showMenu,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.searchBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(width: 12),
                      Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Search your vibe',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Stories
            const SliverToBoxAdapter(
              child: StoryWidget(),
            ),
            // Posts
            Consumer<PostProvider>(
              builder: (context, postProvider, _) {
                if (postProvider.posts.isEmpty && postProvider.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (postProvider.posts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No posts yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index < postProvider.posts.length) {
                        return PostCard(post: postProvider.posts[index]);
                      } else if (postProvider.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                    childCount: postProvider.posts.length +
                        (postProvider.hasMore ? 1 : 0),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../data/providers/post_provider.dart';
// import '../search/search_screen.dart';
// import '../chat/chat_list_screen.dart';
// import '../notifications/notifications_screen.dart';
// import 'widgets/story_widget.dart';
// import 'widgets/post_card.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFeed();
//     _scrollController.addListener(_onScroll);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _loadFeed() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<PostProvider>(context, listen: false).fetchHomeFeed(refresh: true);
//     });
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       final postProvider = Provider.of<PostProvider>(context, listen: false);
//       if (!postProvider.isLoading && postProvider.hasMore) {
//         postProvider.fetchHomeFeed();
//       }
//     }
//   }
//
//   Future<void> _onRefresh() async {
//     await Provider.of<PostProvider>(context, listen: false)
//         .fetchHomeFeed(refresh: true);
//   }
//
//   void _openSearch() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const SearchScreen()),
//     );
//   }
//
//   void _openNotifications() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const NotificationsScreen()),
//     );
//   }
//
//   void _openMessages() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const ChatListScreen()),
//     );
//   }
//
//   void _showMenu() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.settings),
//                 title: const Text('Settings'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Navigate to settings
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.info_outline),
//                 title: const Text('About'),
//                 onTap: () => Navigator.pop(context),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.help_outline),
//                 title: const Text('Help'),
//                 onTap: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         toolbarHeight: 60,
//         title: Row(
//           children: [
//             RichText(
//               text: const TextSpan(
//                 children: [
//                   TextSpan(
//                     text: 'click',
//                     style: TextStyle(
//                       color: AppColors.primary,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                   TextSpan(
//                     text: 'ME',
//                     style: TextStyle(
//                       color: AppColors.secondary,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 6),
//             const Icon(
//               Icons.keyboard_arrow_down,
//               color: AppColors.primary,
//               size: 24,
//             ),
//           ],
//         ),
//         actions: [
//           // Notifications Icon
//           IconButton(
//             icon: const Icon(
//               Icons.favorite_border,
//               color: AppColors.textPrimary,
//               size: 26,
//             ),
//             onPressed: _openNotifications,
//           ),
//           // Messages Icon
//           IconButton(
//             icon: const Icon(
//               Icons.chat_bubble_outline,
//               color: AppColors.textPrimary,
//               size: 26,
//             ),
//             onPressed: _openMessages,
//           ),
//           // Menu Icon
//           IconButton(
//             icon: const Icon(
//               Icons.menu,
//               color: AppColors.textPrimary,
//               size: 26,
//             ),
//             onPressed: _showMenu,
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _onRefresh,
//         color: AppColors.primary,
//         child: CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             // Search Bar (WORKING)
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//                 child: GestureDetector(
//                   onTap: _openSearch,
//                   child: Container(
//                     height: 44,
//                     decoration: BoxDecoration(
//                       color: AppColors.searchBackground,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: const [
//                         SizedBox(width: 12),
//                         Icon(
//                           Icons.search,
//                           color: Color(0xFF9CA3AF),
//                           size: 22,
//                         ),
//                         SizedBox(width: 12),
//                         Text(
//                           'Search your vibe',
//                           style: TextStyle(
//                             color: Color(0xFF9CA3AF),
//                             fontSize: 15,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             // Stories
//             const SliverToBoxAdapter(
//               child: StoryWidget(),
//             ),
//             // Posts
//             Consumer<PostProvider>(
//               builder: (context, postProvider, _) {
//                 if (postProvider.posts.isEmpty && postProvider.isLoading) {
//                   return const SliverFillRemaining(
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   );
//                 }
//
//                 if (postProvider.posts.isEmpty) {
//                   return const SliverFillRemaining(
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.photo_library_outlined,
//                             size: 64,
//                             color: AppColors.textLight,
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'No posts yet',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: AppColors.textSecondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }
//
//                 return SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                       if (index < postProvider.posts.length) {
//                         return PostCard(post: postProvider.posts[index]);
//                       } else if (postProvider.hasMore) {
//                         return const Padding(
//                           padding: EdgeInsets.all(16),
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               color: AppColors.primary,
//                             ),
//                           ),
//                         );
//                       } else {
//                         return const SizedBox();
//                       }
//                     },
//                     childCount: postProvider.posts.length +
//                         (postProvider.hasMore ? 1 : 0),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
