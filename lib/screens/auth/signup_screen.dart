import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../data/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {
          'email': _emailController.text.trim(),
          'purpose': 'register',
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Signup failed'),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                // 🔹 Logo (image jaisa)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Create new account',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 First Name
                CustomTextField(
                  hint: 'First Name',
                  controller: _firstNameController,
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Enter first name' : null,
                ),

                const SizedBox(height: 16),

                // 🔹 Last Name
                CustomTextField(
                  hint: 'Last Name',
                  controller: _lastNameController,
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Enter last name' : null,
                ),

                const SizedBox(height: 16),

                // 🔹 Phone
                CustomTextField(
                  hint: 'Mobile Number (optional)',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                // 🔹 Email
                CustomTextField(
                  hint: 'Email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 🔹 Password
                CustomTextField(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'Min 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // 🔹 Sign up button
                Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    return CustomButton(
                      text: 'Sign up',
                      onPressed: _handleSignup,
                      isLoading: auth.isLoading,
                    );
                  },
                ),

                const SizedBox(height: 30),

                // 🔹 Bottom links
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



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../data/providers/auth_provider.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final _nameController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _mobileController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _otpController = TextEditingController();
//
//   String _gender = 'Female';
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _dobController.dispose();
//     _mobileController.dispose();
//     _emailController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const SizedBox(height: 40),
//
//                 // 🔹 LOGO (exact image style)
//                 Container(
//                   width: 90,
//                   height: 90,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(22),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 20,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(22),
//                     child: Image.asset(
//                       'assets/logo.png',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // 🔹 Title
//                 Text(
//                   'Create new account',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.primary,
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 // 🔹 Name
//                 _inputField(
//                   label: 'Name',
//                   controller: _nameController,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // 🔹 DOB + Gender
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _inputField(
//                         label: 'Date of Birth',
//                         controller: _dobController,
//                         hint: 'xx/xx/xxxx',
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 4),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade400),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<String>(
//                             value: _gender,
//                             items: const [
//                               DropdownMenuItem(
//                                   value: 'Female', child: Text('Female')),
//                               DropdownMenuItem(
//                                   value: 'Male', child: Text('Male')),
//                             ],
//                             onChanged: (value) {
//                               setState(() => _gender = value!);
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // 🔹 Mobile
//                 _inputField(
//                   label: 'Mobile Number',
//                   controller: _mobileController,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // 🔹 Email
//                 _inputField(
//                   label: 'Email address',
//                   controller: _emailController,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // 🔹 OTP
//                 Stack(
//                   alignment: Alignment.centerRight,
//                   children: [
//                     _inputField(
//                       label: 'Enter OTP',
//                       controller: _otpController,
//                       hint: 'XXX XXX',
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.only(right: 16),
//                       child: Icon(
//                         Icons.check_box,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 28),
//
//                 // 🔹 Sign up button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     onPressed: () {},
//                     child: const Text(
//                       'Sign up',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 // 🔹 Bottom Links
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: const [
//                     Text('About', style: TextStyle(fontSize: 12)),
//                     SizedBox(width: 16),
//                     Text('Help', style: TextStyle(fontSize: 12)),
//                     SizedBox(width: 16),
//                     Text('More', style: TextStyle(fontSize: 12)),
//                   ],
//                 ),
//
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // 🔹 Common input field
//   Widget _inputField({
//     required String label,
//     required TextEditingController controller,
//     String? hint,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
// }
//
//
//
// // // lib/screens/auth/signup_screen.dart - EMAIL VERSION
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../../core/constants/app_colors.dart';
// // import '../../core/widgets/custom_button.dart';
// // import '../../core/widgets/custom_textfield.dart';
// // import '../../data/providers/auth_provider.dart';
// // import '../../config/routes.dart';
// //
// // class SignupScreen extends StatefulWidget {
// //   const SignupScreen({super.key});
// //
// //   @override
// //   State<SignupScreen> createState() => _SignupScreenState();
// // }
// //
// // class _SignupScreenState extends State<SignupScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _firstNameController = TextEditingController();
// //   final _lastNameController = TextEditingController();
// //   final _emailController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   final _phoneController = TextEditingController(); // Optional
// //
// //   @override
// //   void dispose() {
// //     _firstNameController.dispose();
// //     _lastNameController.dispose();
// //     _emailController.dispose();
// //     _passwordController.dispose();
// //     _phoneController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _handleSignup() async {
// //     if (!_formKey.currentState!.validate()) return;
// //
// //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// //     authProvider.clearError();
// //
// //     // Call register API (it will send OTP to email)
// //     final result = await authProvider.register(
// //       firstName: _firstNameController.text.trim(),
// //       lastName: _lastNameController.text.trim(),
// //       email: _emailController.text.trim(),
// //       password: _passwordController.text,
// //       phone: _phoneController.text
// //           .trim()
// //           .isNotEmpty
// //           ? _phoneController.text.trim()
// //           : null,
// //     );
// //
// //     if (!mounted) return;
// //
// //     if (result['success'] == true) {
// //       // Navigate to OTP screen
// //       Navigator.pushNamed(
// //         context,
// //         '/otp', // Change this to your actual OTP route
// //         arguments: {
// //           'email': result['email'] ?? _emailController.text.trim(),
// //           'userId': result['userId'],
// //           'phone': _phoneController.text
// //               .trim()
// //               .isNotEmpty
// //               ? _phoneController.text.trim()
// //               : null,
// //           'purpose': 'register',
// //         },
// //       );
// //
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(result['message'] ?? 'OTP sent to your email'),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(result['message'] ?? 'Registration failed'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: const Text(
// //           'Create Account',
// //           style: TextStyle(
// //             color: AppColors.textPrimary,
// //             fontSize: 18,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //       ),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(24),
// //           child: Form(
// //             key: _formKey,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const SizedBox(height: 20),
// //
// //                 // Welcome text
// //                 const Text(
// //                   'Join ClickME!',
// //                   style: TextStyle(
// //                     fontSize: 24,
// //                     fontWeight: FontWeight.bold,
// //                     color: AppColors.textPrimary,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 const Text(
// //                   'Create your account to connect with friends',
// //                   style: TextStyle(
// //                     color: AppColors.textSecondary,
// //                     fontSize: 14,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 32),
// //
// //                 // First Name
// //                 CustomTextField(
// //                   label: 'First Name *',
// //                   hint: 'John',
// //                   controller: _firstNameController,
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter first name';
// //                     }
// //                     if (value.length < 2) {
// //                       return 'Name must be at least 2 characters';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),
// //
// //                 // Last Name
// //                 CustomTextField(
// //                   label: 'Last Name *',
// //                   hint: 'Doe',
// //                   controller: _lastNameController,
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Please enter last name';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),
// //
// //                 // Email (Required)
// //                 CustomTextField(
// //                   label: 'Email Address *',
// //                   hint: 'your.email@example.com',
// //                   controller: _emailController,
// //                   keyboardType: TextInputType.emailAddress,
// //                   prefixIcon: const Icon(Icons.email, size: 20),
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Email is required';
// //                     }
// //                     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
// //                       return 'Enter valid email address';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),
// //
// //                 // Password
// //                 CustomTextField(
// //                   label: 'Password *',
// //                   hint: 'Create a strong password',
// //                   controller: _passwordController,
// //                   obscureText: true,
// //                   prefixIcon: const Icon(Icons.lock, size: 20),
// //                   validator: (value) {
// //                     if (value == null || value.isEmpty) {
// //                       return 'Password is required';
// //                     }
// //                     if (value.length < 6) {
// //                       return 'Password must be at least 6 characters';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),
// //
// //                 // Phone (Optional)
// //                 CustomTextField(
// //                   label: 'Phone Number (Optional)',
// //                   hint: '1234567890',
// //                   controller: _phoneController,
// //                   keyboardType: TextInputType.phone,
// //                   prefixIcon: const Icon(Icons.phone, size: 20),
// //                 ),
// //                 const SizedBox(height: 24),
// //
// //                 // Info Box
// //                 Container(
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: AppColors.primary.withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(8),
// //                     border: Border.all(
// //                         color: AppColors.primary.withOpacity(0.3)),
// //                   ),
// //                   child: Row(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Icon(
// //                         Icons.info_outline,
// //                         color: AppColors.primary,
// //                         size: 20,
// //                       ),
// //                       const SizedBox(width: 8),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               'Important Information',
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: AppColors.primary,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 4),
// //                             Text(
// //                               'â€¢ OTP will be sent to your email for verification\n'
// //                                   'â€¢ Phone number is optional for account recovery\n'
// //                                   'â€¢ Use strong password for security',
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: AppColors.textSecondary,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 24),
// //
// //                 // Terms and Conditions
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Checkbox(
// //                       value: true,
// //                       onChanged: (value) {},
// //                       activeColor: AppColors.primary,
// //                     ),
// //                     const Expanded(
// //                       child: Text(
// //                         'I agree to Terms of Service and Privacy Policy',
// //                         style: TextStyle(
// //                           color: AppColors.textSecondary,
// //                           fontSize: 12,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 24),
// //
// //                 // Sign Up Button
// //                 Consumer<AuthProvider>(
// //                   builder: (context, authProvider, _) {
// //                     return CustomButton(
// //                       text: 'Create Account',
// //                       onPressed: _handleSignup,
// //                       isLoading: authProvider.isLoading,
// //                     );
// //                   },
// //                 ),
// //                 const SizedBox(height: 24),
// //
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
// //
// //                 // Already have account
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     const Text(
// //                       'Already have an account? ',
// //                       style: TextStyle(
// //                         color: AppColors.textSecondary,
// //                         fontSize: 14,
// //                       ),
// //                     ),
// //                     TextButton(
// //                       onPressed: () => Navigator.pushNamed(context, '/login'),
// //                       child: const Text(
// //                         'Log in',
// //                         style: TextStyle(
// //                           color: AppColors.primary,
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 20),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
