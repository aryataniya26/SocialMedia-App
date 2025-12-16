import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/auth_provider.dart';
import '../../config/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait for 2 seconds (splash screen display time)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is already logged in
    final isLoggedIn = await authProvider.checkAuthStatus();

    if (!mounted) return;

    if (isLoggedIn) {
      // User is logged in, go to home
      Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
    } else {
      // User is not logged in, go to login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              Color(0x99FFB6C1), // Light pink
            ],
          ),
          // gradient: AppColors.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 32),
            // App Name
            const Text(
              'clickME',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect • Share • Inspire',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 50),
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
// import '../../config/routes.dart';
// import '../../data/providers/auth_provider.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeIn),
//     );
//
//     _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
//     );
//
//     _controller.forward();
//     _checkAuth();
//   }
//
//   Future<void> _checkAuth() async {
//     await Future.delayed(const Duration(seconds: 3));
//
//     if (!mounted) return;
//
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final isLoggedIn = await authProvider.checkAuthStatus();
//
//     if (!mounted) return;
//
//     if (isLoggedIn) {
//       Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
//     } else {
//       Navigator.pushReplacementNamed(context, AppRoutes.login);
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.primary,
//               AppColors.primaryLight,
//               Color(0xFFFFB6C1), // Light pink
//             ],
//           ),
//           // gradient: AppColors.splashGradient,
//         ),
//         child: Center(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: ScaleTransition(
//               scale: _scaleAnimation,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Logo
//                   Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(30),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 20,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Image.asset(
//                       'assets/logo.png',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//
//                   // Container(
//                   //   width: 120,
//                   //   height: 120,
//                   //   decoration: BoxDecoration(
//                   //     color: Colors.white,
//                   //     borderRadius: BorderRadius.circular(30),
//                   //     boxShadow: [
//                   //       BoxShadow(
//                   //         color: Colors.black.withOpacity(0.2),
//                   //         blurRadius: 20,
//                   //         offset: const Offset(0, 10),
//                   //       ),
//                   //     ],
//                   //   ),
//                   //   child: Icon(
//                   //     Icons.touch_app_rounded,
//                   //     size: 60,
//                   //     color: AppColors.primary,
//                   //   ),
//                   // ),
//                   const SizedBox(height: 32),
//                   // App Name
//                   Text(
//                     'Welcome to',
//                     style: TextStyle(
//                       fontSize: 20,
//                       color: Colors.white.withOpacity(0.9),
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'clickME!',
//                     style: TextStyle(
//                       fontSize: 48,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                   // Loading Indicator
//                   const SizedBox(
//                     width: 40,
//                     height: 40,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 3,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../core/constants/app_colors.dart';
// // import '../../config/routes.dart';
// // import '../../data/providers/auth_provider.dart';
// //
// // class SplashScreen extends StatefulWidget {
// //   const SplashScreen({super.key});
// //
// //   @override
// //   State<SplashScreen> createState() => _SplashScreenState();
// // }
// //
// // class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
// //   late AnimationController _controller;
// //   late Animation<double> _fadeAnimation;
// //   late Animation<double> _scaleAnimation;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     _controller = AnimationController(
// //       duration: const Duration(milliseconds: 1500),
// //       vsync: this,
// //     );
// //
// //     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(parent: _controller, curve: Curves.easeIn),
// //     );
// //
// //     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
// //       CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
// //     );
// //
// //     _controller.forward();
// //     _checkAuthAndNavigate();
// //   }
// //
// //   Future<void> _checkAuthAndNavigate() async {
// //     await Future.delayed(const Duration(seconds: 3));
// //
// //     if (!mounted) return;
// //
// //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// //     final isLoggedIn = await authProvider.checkAuthStatus();
// //
// //     if (!mounted) return;
// //
// //     if (isLoggedIn) {
// //       Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
// //     } else {
// //       Navigator.pushReplacementNamed(context, AppRoutes.login);
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: AppColors.splashGradient,
// //         ),
// //         child: Center(
// //           child: FadeTransition(
// //             opacity: _fadeAnimation,
// //             child: ScaleTransition(
// //               scale: _scaleAnimation,
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   // App Icon with Gradient Background
// //                   Container(
// //                     width: 140,
// //                     height: 140,
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: [
// //                           Colors.blue.shade300,
// //                           AppColors.primary,
// //                         ],
// //                         begin: Alignment.topLeft,
// //                         end: Alignment.bottomRight,
// //                       ),
// //                       borderRadius: BorderRadius.circular(35),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.3),
// //                           blurRadius: 30,
// //                           offset: const Offset(0, 15),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Stack(
// //                       alignment: Alignment.center,
// //                       children: [
// //                         // Ripple effect circles
// //                         ...List.generate(3, (index) {
// //                           return AnimatedBuilder(
// //                             animation: _controller,
// //                             builder: (context, child) {
// //                               return Container(
// //                                 width: 70 + (index * 20 * _controller.value),
// //                                 height: 70 + (index * 20 * _controller.value),
// //                                 decoration: BoxDecoration(
// //                                   shape: BoxShape.circle,
// //                                   border: Border.all(
// //                                     color: Colors.white.withOpacity(0.3 - (index * 0.1)),
// //                                     width: 2,
// //                                   ),
// //                                 ),
// //                               );
// //                             },
// //                           );
// //                         }),
// //                         // Hand icon
// //                         const Icon(
// //                           Icons.touch_app_rounded,
// //                           size: 70,
// //                           color: Colors.white,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   const SizedBox(height: 40),
// //                   // App Name
// //                   const Text(
// //                     'Welcome to',
// //                     style: TextStyle(
// //                       color: Colors.white70,
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.w400,
// //                       letterSpacing: 1,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   RichText(
// //                     text: const TextSpan(
// //                       children: [
// //                         TextSpan(
// //                           text: 'click',
// //                           style: TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 48,
// //                             fontWeight: FontWeight.bold,
// //                             letterSpacing: 2,
// //                           ),
// //                         ),
// //                         TextSpan(
// //                           text: 'ME',
// //                           style: TextStyle(
// //                             color: Color(0xFFFFDA7B), // Yellow
// //                             fontSize: 48,
// //                             fontWeight: FontWeight.bold,
// //                             letterSpacing: 2,
// //                           ),
// //                         ),
// //                         TextSpan(
// //                           text: '!',
// //                           style: TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 48,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import '../../core/constants/app_colors.dart';
// // // import '../../config/routes.dart';
// // // import '../../data/providers/auth_provider.dart';
// // //
// // // class SplashScreen extends StatefulWidget {
// // //   const SplashScreen({super.key});
// // //
// // //   @override
// // //   State<SplashScreen> createState() => _SplashScreenState();
// // // }
// // //
// // // class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
// // //   late AnimationController _controller;
// // //   late Animation<double> _fadeAnimation;
// // //   late Animation<double> _scaleAnimation;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //
// // //     _controller = AnimationController(
// // //       duration: const Duration(milliseconds: 1500),
// // //       vsync: this,
// // //     );
// // //
// // //     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// // //       CurvedAnimation(parent: _controller, curve: Curves.easeIn),
// // //     );
// // //
// // //     _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
// // //       CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
// // //     );
// // //
// // //     _controller.forward();
// // //     _checkAuthAndNavigate();
// // //   }
// // //
// // //   Future<void> _checkAuthAndNavigate() async {
// // //     await Future.delayed(const Duration(seconds: 2));
// // //
// // //     if (!mounted) return;
// // //
// // //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// // //     final isLoggedIn = await authProvider.checkAuthStatus();
// // //
// // //     if (!mounted) return;
// // //
// // //     if (isLoggedIn) {
// // //       Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
// // //     } else {
// // //       Navigator.pushReplacementNamed(context, AppRoutes.login);
// // //     }
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _controller.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       body: Container(
// // //         decoration: const BoxDecoration(
// // //           gradient: AppColors.splashGradient,
// // //         ),
// // //         child: Center(
// // //           child: FadeTransition(
// // //             opacity: _fadeAnimation,
// // //             child: ScaleTransition(
// // //               scale: _scaleAnimation,
// // //               child: Column(
// // //                 mainAxisAlignment: MainAxisAlignment.center,
// // //                 children: [
// // //                   // App Icon
// // //                   Container(
// // //                     width: 120,
// // //                     height: 120,
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.white,
// // //                       borderRadius: BorderRadius.circular(30),
// // //                       boxShadow: [
// // //                         BoxShadow(
// // //                           color: Colors.black.withOpacity(0.2),
// // //                           blurRadius: 20,
// // //                           offset: const Offset(0, 10),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     child: const Icon(
// // //                       Icons.touch_app_rounded,
// // //                       size: 60,
// // //                       color: AppColors.primary,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 24),
// // //                   // App Name
// // //                   const Text(
// // //                     'Welcome to',
// // //                     style: TextStyle(
// // //                       color: Colors.white70,
// // //                       fontSize: 16,
// // //                       fontWeight: FontWeight.w400,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 8),
// // //                   const Text(
// // //                     'clickME!',
// // //                     style: TextStyle(
// // //                       color: Colors.white,
// // //                       fontSize: 36,
// // //                       fontWeight: FontWeight.bold,
// // //                       letterSpacing: 1,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }