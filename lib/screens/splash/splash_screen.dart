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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('ðŸš€ SplashScreen: App initialization started...');

      // Step 1: Wait for minimum 2 seconds (splash screen display time)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Step 2: Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('ðŸ”§ SplashScreen: AuthProvider obtained');

      // Step 3: Initialize auth provider (load stored user data)
      await authProvider.initialize();
      print('âœ… SplashScreen: AuthProvider initialized');

      if (!mounted) return;

      // Step 4: Check authentication status
      final isAuthenticated = authProvider.isAuthenticated;
      final user = authProvider.currentUser;

      print('ðŸ” SplashScreen: Auth Status - $isAuthenticated');
      if (user != null) {
        print('ðŸ‘¤ SplashScreen: User - ${user.email}');
      }

      // Step 5: Navigate based on auth status
      if (isAuthenticated && user != null) {
        print('ðŸ  SplashScreen: User authenticated, navigating to Home');
        _navigateToHome();
      } else {
        print('ðŸ”‘ SplashScreen: No user found, navigating to Login');
        _navigateToLogin();
      }
    } catch (e) {
      print('âŒ SplashScreen Error: $e');
      print('âš ï¸ SplashScreen: Defaulting to Login due to error');

      // If any error occurs, navigate to login
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.bottomNav, // Ensure this route exists
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.login, // Ensure this route exists
    );
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
              const Color(0x99FFB6C1), // Light pink
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo Container
            Container(
              width: 130,
              height: 130,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if logo doesn't exist
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group,
                              size: 60,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'CM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // App Name
            const Text(
              'ClickME',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black26,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            const Text(
              'Connect â€¢ Share â€¢ Inspire',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 50),

            // Loading Indicator
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),

            // Loading text
            const SizedBox(height: 20),
            const Text(
              'Initializing...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),

            // Version info (optional)
            const SizedBox(height: 40),
            const Positioned(
              bottom: 20,
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
