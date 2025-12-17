import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../data/providers/auth_provider.dart';
import '../../config/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper method to show success message
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Helper method to show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final result = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      // ✅ Direct login successful - navigate to home
      _showSuccess('Login successful!');

      // Navigate to home screen
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
      });
    } else {
      _showError(result['message'] ?? 'Login failed');
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final result = await authProvider.forgotPassword(
        _emailController.text.trim());

    if (!mounted) return;

    if (result['success'] == true) {
      _showSuccess(result['message'] ?? 'Password reset link sent');
    } else {
      _showError(result['message'] ?? 'Failed to send reset link');
    }
  }

  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     appBar: AppBar(
  //       backgroundColor: Colors.white,
  //       elevation: 0,
  //       leading: IconButton(
  //         icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
  //         onPressed: () => Navigator.pop(context),
  //       ),
  //       title: const Text(
  //         'Login',
  //         style: TextStyle(
  //           color: AppColors.textPrimary,
  //           fontSize: 18,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //     ),
  //     body: SafeArea(
  //       child: SingleChildScrollView(
  //         padding: const EdgeInsets.all(24),
  //         child: Form(
  //           key: _formKey,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const SizedBox(height: 40),
  //
  //               // App Logo
  //               Center(
  //                 child: Container(
  //                   width: 120,
  //                   height: 120,
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(30),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.2),
  //                         blurRadius: 20,
  //                         offset: const Offset(0, 10),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Image.asset(
  //                     'assets/logo.png',
  //                     fit: BoxFit.cover,
  //                     errorBuilder: (context, error, stackTrace) {
  //                       return Container(
  //                         decoration: BoxDecoration(
  //                           color: AppColors.primary,
  //                           borderRadius: BorderRadius.circular(30),
  //                         ),
  //                         child: const Center(
  //                           child: Icon(
  //                             Icons.group,
  //                             size: 60,
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 32),
  //
  //               // Welcome text
  //               const Text(
  //                 'Welcome Back!',
  //                 style: TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                   color: AppColors.textPrimary,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               const Text(
  //                 'Sign in to continue to ClickME',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   color: AppColors.textSecondary,
  //                 ),
  //               ),
  //               const SizedBox(height: 32),
  //
  //               // Email Field
  //               CustomTextField(
  //                 label: 'Email Address *',
  //                 hint: 'your.email@example.com',
  //                 controller: _emailController,
  //                 keyboardType: TextInputType.emailAddress,
  //                 prefixIcon: const Icon(Icons.email, size: 20),
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return 'Please enter your email';
  //                   }
  //                   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
  //                     return 'Please enter a valid email';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               const SizedBox(height: 16),
  //
  //               // Password Field
  //               CustomTextField(
  //                 label: 'Password *',
  //                 hint: 'Enter your password',
  //                 controller: _passwordController,
  //                 obscureText: true,
  //                 prefixIcon: const Icon(Icons.lock, size: 20),
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return 'Please enter password';
  //                   }
  //                   if (value.length < 6) {
  //                     return 'Password must be at least 6 characters';
  //                   }
  //                   return null;
  //                 },
  //               ),
  //               const SizedBox(height: 8),
  //
  //               // Forgot Password
  //               Align(
  //                 alignment: Alignment.centerRight,
  //                 child: TextButton(
  //                   onPressed: _handleForgotPassword,
  //                   child: const Text(
  //                     'Forgot Password?',
  //                     style: TextStyle(
  //                       color: AppColors.primary,
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 24),
  //
  //               // Login Button
  //               Consumer<AuthProvider>(
  //                 builder: (context, authProvider, _) {
  //                   return CustomButton(
  //                     text: 'Login',
  //                     onPressed: _handleLogin,
  //                     isLoading: authProvider.isLoading,
  //                   );
  //                 },
  //               ),
  //               const SizedBox(height: 16),
  //
  //               // Info box - Update message since OTP is disabled
  //               Container(
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.primary.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(8),
  //                   border: Border.all(color: AppColors.primary.withOpacity(0.3)),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Icon(
  //                       Icons.info_outline,
  //                       color: AppColors.primary,
  //                       size: 20,
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Expanded(
  //                       child: Text(
  //                         'Direct login enabled. OTP verification is currently disabled.',
  //                         style: TextStyle(
  //                           fontSize: 12,
  //                           color: AppColors.primary,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(height: 24),
  //
  //               // Divider
  //               const Row(
  //                 children: [
  //                   Expanded(child: Divider()),
  //                   Padding(
  //                     padding: EdgeInsets.symmetric(horizontal: 16),
  //                     child: Text(
  //                       'OR',
  //                       style: TextStyle(color: AppColors.textLight),
  //                     ),
  //                   ),
  //                   Expanded(child: Divider()),
  //                 ],
  //               ),
  //               const SizedBox(height: 24),
  //
  //               // Create Account Button
  //               CustomButton(
  //                 text: 'Create New Account',
  //                 onPressed: () {
  //                   Navigator.pushNamed(context, '/signup');
  //                 },
  //                 isOutlined: true,
  //               ),
  //               const SizedBox(height: 24),
  //
  //               // Already have account? (for consistency)
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   const Text(
  //                     "Don't have an account? ",
  //                     style: TextStyle(
  //                       color: AppColors.textSecondary,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                   TextButton(
  //                     onPressed: () {
  //                       Navigator.pushNamed(context, '/signup');
  //                     },
  //                     child: const Text(
  //                       'Sign Up',
  //                       style: TextStyle(
  //                         color: AppColors.primary,
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 20),
  //
  //               // Footer note
  //               const Center(
  //                 child: Text(
  //                   'By continuing, you agree to ClickME\'s Terms and acknowledge our Privacy Policy',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     color: AppColors.textLight,
  //                     fontSize: 11,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),

                // App Logo
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.group,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 🔹 Login Text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Email Field
                CustomTextField(
                  hint: 'Mobile number or email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter email or mobile';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 🔹 Password Field
                CustomTextField(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 🔹 Login Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _handleLogin,
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Forgot Password
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 🔹 Create Account Button (Outlined)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: AppColors.primary),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text(
                      'Create new Account',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 🔹 Bottom Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('About', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 16),
                    Text('Help', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 16),
                    Text('More', style: TextStyle(fontSize: 12)),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}