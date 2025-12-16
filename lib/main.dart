import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'data/services/storage_service.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/user_provider.dart';
import 'data/providers/post_provider.dart';
import 'data/providers/chat_provider.dart';
import 'data/providers/notification_provider.dart';
import 'data/providers/story_provider.dart';
import 'data/providers/reel_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage
  await StorageService.init();

  // Set System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Set Preferred Orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => ReelProvider()),
      ],
      child: MaterialApp(
        title: 'clickME',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'config/theme.dart';
// import 'config/routes.dart';
// import 'data/services/storage_service.dart';
// import 'data/providers/auth_provider.dart';
// import 'data/providers/user_provider.dart';
// import 'data/providers/post_provider.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Storage
//   await StorageService.init();
//
//   // Set System UI
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//     ),
//   );
//
//   // Set Preferred Orientations
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//         ChangeNotifierProvider(create: (_) => PostProvider()),
//       ],
//       child: MaterialApp(
//         title: 'clickME',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.lightTheme,
//         initialRoute: AppRoutes.splash,
//         onGenerateRoute: AppRoutes.generateRoute,
//       ),
//     );
//   }
// }