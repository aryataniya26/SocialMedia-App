import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/follow_provider.dart';
import '../../data/providers/user_provider.dart';
import 'edit_profile_screen.dart';
import 'followers_screen.dart';
import 'following_screen.dart';
import 'settings_screen.dart';
import 'saved_posts_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // Optional: if viewing other user's profile

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOwnProfile = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData();
  }

  void _loadProfileData() {
    final authProvider = context.read<AuthProvider>();
    final followProvider = context.read<FollowProvider>();

    // Check if viewing own profile or another user's profile
    _isOwnProfile = widget.userId == null ||
        widget.userId == authProvider.currentUser?.id;

    // Load follow counts for own profile
    if (_isOwnProfile) {
      Future.microtask(() {
        followProvider.getFollowStats(); // ✅ Changed to getFollowStats
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              expandedHeight: 420,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(),
              ),
              actions: _isOwnProfile
                  ? [
                IconButton(
                  icon: const Icon(Icons.settings, color: AppColors.textPrimary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ]
                  : [],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on, size: 26)),
                    Tab(icon: Icon(Icons.video_collection, size: 26)),
                    Tab(icon: Icon(Icons.bookmark_border, size: 26)),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsGrid(),
            _buildReelsGrid(),
            _buildSavedGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer3<AuthProvider, FollowProvider, UserProvider>(
      builder: (context, authProvider, followProvider, userProvider, child) {
        final user = authProvider.currentUser;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            const SizedBox(height: 60),
            // Profile Picture
            GestureDetector(
              onTap: _isOwnProfile
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              }
                  : null,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.cardBackground,
                      backgroundImage: user.profileImage != null
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child: user.profileImage == null
                          ? Text(
                        user.firstName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                          : null,
                    ),
                  ),
                  if (_isOwnProfile)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Name & Username
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@${user.email?.split('@').first ?? user.firstName.toLowerCase()}',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // Bio
            if (user.bio != null && user.bio!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  user.bio!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Stats with Real Data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('0', 'Posts', () {}), // TODO: Add posts count
                _buildStatItem(
                  followProvider.followersCount.toString(),
                  'Followers',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FollowersScreen(userId: user.id),
                      ),
                    );
                  },
                ),
                _buildStatItem(
                  followProvider.followingCount.toString(),
                  'Following',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FollowingScreen(userId: user.id),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Edit Profile Button or Follow Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _isOwnProfile
                  ? _buildOwnProfileButtons()
                  : _buildOtherProfileButtons(user.id, followProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOwnProfileButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Edit Profile'),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            // TODO: Share profile functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cardBackground,
            padding: const EdgeInsets.all(12),
          ),
          child: const Icon(Icons.share, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildOtherProfileButtons(String currentUserId, FollowProvider followProvider) {
    // For now, show a simple follow button
    bool isFollowing = false; // You'll get this from API later

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              if (isFollowing) {
                // Unfollow
                await _handleUnfollow(followProvider, currentUserId);
              } else {
                // Follow
                await _handleFollow(followProvider, currentUserId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing ? AppColors.cardBackground : AppColors.primary,
              foregroundColor: isFollowing ? AppColors.textPrimary : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(isFollowing ? 'Following' : 'Follow'),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            // TODO: Message functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cardBackground,
            padding: const EdgeInsets.all(12),
          ),
          child: const Icon(Icons.message, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Future<void> _handleFollow(FollowProvider followProvider, String targetUserId) async {
    try {
      final result = await followProvider.sendFollowRequest(targetUserId);

      if (mounted && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Follow request sent'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh follow counts
        followProvider.getFollowStats();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to follow'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleUnfollow(FollowProvider followProvider, String targetUserId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unfollow'),
        content: const Text('Are you sure you want to unfollow this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Unfollow'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final result = await followProvider.unfollowUser(targetUserId);

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unfollowed successfully'),
              backgroundColor: Colors.grey,
            ),
          );

          // Refresh follow counts
          followProvider.getFollowStats();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to unfollow'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatItem(String count, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        return Container(
          color: AppColors.cardBackground,
          child: const Center(
            child: Icon(
              Icons.image,
              color: AppColors.textLight,
              size: 40,
            ),
          ),
        );
      },
    );
  }

  Widget _buildReelsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 0.6,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Container(
          color: AppColors.cardBackground,
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: AppColors.textLight,
              size: 40,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SavedPostsScreen(),
              ),
            );
          },
          child: Container(
            color: AppColors.cardBackground,
            child: const Center(
              child: Icon(
                Icons.bookmark,
                color: AppColors.textLight,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../data/providers/auth_provider.dart';
// import '../../data/providers/follow_provider.dart';
// import '../../data/providers/user_provider.dart';
// import '../../config/routes.dart';
// import 'edit_profile_screen.dart';
// import 'followers_screen.dart';
// import 'following_screen.dart';
// import 'settings_screen.dart';
// import 'saved_posts_screen.dart';
//
// class ProfileScreen extends StatefulWidget {
//   final String? userId; // Optional: if viewing other user's profile
//
//   const ProfileScreen({super.key, this.userId});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _isOwnProfile = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _loadProfileData();
//   }
//
//   void _loadProfileData() {
//     final authProvider = context.read<AuthProvider>();
//     final followProvider = context.read<FollowProvider>();
//
//     // Check if viewing own profile or another user's profile
//     _isOwnProfile = widget.userId == null ||
//         widget.userId == authProvider.currentUser?.id;
//
//     // Load follow counts for own profile
//     if (_isOwnProfile) {
//       Future.microtask(() {
//         followProvider.fetchFollowCounts();
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: NestedScrollView(
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return [
//             SliverAppBar(
//               backgroundColor: Colors.white,
//               elevation: 0,
//               pinned: true,
//               expandedHeight: 420,
//               flexibleSpace: FlexibleSpaceBar(
//                 background: _buildProfileHeader(),
//               ),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.settings, color: AppColors.textPrimary),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SettingsScreen()),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             SliverPersistentHeader(
//               pinned: true,
//               delegate: _SliverAppBarDelegate(
//                 TabBar(
//                   controller: _tabController,
//                   labelColor: AppColors.primary,
//                   unselectedLabelColor: AppColors.textSecondary,
//                   indicatorColor: AppColors.primary,
//                   tabs: const [
//                     Tab(icon: Icon(Icons.grid_on, size: 26)),
//                     Tab(icon: Icon(Icons.video_collection, size: 26)),
//                     Tab(icon: Icon(Icons.bookmark_border, size: 26)),
//                   ],
//                 ),
//               ),
//             ),
//           ];
//         },
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             _buildPostsGrid(),
//             _buildReelsGrid(),
//             _buildSavedGrid(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileHeader() {
//     return Consumer3<AuthProvider, FollowProvider, UserProvider>(
//       builder: (context, authProvider, followProvider, userProvider, child) {
//         final user = authProvider.currentUser;
//
//         if (user == null) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         return Column(
//           children: [
//             const SizedBox(height: 60),
//             // Profile Picture
//             GestureDetector(
//               onTap: _isOwnProfile ? () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const EditProfileScreen()),
//                 );
//               } : null,
//               child: Stack(
//                 children: [
//                   Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: AppColors.primary, width: 3),
//                     ),
//                     child: CircleAvatar(
//                       radius: 48,
//                       backgroundColor: AppColors.cardBackground,
//                       backgroundImage: user.profileImage != null
//                           ? NetworkImage(user.profileImage!)
//                           : null,
//                       child: user.profileImage == null
//                           ? Text(
//                         user.firstName[0].toUpperCase(),
//                         style: const TextStyle(
//                           fontSize: 40,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       )
//                           : null,
//                     ),
//                   ),
//                   if (_isOwnProfile)
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: const BoxDecoration(
//                           color: AppColors.primary,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(Icons.edit, color: Colors.white, size: 16),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Name & Username
//             Text(
//               user.fullName,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '@${user.email?.split('@').first ?? user.firstName.toLowerCase()}',
//               style: const TextStyle(
//                 fontSize: 15,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Bio
//             if (user.bio != null && user.bio!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 32),
//                 child: Text(
//                   user.bio!,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 20),
//             // Stats with Real Data
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildStatItem('0', 'Posts', () {}), // TODO: Add posts count
//                 _buildStatItem(
//                   followProvider.followersCount.toString(),
//                   'Followers',
//                       () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => FollowersScreen(userId: user.id),
//                       ),
//                     );
//                   },
//                 ),
//                 _buildStatItem(
//                   followProvider.followingCount.toString(),
//                   'Following',
//                       () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => FollowingScreen(userId: user.id),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             // Edit Profile Button or Follow Button
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: _isOwnProfile
//                   ? _buildOwnProfileButtons()
//                   : _buildOtherProfileButtons(),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildOwnProfileButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const EditProfileScreen()),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//             child: const Text('Edit Profile'),
//           ),
//         ),
//         const SizedBox(width: 12),
//         ElevatedButton(
//           onPressed: () {
//             // TODO: Share profile functionality
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.cardBackground,
//             padding: const EdgeInsets.all(12),
//           ),
//           child: const Icon(Icons.share, color: AppColors.textPrimary),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOtherProfileButtons() {
//     return Consumer<FollowProvider>(
//       builder: (context, followProvider, child) {
//         final status = followProvider.getFollowStatus(widget.userId!);
//
//         return Row(
//           children: [
//             Expanded(
//               child: _buildFollowButton(status, followProvider),
//             ),
//             const SizedBox(width: 12),
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Message functionality
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.cardBackground,
//                 padding: const EdgeInsets.all(12),
//               ),
//               child: const Icon(Icons.message, color: AppColors.textPrimary),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildFollowButton(String status, FollowProvider followProvider) {
//     Color backgroundColor;
//     String buttonText;
//     VoidCallback? onPressed;
//
//     switch (status) {
//       case 'following':
//         backgroundColor = AppColors.cardBackground;
//         buttonText = 'Following';
//         onPressed = () => _handleUnfollow(followProvider);
//         break;
//       case 'pending':
//         backgroundColor = AppColors.cardBackground;
//         buttonText = 'Requested';
//         onPressed = null;
//         break;
//       default:
//         backgroundColor = AppColors.primary;
//         buttonText = 'Follow';
//         onPressed = () => _handleFollow(followProvider);
//     }
//
//     return ElevatedButton(
//       onPressed: followProvider.isLoading ? null : onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: backgroundColor,
//         foregroundColor: status == 'following' || status == 'pending'
//             ? AppColors.textPrimary
//             : Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 12),
//       ),
//       child: followProvider.isLoading
//           ? const SizedBox(
//         height: 20,
//         width: 20,
//         child: CircularProgressIndicator(strokeWidth: 2),
//       )
//           : Text(buttonText),
//     );
//   }
//
//   void _handleFollow(FollowProvider followProvider) async {
//     final success = await followProvider.sendFollowRequest(widget.userId!);
//
//     if (success && mounted) {
//       final status = followProvider.getFollowStatus(widget.userId!);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             status == 'following' ? 'Now following user' : 'Follow request sent',
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }
//
//   void _handleUnfollow(FollowProvider followProvider) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Unfollow'),
//         content: const Text('Are you sure you want to unfollow this user?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Unfollow'),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm == true) {
//       final success = await followProvider.unfollowUser(widget.userId!);
//       if (success && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Unfollowed successfully'),
//             backgroundColor: Colors.grey,
//           ),
//         );
//       }
//     }
//   }
//
//   Widget _buildStatItem(String count, String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Text(
//             count,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPostsGrid() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(2),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 2,
//         crossAxisSpacing: 2,
//       ),
//       itemCount: 30,
//       itemBuilder: (context, index) {
//         return Container(
//           color: AppColors.cardBackground,
//           child: const Center(
//             child: Icon(
//               Icons.image,
//               color: AppColors.textLight,
//               size: 40,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildReelsGrid() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(2),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 2,
//         crossAxisSpacing: 2,
//         childAspectRatio: 0.6,
//       ),
//       itemCount: 20,
//       itemBuilder: (context, index) {
//         return Container(
//           color: AppColors.cardBackground,
//           child: const Center(
//             child: Icon(
//               Icons.play_circle_outline,
//               color: AppColors.textLight,
//               size: 40,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSavedGrid() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(2),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 2,
//         crossAxisSpacing: 2,
//       ),
//       itemCount: 15,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const SavedPostsScreen(),
//               ),
//             );
//           },
//           child: Container(
//             color: AppColors.cardBackground,
//             child: const Center(
//               child: Icon(
//                 Icons.bookmark,
//                 color: AppColors.textLight,
//                 size: 40,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar _tabBar;
//
//   _SliverAppBarDelegate(this._tabBar);
//
//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;
//
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: Colors.white,
//       child: _tabBar,
//     );
//   }
//
//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }
