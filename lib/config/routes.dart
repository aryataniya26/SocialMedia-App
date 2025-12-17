import 'package:clickme_app/screens/auth/forgot_password_screen.dart';
import 'package:clickme_app/screens/auth/reset_password_screen.dart';
import 'package:clickme_app/screens/post/post_detail_screen.dart';
import 'package:clickme_app/screens/profile/followers_screen.dart';
import 'package:clickme_app/screens/profile/following_screen.dart';
import 'package:clickme_app/screens/profile/suggestions_screen.dart';
import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/profile_setup_screen.dart';
import '../screens/auth/interests_screen.dart';
import '../screens/home/bottom_nav.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String profileSetup = '/profile-setup';
  static const String interests = '/interests';
  static const String bottomNav = '/bottom-nav';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String followers = '/followers';
  static const String following = '/following';
  static const String suggestions = '/suggestions';
  static const String postDetail = '/post-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      case AppRoutes.followers:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => FollowersScreen(
            userId: args?['userId'] ?? '',
            title: args?['title'],
          ),
        );




      case AppRoutes.following:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => FollowingScreen(
            userId: args?['userId'] ?? '',
            title: args?['title'],
          ),
        );

      case AppRoutes.suggestions:
        return MaterialPageRoute(
          builder: (_) => const SuggestionsScreen(),
        );
      case AppRoutes.resetPassword:
        final token = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(token: token),
        );
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case otp:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OtpScreen(
          // mobile: args?['mobile'],
            email: args?['email'],
            purpose: args?['purpose'] ?? 'login',
          ),
        );

      case profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());

      case interests:
        return MaterialPageRoute(builder: (_) => const InterestsScreen());

      case bottomNav:
        return MaterialPageRoute(builder: (_) => const BottomNavScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}



// import 'package:flutter/material.dart';
// import '../screens/splash/splash_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/signup_screen.dart';
// import '../screens/auth/otp_screen.dart';
// import '../screens/auth/profile_setup_screen.dart';
// import '../screens/auth/interests_screen.dart';
// import '../screens/home/bottom_nav.dart';
//
// class AppRoutes {
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String signup = '/signup';
//   static const String otp = '/otp';
//   static const String profileSetup = '/profile-setup';
//   static const String interests = '/interests';
//   static const String bottomNav = '/bottom-nav';
//
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case splash:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//
//       case login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
//
//       case signup:
//         return MaterialPageRoute(builder: (_) => const SignupScreen());
//
//       case otp:
//         final args = settings.arguments as Map<String, dynamic>?;
//         return MaterialPageRoute(
//           builder: (_) => OtpScreen(
//             mobile: args?['mobile'],
//             email: args?['email'],
//             purpose: args?['purpose'] ?? 'login',
//           ),
//         );
//
//       case profileSetup:
//         return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());
//
//       case interests:
//         return MaterialPageRoute(builder: (_) => const InterestsScreen());
//
//       case bottomNav:
//         return MaterialPageRoute(builder: (_) => const BottomNavScreen());
//
//       default:
//         return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             body: Center(
//               child: Text('No route defined for ${settings.name}'),
//             ),
//           ),
//         );
//     }
//   }
// }