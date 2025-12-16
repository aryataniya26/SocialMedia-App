import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedTab = 'All';
  final List<String> _tabs = ['All', 'Users', 'Posts', 'Reels', 'Pages'];

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // TODO: Replace with real API call
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        _searchResults = List.generate(
          10,
              (index) => {
            'id': '${index + 1}',
            'name': 'User ${index + 1}',
            'username': '@user${index + 1}',
            'avatar': 'https://i.pravatar.cc/150?img=${index + 1}',
            'type': _selectedTab == 'All'
                ? (index % 3 == 0 ? 'user' : index % 3 == 1 ? 'post' : 'reel')
                : _selectedTab.toLowerCase(),
          },
        );
        _isSearching = false;
      });
    });
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
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.searchBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search users, posts, pages...',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 15,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF9CA3AF),
                size: 22,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  _performSearch('');
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: _performSearch,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          SizedBox(
            height: 50,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = _selectedTab == tab;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = tab;
                    });
                    if (_searchController.text.isNotEmpty) {
                      _performSearch(_searchController.text);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Search Results
          Expanded(
            child: _isSearching
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
                : _searchController.text.isEmpty
                ? _buildTrendingSection()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Trending Now',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(10, (index) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.trending_up, color: AppColors.primary),
            ),
            title: Text(
              '#trending${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              '${(index + 1) * 1234} posts',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _searchController.text = '#trending${index + 1}';
              _performSearch(_searchController.text);
            },
          );
        }),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(result['avatar']),
            backgroundColor: AppColors.cardBackground,
          ),
          title: Text(
            result['name'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            result['username'],
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to user profile or post
          },
        );
      },
    );
  }
}


// import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
//
// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});
//
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedTab = 'All';
//   final List<String> _tabs = ['All', 'Users', 'Posts', 'Reels', 'Pages'];
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Search',
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search users, posts, pages...',
//                 prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                   icon: const Icon(Icons.clear, color: AppColors.textLight),
//                   onPressed: () {
//                     _searchController.clear();
//                     setState(() {});
//                   },
//                 )
//                     : null,
//                 filled: true,
//                 fillColor: AppColors.cardBackground,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               onChanged: (value) {
//                 setState(() {});
//               },
//             ),
//           ),
//           // Tabs
//           SizedBox(
//             height: 40,
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               scrollDirection: Axis.horizontal,
//               itemCount: _tabs.length,
//               itemBuilder: (context, index) {
//                 final tab = _tabs[index];
//                 final isSelected = _selectedTab == tab;
//
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _selectedTab = tab;
//                     });
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(right: 12),
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: isSelected ? AppColors.primary : Colors.transparent,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: isSelected ? AppColors.primary : AppColors.border,
//                       ),
//                     ),
//                     child: Text(
//                       tab,
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : AppColors.textSecondary,
//                         fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Search Results
//           Expanded(
//             child: _searchController.text.isEmpty
//                 ? _buildTrendingSection()
//                 : _buildSearchResults(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTrendingSection() {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         const Text(
//           'Trending Now',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 16),
//         ...List.generate(5, (index) {
//           return ListTile(
//             leading: Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(Icons.trending_up, color: AppColors.primary),
//             ),
//             title: Text('#trending${index + 1}'),
//             subtitle: Text('${(index + 1) * 1000}K posts'),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () {},
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget _buildSearchResults() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 10,
//       itemBuilder: (context, index) {
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundColor: AppColors.cardBackground,
//             child: Text('${index + 1}'),
//           ),
//           title: Text('Search Result ${index + 1}'),
//           subtitle: const Text('Description here'),
//           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//           onTap: () {},
//         );
//       },
//     );
//   }
// }