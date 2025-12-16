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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Step 1: Send email + password → Backend sends OTP
    final result = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      // Step 2: Navigate to OTP screen
      Navigator.pushNamed(
        context,
        AppRoutes.otp,
        arguments: {
          'email': result['email'],
          'userId': result['userId'],
          'purpose': 'login',
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'OTP sent to your email'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

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
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Log in',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 32),

                // Email Field
                CustomTextField(
                  label: 'Email address',
                  hint: 'example@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Forgot password feature coming soon'),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgotten password?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      text: 'Log in',
                      onPressed: _handleLogin,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Info text
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'OTP will be sent to your email',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Create Account Button
                CustomButton(
                  text: 'Create new Account',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signup);
                  },
                  isOutlined: true,
                ),
                const SizedBox(height: 24),

                // Footer Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'About',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Help',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'More',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// // lib/screens/auth/login_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/widgets/custom_button.dart';
// import '../../core/widgets/custom_textfield.dart';
// import '../../data/providers/auth_provider.dart';
// import '../../config/routes.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController(); // Changed from mobile to email
//   final _passwordController = TextEditingController();
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//
//     // Step 1: Send email + password → Backend sends OTP
//     final success = await authProvider.login(
//       email: _emailController.text.trim(),
//       password: _passwordController.text,
//     );
//
//     if (!mounted) return;
//
//     if (success) {
//       // Step 2: Navigate to OTP screen
//       Navigator.pushNamed(
//         context,
//         AppRoutes.otp,
//         arguments: {
//           'email': _emailController.text.trim(),
//           'purpose': 'login',
//         },
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(authProvider.error ?? 'Login failed'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 40),
//                 // App Logo
//                 Center(
//                   child: Container(
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
//                 ),
//                 const SizedBox(height: 32),
//                 // Title
//                 const Text(
//                   'Log in',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 // Email Field (CHANGED FROM MOBILE)
//                 CustomTextField(
//                   label: 'Email address',
//                   hint: 'example@email.com',
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!value.contains('@')) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 // Password Field
//                 CustomTextField(
//                   label: 'Password',
//                   hint: 'Enter your password',
//                   controller: _passwordController,
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter password';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       // TODO: Implement forgot password
//                     },
//                     child: const Text(
//                       'Forgotten password?',
//                       style: TextStyle(
//                         color: AppColors.textSecondary,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 // Login Button
//                 Consumer<AuthProvider>(
//                   builder: (context, authProvider, _) {
//                     return CustomButton(
//                       text: 'Log in',
//                       onPressed: _handleLogin,
//                       isLoading: authProvider.isLoading,
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 // Info text
//                 Center(
//                   child: Text(
//                     'OTP will be sent to your email',
//                     style: TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 // Divider
//                 const Row(
//                   children: [
//                     Expanded(child: Divider()),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: Text(
//                         'OR',
//                         style: TextStyle(color: AppColors.textLight),
//                       ),
//                     ),
//                     Expanded(child: Divider()),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 // Create Account Button
//                 CustomButton(
//                   text: 'Create new Account',
//                   onPressed: () {
//                     Navigator.pushNamed(context, AppRoutes.signup);
//                   },
//                   isOutlined: true,
//                 ),
//                 const SizedBox(height: 24),
//                 // Footer Links
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     TextButton(
//                       onPressed: () {},
//                       child: const Text(
//                         'About',
//                         style: TextStyle(
//                           color: AppColors.textSecondary,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {},
//                       child: const Text(
//                         'Help',
//                         style: TextStyle(
//                           color: AppColors.textSecondary,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {},
//                       child: const Text(
//                         'More',
//                         style: TextStyle(
//                           color: AppColors.textSecondary,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../core/constants/app_colors.dart';
// // import '../../core/widgets/custom_button.dart';
// // import '../../core/widgets/custom_textfield.dart';
// // import '../../data/providers/auth_provider.dart';
// // import '../../config/routes.dart';
// //
// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});
// //
// //   @override
// //   State<LoginScreen> createState() => _LoginScreenState();
// // }
// //
// // class _LoginScreenState extends State<LoginScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _mobileController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   bool _isPasswordLogin = true;
// //
// //   @override
// //   void dispose() {
// //     _mobileController.dispose();
// //     _passwordController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _handleLogin() async {
// //     if (!_formKey.currentState!.validate()) return;
// //
// //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// //
// //     if (_isPasswordLogin) {
// //       // Login with Password
// //       final success = await authProvider.login(
// //         mobile: _mobileController.text.trim(),
// //         password: _passwordController.text,
// //       );
// //
// //       if (!mounted) return;
// //
// //       if (success) {
// //         Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text(authProvider.error ?? 'Login failed')),
// //         );
// //       }
// //     } else {
// //       // Send OTP
// //       final success = await authProvider.sendOtp(
// //         mobileOrEmail: _mobileController.text.trim(),
// //         purpose: 'login',
// //       );
// //
// //       if (!mounted) return;
// //
// //       if (success) {
// //         Navigator.pushNamed(
// //           context,
// //           AppRoutes.otp,
// //           arguments: {
// //             'mobile': _mobileController.text.trim(),
// //             'email': null,
// //             'purpose': 'login',
// //           },
// //         );
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text(authProvider.error ?? 'Failed to send OTP')),
// //         );
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(24),
// //           child: Form(
// //             key: _formKey,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const SizedBox(height: 40),
// //                 // App Logo
// //                 Center(
// //                   child: Container(
// //                       width: 120,
// //                       height: 120,
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(30),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: Colors.black.withOpacity(0.2),
// //                             blurRadius: 20,
// //                             offset: const Offset(0, 10),
// //                           ),
// //                         ],
// //                       ),
// //                       child: Image.asset(
// //                         'assets/logo.png',
// //                         fit: BoxFit.cover,
// //                       ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 32),
// //                 // Title
// //                 const Text(
// //                   'Log in',
// //                   style: TextStyle(
// //                     fontSize: 28,
// //                     fontWeight: FontWeight.bold,
// //                     color: AppColors.textPrimary,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 32),
// //                 // Mobile/Email Field
// //                 CustomTextField(
// //                   label: 'Mobile number or email address',
// //                   hint: 'XXXX',
// //                   controller: _mobileController,
// //                   keyboardType: TextInputType.text,
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter mobile or email';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),
// //                 // Password Field (conditional)
// //                 if (_isPasswordLogin) ...[
// //                   CustomTextField(
// //                     label: 'Password',
// //                     hint: 'XXXX',
// //                     controller: _passwordController,
// //                     obscureText: true,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'Please enter password';
// //                       }
// //                       return null;
// //                     },
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Align(
// //                     alignment: Alignment.centerRight,
// //                     child: TextButton(
// //                       onPressed: () {
// //                         // TODO: Implement forgot password
// //                       },
// //                       child: const Text(
// //                         'Forgotten password?',
// //                         style: TextStyle(
// //                           color: AppColors.textSecondary,
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //                 const SizedBox(height: 24),
// //                 // Login Button
// //                 Consumer<AuthProvider>(
// //                   builder: (context, authProvider, _) {
// //                     return CustomButton(
// //                       text: 'Log in',
// //                       onPressed: _handleLogin,
// //                       isLoading: authProvider.isLoading,
// //                     );
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),
// //                 // Switch Login Method
// //                 Center(
// //                   child: TextButton(
// //                     onPressed: () {
// //                       setState(() {
// //                         _isPasswordLogin = !_isPasswordLogin;
// //                         _passwordController.clear();
// //                       });
// //                     },
// //                     child: Text(
// //                       _isPasswordLogin
// //                           ? 'Login with OTP instead'
// //                           : 'Login with Password instead',
// //                       style: const TextStyle(
// //                         color: AppColors.primary,
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 24),
// //                 // Divider
// //                 const Row(
// //                   children: [
// //                     Expanded(child: Divider()),
// //                     Padding(
// //                       padding: EdgeInsets.symmetric(horizontal: 16),
// //                       child: Text(
// //                         'OR',
// //                         style: TextStyle(color: AppColors.textLight),
// //                       ),
// //                     ),
// //                     Expanded(child: Divider()),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 24),
// //                 // Create Account Button
// //                 CustomButton(
// //                   text: 'Create new Account',
// //                   onPressed: () {
// //                     Navigator.pushNamed(context, AppRoutes.signup);
// //                   },
// //                   isOutlined: true,
// //                 ),
// //                 const SizedBox(height: 24),
// //                 // Footer Links
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     TextButton(
// //                       onPressed: () {},
// //                       child: const Text(
// //                         'About',
// //                         style: TextStyle(
// //                           color: AppColors.textSecondary,
// //                           fontSize: 12,
// //                         ),
// //                       ),
// //                     ),
// //                     TextButton(
// //                       onPressed: () {},
// //                       child: const Text(
// //                         'Help',
// //                         style: TextStyle(
// //                           color: AppColors.textSecondary,
// //                           fontSize: 12,
// //                         ),
// //                       ),
// //                     ),
// //                     TextButton(
// //                       onPressed: () {},
// //                       child: const Text(
// //                         'More',
// //                         style: TextStyle(
// //                           color: AppColors.textSecondary,
// //                           fontSize: 12,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }