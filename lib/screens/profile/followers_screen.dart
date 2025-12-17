import 'package:clickme_app/screens/home/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/follow_provider.dart';
import '../../data/models/user_model.dart';
import '../../core/widgets/loading_widget.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;
  final String? title;

  const FollowersScreen({
    Key? key,
    required this.userId,
    this.title,
  }) : super(key: key);

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final List<UserModel> _followers = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    final followProvider = Provider.of<FollowProvider>(context, listen: false);
    final newFollowers = await followProvider.getFollowers(
      widget.userId,
      refresh: _page == 1,
    );

    setState(() {
      if (_page == 1) {
        _followers.clear();
      }
      _followers.addAll(newFollowers);
      _hasMore = newFollowers.length == _limit;
      _isLoading = false;
      _page++;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _hasMore = true;
    });
    await _loadFollowers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Followers'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search followers...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20,
                  ),
                ),
              ),
            ),

            // Followers Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_followers.length} followers',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Followers List
            Expanded(
              child: _followers.isEmpty && !_isLoading
                  ? const Center(
                child: Text(
                  'No followers yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _followers.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _followers.length) {
                    if (_hasMore) {
                      _loadFollowers();
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: LoadingWidget()),
                      );
                    }
                    return const SizedBox();
                  }

                  final follower = _followers[index];
                  return UserCard(
                    user: follower,
                    onTap: () {
                      // Navigate to user profile
                      // Navigator.pushNamed(context, '/user-profile', arguments: follower.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:clickme_app/screens/home/widgets/follow_buttoon_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../data/providers/follow_provider.dart';
//
// class FollowersScreen extends StatefulWidget {
//   final String userId;
//
//   const FollowersScreen({super.key, required this.userId});
//
//   @override
//   State<FollowersScreen> createState() => _FollowersScreenState();
// }
//
// class _FollowersScreenState extends State<FollowersScreen> {
//   List<Map<String, dynamic>> _followers = [];
//   List<Map<String, dynamic>> _filteredFollowers = [];
//   bool _isLoading = true;
//   String _searchQuery = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFollowers();
//   }
//
//   Future<void> _loadFollowers() async {
//     setState(() => _isLoading = true);
//
//     final followProvider = context.read<FollowProvider>();
//     final followers = await followProvider.fetchFollowersList(widget.userId);
//
//     setState(() {
//       _followers = followers;
//       _filteredFollowers = followers;
//       _isLoading = false;
//     });
//   }
//
//   void _filterFollowers(String query) {
//     setState(() {
//       _searchQuery = query;
//       if (query.isEmpty) {
//         _filteredFollowers = _followers;
//       } else {
//         _filteredFollowers = _followers.where((follower) {
//           final name = (follower['firstName'] ?? '').toLowerCase() +
//               ' ' +
//               (follower['lastName'] ?? '').toLowerCase();
//           final email = (follower['email'] ?? '').toLowerCase();
//           final searchLower = query.toLowerCase();
//
//           return name.contains(searchLower) || email.contains(searchLower);
//         }).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Followers',
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: [
//           Consumer<FollowProvider>(
//             builder: (context, followProvider, child) {
//               return Center(
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 16),
//                   child: Text(
//                     '${followProvider.followersCount}',
//                     style: const TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               onChanged: _filterFollowers,
//               decoration: InputDecoration(
//                 hintText: 'Search followers...',
//                 prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
//                 filled: true,
//                 fillColor: AppColors.cardBackground,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//             ),
//           ),
//
//           // Loading State
//           if (_isLoading)
//             const Expanded(
//               child: Center(
//                 child: CircularProgressIndicator(
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//
//           // Empty State
//           if (!_isLoading && _filteredFollowers.isEmpty)
//             Expanded(
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       _searchQuery.isEmpty
//                           ? Icons.people_outline
//                           : Icons.search_off,
//                       size: 80,
//                       color: AppColors.textLight,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       _searchQuery.isEmpty
//                           ? 'No followers yet'
//                           : 'No followers found',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//           // Followers List
//           if (!_isLoading && _filteredFollowers.isNotEmpty)
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: _loadFollowers,
//                 color: AppColors.primary,
//                 child: ListView.builder(
//                   itemCount: _filteredFollowers.length,
//                   itemBuilder: (context, index) {
//                     final follower = _filteredFollowers[index];
//                     return _buildFollowerItem(follower);
//                   },
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFollowerItem(Map<String, dynamic> follower) {
//     final followerId = follower['_id'] ?? follower['id'] ?? '';
//     final firstName = follower['firstName'] ?? '';
//     final lastName = follower['lastName'] ?? '';
//     final fullName = '$firstName $lastName'.trim();
//     final email = follower['email'] ?? '';
//     final username = email.isNotEmpty ? '@${email.split('@').first}' : '';
//     final profileImage = follower['profileImage'] ?? follower['avatar'];
//
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 8,
//       ),
//       leading: CircleAvatar(
//         radius: 24,
//         backgroundColor: AppColors.cardBackground,
//         backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
//         child: profileImage == null
//             ? Text(
//           firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: AppColors.primary,
//           ),
//         )
//             : null,
//       ),
//       title: Text(
//         fullName.isNotEmpty ? fullName : 'User',
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       subtitle: Text(
//         username,
//         style: const TextStyle(
//           fontSize: 12,
//           color: AppColors.textSecondary,
//         ),
//       ),
//       trailing: SizedBox(
//         width: 100,
//         height: 36,
//         child: CompactFollowButton(
//           userId: followerId,
//           initialStatus: 'none', // Can be updated based on API response
//         ),
//       ),
//       onTap: () {
//         // TODO: Navigate to user profile
//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(
//         //     builder: (_) => ProfileScreen(userId: followerId),
//         //   ),
//         // );
//       },
//     );
//   }
// }