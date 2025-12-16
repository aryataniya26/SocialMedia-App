import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/providers/auth_provider.dart';
import '../../config/routes.dart';
import '../../config/app_config.dart';

class OtpScreen extends StatefulWidget {
  final String? email;
  final String? userId;
  final String? phone;
  final String purpose; // 'register' or 'login'
  final String? firstName;
  final String? lastName;
  final String? mobile; // For compatibility

  const OtpScreen({
    super.key,
    this.email,
    this.userId,
    this.phone,
    required this.purpose,
    this.firstName,
    this.lastName,
    this.mobile,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _remainingSeconds = AppConfig.otpExpirySeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = AppConfig.otpExpirySeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _getTimerText() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleResend() async {
    if (_remainingSeconds > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait before requesting a new OTP'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please go back and try again'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _handleVerify() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    if (widget.purpose == 'register') {
      // Verify Registration
      success = await authProvider.verifyRegistration(
        email: widget.email ?? '',
        userId: widget.userId ?? '',
        otp: otp,
        phone: widget.phone,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Invalid OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Verify Login
      success = await authProvider.verifyLoginOtp(
        email: widget.email ?? '',
        otp: otp,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Invalid OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // App Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.verified_user,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                widget.purpose == 'register'
                    ? 'Verify Your Account'
                    : 'Verify Login',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Enter the 6-digit code sent to',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              // OTP Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Timer
              if (_remainingSeconds > 0)
                Text(
                  'OTP expires in ${_getTimerText()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                const Text(
                  'OTP has expired',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 8),

              // Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive code? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: _handleResend,
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        fontSize: 14,
                        color: _remainingSeconds > 0
                            ? AppColors.textLight
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Verify Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return CustomButton(
                    text: 'Verify',
                    onPressed: _handleVerify,
                    isLoading: authProvider.isLoading,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:async';
// import '../../core/constants/app_colors.dart';
// import '../../core/widgets/custom_button.dart';
// import '../../data/providers/auth_provider.dart';
// import '../../config/routes.dart';
// import '../../config/app_config.dart';
//
// class OtpScreen extends StatefulWidget {
//   final String? email;
//   final String? userId;
//   final String? phone;
//   final String purpose; // 'register' or 'login'
//   final String? firstName;
//   final String? lastName;
//
//   const OtpScreen({
//     super.key,
//     this.email,
//     this.userId,
//     this.phone,
//     required this.purpose,
//     this.firstName,
//     this.lastName, required mobile,
//   });
//
//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }
//
// class _OtpScreenState extends State<OtpScreen> {
//   final List<TextEditingController> _otpControllers =
//   List.generate(6, (_) => TextEditingController());
//   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
//
//   int _remainingSeconds = AppConfig.otpExpirySeconds; // 2 minutes
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     for (var controller in _otpControllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }
//
//   void _startTimer() {
//     _timer?.cancel();
//     setState(() {
//       _remainingSeconds = AppConfig.otpExpirySeconds;
//     });
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingSeconds > 0) {
//         setState(() {
//           _remainingSeconds--;
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }
//
//   String _getTimerText() {
//     final minutes = _remainingSeconds ~/ 60;
//     final seconds = _remainingSeconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//   }
//
//   Future<void> _handleResend() async {
//     if (_remainingSeconds > 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please wait before requesting a new OTP'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }
//
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//
//     if (widget.purpose == 'register') {
//       // Re-register to get new OTP
//       final result = await authProvider.register(
//         firstName: widget.firstName ?? '',
//         lastName: widget.lastName ?? '',
//         email: widget.email ?? '',
//         password: '', // Need to store password or re-ask
//         phone: widget.phone,
//       );
//
//       if (!mounted) return;
//
//       if (result != null && result['success'] == true) {
//         _startTimer();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('OTP resent successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } else {
//       // Re-login to get new OTP
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please go back and login again'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }
//
//   Future<void> _handleVerify() async {
//     final otp = _otpControllers.map((c) => c.text).join();
//
//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter complete 6-digit OTP'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     bool success = false;
//
//     if (widget.purpose == 'register') {
//       // Verify Registration
//       success = await authProvider.verifyRegistration(
//         email: widget.email ?? '',
//         userId: widget.userId ?? '',
//         otp: otp,
//         phone: widget.phone,
//       );
//
//       if (!mounted) return;
//
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Account verified successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         // Navigate to profile setup
//         Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(authProvider.error ?? 'Invalid OTP'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } else {
//       // Verify Login
//       success = await authProvider.verifyLoginOtp(
//         email: widget.email ?? '',
//         otp: otp,
//       );
//
//       if (!mounted) return;
//
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Login successful!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         // Navigate to home
//         Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(authProvider.error ?? 'Invalid OTP'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
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
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             children: [
//               // App Logo
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   gradient: AppColors.primaryGradient,
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: const Icon(
//                   Icons.verified_user,
//                   size: 30,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               // Title
//               Text(
//                 widget.purpose == 'register'
//                     ? 'Verify Your Account'
//                     : 'Verify Login',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//
//               // Subtitle
//               Text(
//                 'Enter the 6-digit code sent to',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 widget.email ?? '',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.primary,
//                 ),
//               ),
//               const SizedBox(height: 32),
//
//               // OTP Input
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(6, (index) {
//                   return SizedBox(
//                     width: 45,
//                     child: TextField(
//                       controller: _otpControllers[index],
//                       focusNode: _focusNodes[index],
//                       textAlign: TextAlign.center,
//                       keyboardType: TextInputType.number,
//                       maxLength: 1,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       decoration: InputDecoration(
//                         counterText: '',
//                         filled: true,
//                         fillColor: AppColors.cardBackground,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: AppColors.border),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(
//                             color: AppColors.primary,
//                             width: 2,
//                           ),
//                         ),
//                       ),
//                       onChanged: (value) {
//                         if (value.isNotEmpty && index < 5) {
//                           _focusNodes[index + 1].requestFocus();
//                         } else if (value.isEmpty && index > 0) {
//                           _focusNodes[index - 1].requestFocus();
//                         }
//                       },
//                     ),
//                   );
//                 }),
//               ),
//               const SizedBox(height: 24),
//
//               // Timer and Resend
//               if (_remainingSeconds > 0)
//                 Text(
//                   'OTP expires in ${_getTimerText()}',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textSecondary,
//                   ),
//                 )
//               else
//                 const Text(
//                   'OTP has expired',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.error,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               const SizedBox(height: 8),
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Didn't receive code? ",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: _handleResend,
//                     child: Text(
//                       'Resend',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: _remainingSeconds > 0
//                             ? AppColors.textLight
//                             : AppColors.primary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//
//               // Verify Button
//               Consumer<AuthProvider>(
//                 builder: (context, authProvider, _) {
//                   return CustomButton(
//                     text: 'Verify',
//                     onPressed: _handleVerify,
//                     isLoading: authProvider.isLoading,
//                   );
//                 },
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'dart:async';
// // import '../../core/constants/app_colors.dart';
// // import '../../core/widgets/custom_button.dart';
// // import '../../data/providers/auth_provider.dart';
// // import '../../config/routes.dart';
// //
// // class OtpScreen extends StatefulWidget {
// //   final String? mobile;
// //   final String? email;
// //   final String purpose;
// //
// //   const OtpScreen({
// //     super.key,
// //     this.mobile,
// //     this.email,
// //     required this.purpose,
// //   });
// //
// //   @override
// //   State<OtpScreen> createState() => _OtpScreenState();
// // }
// //
// // class _OtpScreenState extends State<OtpScreen> {
// //   final List<TextEditingController> _otpControllers =
// //   List.generate(4, (_) => TextEditingController());
// //   final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
// //
// //   int _remainingSeconds = 600; // 10 minutes
// //   Timer? _timer;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _startTimer();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _timer?.cancel();
// //     for (var controller in _otpControllers) {
// //       controller.dispose();
// //     }
// //     for (var node in _focusNodes) {
// //       node.dispose();
// //     }
// //     super.dispose();
// //   }
// //
// //   void _startTimer() {
// //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       if (_remainingSeconds > 0) {
// //         setState(() {
// //           _remainingSeconds--;
// //         });
// //       } else {
// //         timer.cancel();
// //       }
// //     });
// //   }
// //
// //   String _getTimerText() {
// //     final minutes = _remainingSeconds ~/ 60;
// //     final seconds = _remainingSeconds % 60;
// //     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
// //   }
// //
// //   Future<void> _handleResend() async {
// //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// //
// //     final success = await authProvider.sendOtp(
// //       mobileOrEmail: widget.mobile ?? widget.email ?? '',
// //       purpose: widget.purpose,
// //     );
// //
// //     if (!mounted) return;
// //
// //     if (success) {
// //       setState(() {
// //         _remainingSeconds = 600;
// //       });
// //       _startTimer();
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('OTP sent successfully')),
// //       );
// //     }
// //   }
// //
// //   Future<void> _handleVerify() async {
// //     final otp = _otpControllers.map((c) => c.text).join();
// //
// //     if (otp.length != 4) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Please enter complete OTP')),
// //       );
// //       return;
// //     }
// //
// //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// //
// //     final success = await authProvider.verifyOtp(
// //       mobileOrEmail: widget.mobile ?? widget.email ?? '',
// //       otp: otp,
// //     );
// //
// //     if (!mounted) return;
// //
// //     if (success) {
// //       if (widget.purpose == 'register') {
// //         Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
// //       } else {
// //         Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
// //       }
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text(authProvider.error ?? 'Invalid OTP')),
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
// //       ),
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.all(24),
// //           child: Column(
// //             children: [
// //               // App Logo
// //               Container(
// //                 width: 60,
// //                 height: 60,
// //                 decoration: BoxDecoration(
// //                   gradient: AppColors.primaryGradient,
// //                   borderRadius: BorderRadius.circular(15),
// //                 ),
// //                 child: const Icon(
// //                   Icons.touch_app_rounded,
// //                   size: 30,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //               const SizedBox(height: 24),
// //               // Title
// //               const Text(
// //                 'Log in via OTP',
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.w600,
// //                   color: AppColors.textPrimary,
// //                 ),
// //               ),
// //               const SizedBox(height: 32),
// //               // Mobile/Email Display
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: AppColors.cardBackground,
// //                   borderRadius: BorderRadius.circular(12),
// //                   border: Border.all(color: AppColors.border),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Text(
// //                       widget.mobile ?? widget.email ?? '',
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 24),
// //               // OTP Input
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                 children: List.generate(4, (index) {
// //                   return SizedBox(
// //                     width: 60,
// //                     child: TextField(
// //                       controller: _otpControllers[index],
// //                       focusNode: _focusNodes[index],
// //                       textAlign: TextAlign.center,
// //                       keyboardType: TextInputType.number,
// //                       maxLength: 1,
// //                       style: const TextStyle(
// //                         fontSize: 24,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                       decoration: InputDecoration(
// //                         counterText: '',
// //                         filled: true,
// //                         fillColor: AppColors.cardBackground,
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                           borderSide: const BorderSide(color: AppColors.border),
// //                         ),
// //                         focusedBorder: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                           borderSide: const BorderSide(
// //                             color: AppColors.primary,
// //                             width: 2,
// //                           ),
// //                         ),
// //                       ),
// //                       onChanged: (value) {
// //                         if (value.isNotEmpty && index < 3) {
// //                           _focusNodes[index + 1].requestFocus();
// //                         } else if (value.isEmpty && index > 0) {
// //                           _focusNodes[index - 1].requestFocus();
// //                         }
// //                       },
// //                     ),
// //                   );
// //                 }),
// //               ),
// //               const SizedBox(height: 16),
// //               // Timer and Resend
// //               Text(
// //                 'The OTP will expire in ${_getTimerText()} mins. Click here to ',
// //                 style: const TextStyle(
// //                   fontSize: 12,
// //                   color: AppColors.textSecondary,
// //                 ),
// //               ),
// //               TextButton(
// //                 onPressed: _remainingSeconds > 0 ? null : _handleResend,
// //                 child: Text(
// //                   'resend',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     color: _remainingSeconds > 0
// //                         ? AppColors.textLight
// //                         : AppColors.primary,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ),
// //               const Spacer(),
// //               // Verify Button
// //               Consumer<AuthProvider>(
// //                 builder: (context, authProvider, _) {
// //                   return CustomButton(
// //                     text: 'Log in',
// //                     onPressed: _handleVerify,
// //                     isLoading: authProvider.isLoading,
// //                   );
// //                 },
// //               ),
// //               const SizedBox(height: 16),
// //               // Back to Login
// //               CustomButton(
// //                 text: 'Create new Account',
// //                 onPressed: () {
// //                   Navigator.pushNamed(context, AppRoutes.signup);
// //                 },
// //                 isOutlined: true,
// //               ),
// //               const SizedBox(height: 24),
// //               // Footer
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   TextButton(
// //                     onPressed: () {},
// //                     child: const Text(
// //                       'About',
// //                       style: TextStyle(
// //                         color: AppColors.textSecondary,
// //                         fontSize: 12,
// //                       ),
// //                     ),
// //                   ),
// //                   TextButton(
// //                     onPressed: () {},
// //                     child: const Text(
// //                       'Help',
// //                       style: TextStyle(
// //                         color: AppColors.textSecondary,
// //                         fontSize: 12,
// //                       ),
// //                     ),
// //                   ),
// //                   TextButton(
// //                     onPressed: () {},
// //                     child: const Text(
// //                       'More',
// //                       style: TextStyle(
// //                         color: AppColors.textSecondary,
// //                         fontSize: 12,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }