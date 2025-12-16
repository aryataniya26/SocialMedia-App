import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'home_screen.dart';
import '../search/search_screen.dart';
import '../create/create_menu_screen.dart';
import '../reels/reels_screen.dart';
import '../profile/profile_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const CreateMenuScreen(),
    const ReelsScreen(), // ADDED REELS
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    filledIcon: Icons.home_rounded,
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.people_outline,
                    filledIcon: Icons.people,
                    index: 1,
                  ),
                  _buildCreateButton(),
                  _buildNavItem(
                    icon: Icons.video_library_outlined,
                    filledIcon: Icons.video_library,
                    index: 3,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    filledIcon: Icons.person,
                    index: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData filledIcon,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(
          isSelected ? filledIcon : icon,
          color: isSelected ? AppColors.primary : const Color(0xFF9CA3AF),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = 2;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF9333EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
// import 'home_screen.dart';
// import '../search/search_screen.dart';
// import '../create/create_menu_screen.dart';
// import '../notifications/notifications_screen.dart';
// import '../profile/profile_screen.dart';
//
// class BottomNavScreen extends StatefulWidget {
//   const BottomNavScreen({super.key});
//
//   @override
//   State<BottomNavScreen> createState() => _BottomNavScreenState();
// }
//
// class _BottomNavScreenState extends State<BottomNavScreen> {
//   int _currentIndex = 0;
//
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const SearchScreen(),
//     const CreateMenuScreen(),
//     const NotificationsScreen(),
//     const ProfileScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_currentIndex != 0) {
//           setState(() {
//             _currentIndex = 0;
//           });
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         body: IndexedStack(
//           index: _currentIndex,
//           children: _screens,
//         ),
//         bottomNavigationBar: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 8,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           child: SafeArea(
//             child: Container(
//               height: 65,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildNavItem(
//                     icon: Icons.home,
//                     filledIcon: Icons.home_rounded,
//                     index: 0,
//                   ),
//                   _buildNavItem(
//                     icon: Icons.people_outline,
//                     filledIcon: Icons.people,
//                     index: 1,
//                   ),
//                   _buildCreateButton(),
//                   _buildNavItem(
//                     icon: Icons.video_library_outlined,
//                     filledIcon: Icons.video_library,
//                     index: 3,
//                   ),
//                   _buildNavItem(
//                     icon: Icons.person_outline,
//                     filledIcon: Icons.person,
//                     index: 4,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavItem({
//     required IconData icon,
//     required IconData filledIcon,
//     required int index,
//   }) {
//     final isSelected = _currentIndex == index;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _currentIndex = index;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         child: Icon(
//           isSelected ? filledIcon : icon,
//           color: isSelected ? AppColors.primary : const Color(0xFF9CA3AF),
//           size: 28,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCreateButton() {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _currentIndex = 2;
//         });
//       },
//       child: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [AppColors.primary, Color(0xFF7C3AED)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Icon(
//           Icons.add_rounded,
//           color: Colors.white,
//           size: 28,
//         ),
//       ),
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import '../../core/constants/app_colors.dart';
// // import 'home_screen.dart';
// // import '../search/search_screen.dart';
// // import '../create/create_menu_screen.dart';
// // import '../notifications/notifications_screen.dart';
// // import '../profile/profile_screen.dart';
// //
// // class BottomNavScreen extends StatefulWidget {
// //   const BottomNavScreen({super.key});
// //
// //   @override
// //   State<BottomNavScreen> createState() => _BottomNavScreenState();
// // }
// //
// // class _BottomNavScreenState extends State<BottomNavScreen> {
// //   int _currentIndex = 0;
// //
// //   final List<Widget> _screens = [
// //     const HomeScreen(),
// //     const SearchScreen(),
// //     const CreateMenuScreen(),
// //     const NotificationsScreen(),
// //     const ProfileScreen(),
// //   ];
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: () async {
// //         if (_currentIndex != 0) {
// //           setState(() {
// //             _currentIndex = 0;
// //           });
// //           return false;
// //         }
// //         return true;
// //       },
// //       child: Scaffold(
// //         body: IndexedStack(
// //           index: _currentIndex,
// //           children: _screens,
// //         ),
// //         bottomNavigationBar: Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black.withOpacity(0.05),
// //                 blurRadius: 10,
// //                 offset: const Offset(0, -2),
// //               ),
// //             ],
// //           ),
// //           child: SafeArea(
// //             child: Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   _buildNavItem(Icons.home_rounded, 0),
// //                   _buildNavItem(Icons.search_rounded, 1),
// //                   _buildCreateButton(),
// //                   _buildNavItem(Icons.video_collection_rounded, 3),
// //                   _buildNavItem(Icons.person_rounded, 4),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildNavItem(IconData icon, int index) {
// //     final isSelected = _currentIndex == index;
// //
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           _currentIndex = index;
// //         });
// //       },
// //       child: Container(
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: isSelected
// //               ? AppColors.primary.withOpacity(0.1)
// //               : Colors.transparent,
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //         child: Icon(
// //           icon,
// //           color: isSelected ? AppColors.primary : AppColors.textLight,
// //           size: 28,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCreateButton() {
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           _currentIndex = 2;
// //         });
// //       },
// //       child: Container(
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           gradient: AppColors.primaryGradient,
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //         child: const Icon(
// //           Icons.add_rounded,
// //           color: Colors.white,
// //           size: 28,
// //         ),
// //       ),
// //     );
// //   }
// // }