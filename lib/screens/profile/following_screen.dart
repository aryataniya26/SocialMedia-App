import 'package:clickme_app/screens/home/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/follow_provider.dart';
import '../../data/models/user_model.dart';
import '../../core/widgets/loading_widget.dart';

class FollowingScreen extends StatefulWidget {
  final String userId;
  final String? title;

  const FollowingScreen({
    Key? key,
    required this.userId,
    this.title,
  }) : super(key: key);

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final List<UserModel> _following = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);

    final followProvider = Provider.of<FollowProvider>(context, listen: false);
    final newFollowing = await followProvider.getFollowing(
      widget.userId,
      refresh: _page == 1,
    );

    setState(() {
      if (_page == 1) {
        _following.clear();
      }
      _following.addAll(newFollowing);
      _hasMore = newFollowing.length == _limit;
      _isLoading = false;
      _page++;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _hasMore = true;
    });
    await _loadFollowing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Following'),
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
                  hintText: 'Search following...',
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

            // Following Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_following.length} following',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Following List
            Expanded(
              child: _following.isEmpty && !_isLoading
                  ? const Center(
                child: Text(
                  'Not following anyone yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _following.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _following.length) {
                    if (_hasMore) {
                      _loadFollowing();
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: LoadingWidget()),
                      );
                    }
                    return const SizedBox();
                  }

                  final following = _following[index];
                  return UserCard(
                    user: following,
                    onTap: () {
                      // Navigate to user profile
                      // Navigator.pushNamed(context, '/user-profile', arguments: following.id);
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
// class FollowingScreen extends StatefulWidget {
//   final String userId;
//
//   const FollowingScreen({super.key, required this.userId});
//
//   @override
//   State<FollowingScreen> createState() => _FollowingScreenState();
// }
//
// class _FollowingScreenState extends State<FollowingScreen> {
//   List<Map<String, dynamic>> _following = [];
//   List<Map<String, dynamic>> _filteredFollowing = [];
//   bool _isLoading = true;
//   String _searchQuery = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFollowing();
//   }
//
//   Future<void> _loadFollowing() async {
//     setState(() => _isLoading = true);
//
//     final followProvider = context.read<FollowProvider>();
//     final following = await followProvider.fetchFollowingList(widget.userId);
//
//     setState(() {
//       _following = following;
//       _filteredFollowing = following;
//       _isLoading = false;
//     });
//   }
//
//   void _filterFollowing(String query) {
//     setState(() {
//       _searchQuery = query;
//       if (query.isEmpty) {
//         _filteredFollowing = _following;
//       } else {
//         _filteredFollowing = _following.where((user) {
//           final name = (user['firstName'] ?? '').toLowerCase() +
//               ' ' +
//               (user['lastName'] ?? '').toLowerCase();
//           final email = (user['email'] ?? '').toLowerCase();
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
//           'Following',
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
//                     '${followProvider.followingCount}',
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
//               onChanged: _filterFollowing,
//               decoration: InputDecoration(
//                 hintText: 'Search following...',
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
//           if (!_isLoading && _filteredFollowing.isEmpty)
//             Expanded(
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       _searchQuery.isEmpty
//                           ? Icons.person_add_outlined
//                           : Icons.search_off,
//                       size: 80,
//                       color: AppColors.textLight,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       _searchQuery.isEmpty
//                           ? 'Not following anyone yet'
//                           : 'No users found',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                     if (_searchQuery.isEmpty) ...[
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Find people to follow',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: AppColors.textLight,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//
//           // Following List
//           if (!_isLoading && _filteredFollowing.isNotEmpty)
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: _loadFollowing,
//                 color: AppColors.primary,
//                 child: ListView.builder(
//                   itemCount: _filteredFollowing.length,
//                   itemBuilder: (context, index) {
//                     final user = _filteredFollowing[index];
//                     return _buildFollowingItem(user);
//                   },
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFollowingItem(Map<String, dynamic> user) {
//     final userId = user['_id'] ?? user['id'] ?? '';
//     final firstName = user['firstName'] ?? '';
//     final lastName = user['lastName'] ?? '';
//     final fullName = '$firstName $lastName'.trim();
//     final email = user['email'] ?? '';
//     final username = email.isNotEmpty ? '@${email.split('@').first}' : '';
//     final profileImage = user['profileImage'] ?? user['avatar'];
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
//           userId: userId,
//           initialStatus: 'following',
//         ),
//       ),
//       onTap: () {
//         // TODO: Navigate to user profile
//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(
//         //     builder: (_) => ProfileScreen(userId: userId),
//         //   ),
//         // );
//       },
//     );
//   }
// }