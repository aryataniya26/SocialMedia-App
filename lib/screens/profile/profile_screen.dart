import 'package:clickme_app/screens/profile/saved_posts_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/auth_provider.dart';
import '../../config/routes.dart';
import 'edit_profile_screen.dart';
import 'followers_screen.dart';
import 'following_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: AppColors.textPrimary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
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
    return Column(
      children: [
        const SizedBox(height: 60),
        // Profile Picture
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            );
          },
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.cardBackground,
                  child: Icon(Icons.person, size: 50, color: AppColors.textLight),
                ),
              ),
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
        const Text(
          'Demo User',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '@demo_user',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        // Bio
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'This is a demo bio 🚀\nLiving my best life!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('89', 'Posts', () {}),
            _buildStatItem('1.2K', 'Followers', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FollowersScreen(userId: '1'),
                ),
              );
            }),
            _buildStatItem('567', 'Following', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FollowingScreen(userId: '1'),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 20),
        // Edit Profile Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardBackground,
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.share, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
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
  // Widget _buildSavedGrid() {
  //   return GridView.builder(
  //     padding: const EdgeInsets.all(2),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 3,
  //       mainAxisSpacing: 2,
  //       crossAxisSpacing: 2,
  //     ),
  //     itemCount: 15,
  //     itemBuilder: (context, index) {
  //       return Container(
  //         color: AppColors.cardBackground,
  //         child: const Center(
  //           child: Icon(
  //             Icons.bookmark,
  //             color: AppColors.textLight,
  //             size: 40,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
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
// import '../../config/routes.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
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
//               expandedHeight: 400,
//               flexibleSpace: FlexibleSpaceBar(
//                 background: _buildProfileHeader(),
//               ),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.settings, color: AppColors.textPrimary),
//                   onPressed: () {
//                     _showSettingsMenu(context);
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
//                     Tab(icon: Icon(Icons.grid_on)),
//                     Tab(icon: Icon(Icons.video_collection)),
//                     Tab(icon: Icon(Icons.bookmark_border)),
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
//     return Column(
//       children: [
//         const SizedBox(height: 60),
//         // Profile Picture
//         Stack(
//           children: [
//             Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: AppColors.primary, width: 3),
//               ),
//               child: const CircleAvatar(
//                 radius: 48,
//                 backgroundColor: AppColors.cardBackground,
//                 child: Icon(Icons.person, size: 50, color: AppColors.textLight),
//               ),
//             ),
//             Positioned(
//               bottom: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: const BoxDecoration(
//                   color: AppColors.primary,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.edit, color: Colors.white, size: 16),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         // Name & Username
//         const Text(
//           'Demo User',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const Text(
//           '@demo_user',
//           style: TextStyle(
//             fontSize: 14,
//             color: AppColors.textSecondary,
//           ),
//         ),
//         const SizedBox(height: 16),
//         // Bio
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 32),
//           child: Text(
//             'This is a demo bio 🚀\nLiving my best life!',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14,
//               color: AppColors.textPrimary,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         // Stats
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildStatItem('89', 'Posts'),
//             _buildStatItem('1.2K', 'Followers'),
//             _buildStatItem('567', 'Following'),
//           ],
//         ),
//         const SizedBox(height: 20),
//         // Edit Profile Button
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32),
//           child: Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // TODO: Navigate to edit profile
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                   ),
//                   child: const Text('Edit Profile'),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.cardBackground,
//                 ),
//                 child: const Icon(Icons.share, color: AppColors.textPrimary),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatItem(String count, String label) {
//     return Column(
//       children: [
//         Text(
//           count,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             color: AppColors.textSecondary,
//           ),
//         ),
//       ],
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
//           child: Center(
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
//         return Container(
//           color: AppColors.cardBackground,
//           child: const Center(
//             child: Icon(
//               Icons.bookmark,
//               color: AppColors.textLight,
//               size: 40,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showSettingsMenu(BuildContext context) {
//     showModalBottomSheet(
//         context: context,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (context) {
//           return Container(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//               ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text('Settings'),
//               onTap: () {
//                 Navigator.pop(context);
// // TODO: Navigate to settings
//               },
//               ),
//                     ListTile(
//                       leading: const Icon(Icons.privacy_tip_outlined),
//                       title: const Text('Privacy'),
//                       onTap: () => Navigator.pop(context),
//                     ),
//                     ListTile(
//                       leading: const Icon(Icons.help_outline),
//                       title: const Text('Help'),
//                       onTap: () => Navigator.pop(context),
//                     ),
//                     const Divider(),
//                     ListTile(
//                       leading: const Icon(Icons.logout, color: Colors.red),
//                       title: const Text('Logout', style: TextStyle(color: Colors.red)),
//                       onTap: () async {
//                         Navigator.pop(context);
//                         await Provider.of<AuthProvider>(context, listen: false).logout();
//                         if (context.mounted) {
//                           Navigator.pushReplacementNamed(context, AppRoutes.login);
//                         }
//                       },
//                     ),
//                   ],
//               ),
//           );
//         },
//     );
//   }
// }
// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar _tabBar;
//   _SliverAppBarDelegate(this._tabBar);
//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: Colors.white,
//       child: _tabBar,
//     );
//   }
//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }
