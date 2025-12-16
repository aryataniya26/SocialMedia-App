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

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
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
          mobile: args?['mobile'],
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