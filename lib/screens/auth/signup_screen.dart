import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../data/providers/auth_provider.dart';
import '../../config/routes.dart';

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
  final _phoneController = TextEditingController(); // Optional

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

    // Call register API (it will send OTP)
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

    if (result != null && result['success'] == true) {
      // Navigate to OTP screen
      Navigator.pushNamed(
        context,
        AppRoutes.otp,
        arguments: {
          'email': result['email'],
          'userId': result['userId'],
          'phone': _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          'purpose': 'register',
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
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
          content: Text(authProvider.error ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // App Logo
                Container(
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
                const SizedBox(height: 16),
                const Text(
                  'Create new account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // First Name
                CustomTextField(
                  label: 'First Name',
                  hint: 'John',
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Last Name
                CustomTextField(
                  label: 'Last Name',
                  hint: 'Doe',
                  controller: _lastNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  label: 'Email address',
                  hint: 'john@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Enter valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone (Optional)
                CustomTextField(
                  label: 'Phone Number (Optional)',
                  hint: '1234567890',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                // Info text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'OTP will be sent to your email for verification',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      text: 'Sign up',
                      onPressed: _handleSignup,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/widgets/custom_button.dart';
// import '../../core/widgets/custom_textfield.dart';
// import '../../data/providers/auth_provider.dart';
// import '../../config/routes.dart';
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
//   final _nameController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _mobileController = TextEditingController();
//   final _emailController = TextEditingController();
//
//   String _selectedGender = 'Female';
//   final List<String> _genders = ['Male', 'Female', 'Other'];
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _dobController.dispose();
//     _mobileController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000),
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       setState(() {
//         _dobController.text =
//         '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
//       });
//     }
//   }
//
//   Future<void> _handleSignup() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//
//     // Send OTP for verification
//     final success = await authProvider.sendOtp(
//       mobileOrEmail: _mobileController.text.trim(),
//       purpose: 'register',
//     );
//
//     if (!mounted) return;
//
//     if (success) {
//       Navigator.pushNamed(
//         context,
//         AppRoutes.otp,
//         arguments: {
//           'mobile': _mobileController.text.trim(),
//           'email': _emailController.text.trim(),
//           'purpose': 'register',
//           'name': _nameController.text.trim(),
//           'gender': _selectedGender,
//           'dob': _dobController.text,
//         },
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(authProvider.error ?? 'Failed to send OTP')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 // App Logo
//                 Container(
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
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Title
//                 const Text(
//                   'Create new account',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 // Name Field
//                 CustomTextField(
//                   label: 'Name',
//                   hint: 'XXXX',
//                   controller: _nameController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 // DOB and Gender Row
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CustomTextField(
//                         label: 'Date of Birth',
//                         hint: 'xx/xx/xxxx',
//                         controller: _dobController,
//                         readOnly: true,
//                         onChanged: (_) => _selectDate(),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Select DOB';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Gender',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.textSecondary,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             decoration: BoxDecoration(
//                               color: AppColors.cardBackground,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: AppColors.border),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: _selectedGender,
//                                 isExpanded: true,
//                                 icon: const Icon(Icons.keyboard_arrow_down),
//                                 items: _genders.map((String gender) {
//                                   return DropdownMenuItem<String>(
//                                     value: gender,
//                                     child: Text(gender),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     _selectedGender = newValue!;
//                                   });
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Mobile Field
//                 CustomTextField(
//                   label: 'Mobile Number',
//                   hint: 'XXXX',
//                   controller: _mobileController,
//                   keyboardType: TextInputType.phone,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter mobile number';
//                     }
//                     if (value.length < 10) {
//                       return 'Enter valid mobile number';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 // Email Field
//                 CustomTextField(
//                   label: 'Email address',
//                   hint: 'xxxx@xx.com',
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value != null && value.isNotEmpty) {
//                       if (!value.contains('@')) {
//                         return 'Enter valid email';
//                       }
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 // OTP Info
//                 Row(
//                   children: [
//                     const Text(
//                       'Enter OTP',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                     const Spacer(),
//                     Icon(
//                       Icons.verified_user,
//                       size: 20,
//                       color: AppColors.primary.withOpacity(0.5),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: AppColors.cardBackground,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppColors.border),
//                   ),
//                   child: Row(
//                     children: [
//                       const Text(
//                         'XXX XXX',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: AppColors.textLight,
//                           letterSpacing: 2,
//                         ),
//                       ),
//                       const Spacer(),
//                       Icon(
//                         Icons.check_circle_outline,
//                         color: AppColors.primary.withOpacity(0.5),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 // Sign Up Button
//                 Consumer<AuthProvider>(
//                   builder: (context, authProvider, _) {
//                     return CustomButton(
//                       text: 'Sign up',
//                       onPressed: _handleSignup,
//                       isLoading: authProvider.isLoading,
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 // Footer
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