import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/providers/auth_provider.dart';
import '../../config/routes.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String? userId;
  final String purpose; // 'register' or 'login'

  const OtpScreen({
    super.key,
    required this.email,
    this.userId,
    required this.purpose,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _remainingSeconds = 120; // 2 minutes as per API
  Timer? _timer;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes[0].hasFocus == false) {
        _focusNodes[0].requestFocus();
      }
    });
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
    setState(() => _remainingSeconds = 120);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
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

  Future<void> _handleVerify() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showError('Please enter complete 6-digit OTP');
      return;
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      _showError('Please enter valid 6-digit OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (widget.purpose == 'register') {
        await _handleRegistrationVerification(authProvider, otp);
      } else {
        await _handleLoginVerification(authProvider, otp);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _handleRegistrationVerification(
      AuthProvider authProvider, String otp) async {

    if (widget.userId == null) {
      _showError('User ID not found');
      return;
    }

    final result = await authProvider.verifyRegistrationOtp(
      email: widget.email,
      userId: widget.userId!,
      otp: otp,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      _showSuccess('Account verified successfully!');

      // Navigate to login after successful registration
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
    } else {
      _showError(result['message'] ?? 'Invalid OTP');
    }
  }

  Future<void> _handleLoginVerification(
      AuthProvider authProvider, String otp) async {

    final result = await authProvider.verifyLoginOtp(
      email: widget.email,
      otp: otp,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      _showSuccess('Login successful!');

      // Navigate to home
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
      });
    } else {
      _showError(result['message'] ?? 'Invalid OTP');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
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
        title: Text(
          widget.purpose == 'register' ? 'Verify Account' : 'Verify Login',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                widget.purpose == 'register'
                    ? 'Verify Your Account'
                    : 'Verify Login',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit OTP sent to:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              const Text(
                'Enter 6-digit OTP',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _errorMessage != null
                                ? Colors.red.withOpacity(0.5)
                                : AppColors.border,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (value.isNotEmpty && index == 5) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _handleVerify();
                          });
                        }
                        if (_errorMessage != null && value.isNotEmpty) {
                          setState(() => _errorMessage = null);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _remainingSeconds > 0
                        ? AppColors.border
                        : Colors.red.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _remainingSeconds > 0 ? 'OTP Expires In' : 'OTP Expired',
                          style: TextStyle(
                            fontSize: 14,
                            color: _remainingSeconds > 0
                                ? AppColors.textSecondary
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTimerText(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _remainingSeconds > 0
                                ? AppColors.textPrimary
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _remainingSeconds <= 30 ? () {} : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _remainingSeconds <= 30
                            ? AppColors.primary
                            : AppColors.textLight.withOpacity(0.3),
                        foregroundColor: _remainingSeconds <= 30
                            ? Colors.white
                            : AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CustomButton(
                text: widget.purpose == 'register'
                    ? 'Verify Account'
                    : 'Verify & Login',
                onPressed: _handleVerify,
                isLoading: _isVerifying,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isVerifying ? null : () => Navigator.pop(context),
                child: const Center(
                  child: Text(
                    'Go Back',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      )
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
//   final String email;
//   final String? userId; // For registration
//   final String purpose; // 'register' or 'login'
//
//   const OtpScreen({
//     super.key,
//     required this.email,
//     this.userId,
//     required this.purpose,
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
//   int _remainingSeconds = 120; // 2 minutes
//   Timer? _timer;
//   bool _isVerifying = false;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//     // Auto-focus first OTP field
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_focusNodes[0].hasFocus == false) {
//         _focusNodes[0].requestFocus();
//       }
//     });
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
//       _remainingSeconds = 120;
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
//     if (_remainingSeconds > 30) {
//       _showError('Please wait ${_remainingSeconds - 30} seconds before resending');
//       return;
//     }
//
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//
//     try {
//       if (widget.purpose == 'register') {
//         // TODO: Implement resend registration OTP
//         _showSuccess('Resend feature coming soon');
//       } else {
//         // For login, user needs to login again
//         _showError('Please go back and login again to receive new OTP');
//         return;
//       }
//     } catch (e) {
//       _showError('Failed to resend OTP: ${e.toString()}');
//     }
//
//     _startTimer();
//   }
//
//   Future<void> _handleVerify() async {
//     final otp = _otpControllers.map((c) => c.text).join();
//
//     if (otp.length != 6) {
//       _showError('Please enter complete 6-digit OTP');
//       return;
//     }
//
//     if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
//       _showError('Please enter valid 6-digit OTP');
//       return;
//     }
//
//     setState(() {
//       _isVerifying = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//
//       if (widget.purpose == 'register') {
//         await _handleRegistrationVerification(authProvider, otp);
//       } else {
//         await _handleLoginVerification(authProvider, otp);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       _showError('Verification error: ${e.toString()}');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isVerifying = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _handleRegistrationVerification(
//       AuthProvider authProvider, String otp) async {
//
//     if (widget.userId == null || widget.userId!.isEmpty) {
//       _showError('User ID not found');
//       return;
//     }
//
//     final result = await authProvider.verifyRegistrationOtp(
//       email: widget.email,
//       userId: widget.userId!,
//       otp: otp,
//     );
//
//     if (!mounted) return;
//
//     if (result['success'] == true) {
//       _showSuccess('Account verified successfully!');
//
//       // After registration verification, user needs to login
//       Future.delayed(Duration(milliseconds: 1500), () {
//         Navigator.pushReplacementNamed(
//           context,
//           '/login',
//         );
//       });
//     } else {
//       _showError(result['message'] ?? 'Invalid OTP');
//     }
//   }
//
//   Future<void> _handleLoginVerification(
//       AuthProvider authProvider, String otp) async {
//
//     final result = await authProvider.verifyLoginOtp(
//       email: widget.email,
//       otp: otp,
//     );
//
//     if (!mounted) return;
//
//     if (result['success'] == true) {
//       _showSuccess('Login successful!');
//
//       // Navigate to home screen
//       _navigateToHome();
//     } else {
//       _showError(result['message'] ?? 'Invalid OTP');
//     }
//   }
//
//   void _navigateToHome() {
//     Navigator.pushNamedAndRemoveUntil(
//       context,
//       '/home', // Change to your home route
//           (route) => false,
//     );
//   }
//
//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _showError(String message) {
//     setState(() {
//       _errorMessage = message;
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   void _autoSubmitOnComplete() {
//     final otp = _otpControllers.map((c) => c.text).join();
//     if (otp.length == 6 && RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
//       _handleVerify();
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
//         title: Text(
//           widget.purpose == 'register' ? 'Verify Account' : 'Verify Login',
//           style: const TextStyle(
//             color: AppColors.textPrimary,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 20),
//
//               // Title
//               Text(
//                 widget.purpose == 'register'
//                     ? 'Verify Your Account'
//                     : 'Verify Login',
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//
//               // Subtitle
//               Text(
//                 widget.purpose == 'register'
//                     ? 'Complete your registration by entering the OTP'
//                     : 'Complete your login by entering the OTP',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               const SizedBox(height: 4),
//
//               // Email info
//               Row(
//                 children: [
//                   Text(
//                     'Sent to: ',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   Text(
//                     widget.email,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Error Message
//               if (_errorMessage != null) ...[
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.red.withOpacity(0.3)),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.error_outline,
//                         color: Colors.red,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           _errorMessage!,
//                           style: const TextStyle(
//                             color: Colors.red,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//
//               const SizedBox(height: 32),
//
//               // OTP Input Section
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Enter 6-digit OTP',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textSecondary,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//
//                   // OTP Boxes
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: List.generate(6, (index) {
//                       return SizedBox(
//                         width: 48,
//                         height: 56,
//                         child: TextField(
//                           controller: _otpControllers[index],
//                           focusNode: _focusNodes[index],
//                           textAlign: TextAlign.center,
//                           keyboardType: TextInputType.number,
//                           maxLength: 1,
//                           style: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textPrimary,
//                           ),
//                           decoration: InputDecoration(
//                             counterText: '',
//                             filled: true,
//                             fillColor: AppColors.cardBackground,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: const BorderSide(
//                                 color: AppColors.primary,
//                                 width: 2,
//                               ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: BorderSide(
//                                 color: _errorMessage != null
//                                     ? Colors.red.withOpacity(0.5)
//                                     : AppColors.border,
//                               ),
//                             ),
//                           ),
//                           onChanged: (value) {
//                             if (value.isNotEmpty && index < 5) {
//                               _focusNodes[index + 1].requestFocus();
//                             } else if (value.isEmpty && index > 0) {
//                               _focusNodes[index - 1].requestFocus();
//                             }
//
//                             // Auto-submit when 6 digits are entered
//                             if (value.isNotEmpty && index == 5) {
//                               Future.delayed(const Duration(milliseconds: 100), () {
//                                 _autoSubmitOnComplete();
//                               });
//                             }
//
//                             // Clear error when user starts typing
//                             if (_errorMessage != null && value.isNotEmpty) {
//                               setState(() {
//                                 _errorMessage = null;
//                               });
//                             }
//                           },
//                         ),
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 32),
//
//               // Timer Section
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.cardBackground,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: _remainingSeconds > 0
//                         ? AppColors.border
//                         : AppColors.error.withOpacity(0.3),
//                     width: 1.5,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _remainingSeconds > 0 ? 'OTP Expires In' : 'OTP Expired',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: _remainingSeconds > 0
//                                 ? AppColors.textSecondary
//                                 : AppColors.error,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _getTimerText(),
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: _remainingSeconds > 0
//                                 ? AppColors.textPrimary
//                                 : AppColors.error,
//                           ),
//                         ),
//                       ],
//                     ),
//                     ElevatedButton(
//                       onPressed: _remainingSeconds <= 30 ? _handleResend : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _remainingSeconds <= 30
//                             ? AppColors.primary
//                             : AppColors.textLight.withOpacity(0.3),
//                         foregroundColor: _remainingSeconds <= 30
//                             ? Colors.white
//                             : AppColors.textSecondary,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 10,
//                         ),
//                         elevation: 0,
//                       ),
//                       child: const Text(
//                         'Resend OTP',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//
//               // Resend Info
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4),
//                 child: Text(
//                   _remainingSeconds > 30
//                       ? 'You can request a new code in ${_remainingSeconds - 30} seconds'
//                       : 'You can now request a new OTP',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: AppColors.textLight,
//                   ),
//                 ),
//               ),
//               const Spacer(),
//
//               // Verify Button
//               CustomButton(
//                 text: widget.purpose == 'register'
//                     ? 'Verify Account'
//                     : 'Verify & Login',
//                 onPressed: _handleVerify,
//                 isLoading: _isVerifying,
//               ),
//               const SizedBox(height: 16),
//
//               // Back Button
//               TextButton(
//                 onPressed: _isVerifying ? null : () => Navigator.pop(context),
//                 child: const Center(
//                   child: Text(
//                     'Go Back',
//                     style: TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
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
// // import 'dart:async';
// // import '../../core/constants/app_colors.dart';
// // import '../../core/widgets/custom_button.dart';
// // import '../../data/providers/auth_provider.dart';
// // import '../../config/routes.dart';
// // import '../../config/app_config.dart';
// //
// // class OtpScreen extends StatefulWidget {
// //   final String? email;
// //   final String? mobile;
// //   final String purpose; // 'register' or 'login'
// //
// //   const OtpScreen({
// //     super.key,
// //     this.email,
// //     this.mobile,
// //     required this.purpose,
// //   });
// //
// //   @override
// //   State<OtpScreen> createState() => _OtpScreenState();
// // }
// //
// // class _OtpScreenState extends State<OtpScreen> {
// //   final List<TextEditingController> _otpControllers =
// //   List.generate(6, (_) => TextEditingController());
// //   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
// //
// //   int _remainingSeconds = AppConfig.otpExpirySeconds;
// //   Timer? _timer;
// //   bool _isVerifying = false;
// //   String? _errorMessage;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _startTimer();
// //     // Auto-focus first OTP field
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (_focusNodes[0].hasFocus == false) {
// //         _focusNodes[0].requestFocus();
// //       }
// //     });
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
// //     _timer?.cancel();
// //     setState(() {
// //       _remainingSeconds = AppConfig.otpExpirySeconds;
// //     });
// //
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
// //   String _getTargetInfo() {
// //     if (widget.mobile != null && widget.mobile!.isNotEmpty) {
// //       // Show last 4 digits only for privacy
// //       final mobile = widget.mobile!;
// //       return '******${mobile.length > 4 ? mobile.substring(mobile.length - 4) : mobile}';
// //     } else if (widget.email != null && widget.email!.isNotEmpty) {
// //       return widget.email!;
// //     }
// //     return 'your contact';
// //   }
// //
// //   Future<void> _handleResend() async {
// //     if (_remainingSeconds > 30) {
// //       _showError('Please wait ${_remainingSeconds - 30} more seconds before resending');
// //       return;
// //     }
// //
// //     // TODO: Implement resend OTP API call
// //     _startTimer();
// //     _showSuccess('New OTP sent to ${_getTargetInfo()}');
// //   }
// //
// //   Future<void> _handleVerify() async {
// //     final otp = _otpControllers.map((c) => c.text).join();
// //
// //     if (otp.length != 6) {
// //       _showError('Please enter complete 6-digit OTP');
// //       return;
// //     }
// //
// //     // Validate OTP contains only numbers
// //     if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
// //       _showError('Please enter valid 6-digit OTP');
// //       return;
// //     }
// //
// //     setState(() {
// //       _isVerifying = true;
// //       _errorMessage = null;
// //     });
// //
// //     try {
// //       final authProvider = Provider.of<AuthProvider>(context, listen: false);
// //
// //       if (widget.purpose == 'register') {
// //         await _handleRegistrationVerification(authProvider, otp);
// //       } else {
// //         await _handleLoginVerification(authProvider, otp);
// //       }
// //     } catch (e) {
// //       if (!mounted) return;
// //       _showError('Verification error: ${e.toString()}');
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _isVerifying = false;
// //         });
// //       }
// //     }
// //   }
// //
// //   Future<void> _handleRegistrationVerification(
// //       AuthProvider authProvider, String otp) async {
// //     // Get mobile from arguments
// //     final mobile = widget.mobile;
// //     if (mobile == null || mobile.isEmpty) {
// //       _showError('Mobile number is required for verification');
// //       return;
// //     }
// //
// //     final result = await authProvider.verifyRegistrationOtp(
// //       mobile: mobile,
// //       otp: otp,
// //     );
// //
// //     if (!mounted) return;
// //
// //     if (result['success'] == true) {
// //       _showSuccess('Account verified successfully!');
// //
// //       // Navigate to home screen
// //       _navigateToHome();
// //     } else {
// //       _showError(result['message'] ?? 'Invalid OTP');
// //     }
// //   }
// //
// //   Future<void> _handleLoginVerification(
// //       AuthProvider authProvider, String otp) async {
// //     // Get mobile from arguments
// //     final mobile = widget.mobile;
// //     if (mobile == null || mobile.isEmpty) {
// //       _showError('Mobile number is required for verification');
// //       return;
// //     }
// //
// //     final result = await authProvider.verifyLoginOtp(
// //       mobile: mobile,
// //       otp: otp,
// //     );
// //
// //     if (!mounted) return;
// //
// //     if (result['success'] == true) {
// //       _showSuccess('Login successful!');
// //
// //       // Navigate to home screen
// //       _navigateToHome();
// //     } else {
// //       _showError(result['message'] ?? 'Invalid OTP');
// //     }
// //   }
// //
// //   void _navigateToHome() {
// //     Navigator.pushNamedAndRemoveUntil(
// //       context,
// //       AppRoutes.bottomNav,
// //           (route) => false,
// //     );
// //   }
// //
// //   void _showSuccess(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.green,
// //         duration: const Duration(seconds: 3),
// //       ),
// //     );
// //   }
// //
// //   void _showError(String message) {
// //     setState(() {
// //       _errorMessage = message;
// //     });
// //
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.red,
// //         duration: const Duration(seconds: 3),
// //       ),
// //     );
// //   }
// //
// //   void _autoSubmitOnComplete() {
// //     final otp = _otpControllers.map((c) => c.text).join();
// //     if (otp.length == 6 && RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
// //       _handleVerify();
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
// //         title: Text(
// //           widget.purpose == 'register' ? 'Verify Account' : 'Verify Login',
// //           style: const TextStyle(
// //             color: AppColors.textPrimary,
// //             fontSize: 18,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //       ),
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.all(24),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const SizedBox(height: 20),
// //
// //               // Title
// //               Text(
// //                 widget.purpose == 'register'
// //                     ? 'Verify Your Account'
// //                     : 'Verify Login',
// //                 style: const TextStyle(
// //                   fontSize: 24,
// //                   fontWeight: FontWeight.bold,
// //                   color: AppColors.textPrimary,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //
// //               // Subtitle
// //               Text(
// //                 widget.purpose == 'register'
// //                     ? 'Complete your registration by entering the OTP'
// //                     : 'Complete your login by entering the OTP',
// //                 style: const TextStyle(
// //                   fontSize: 16,
// //                   color: AppColors.textSecondary,
// //                 ),
// //               ),
// //               const SizedBox(height: 4),
// //
// //               // Target info
// //               Row(
// //                 children: [
// //                   Text(
// //                     'Sent to: ',
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       color: AppColors.textSecondary,
// //                     ),
// //                   ),
// //                   Text(
// //                     _getTargetInfo(),
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.w600,
// //                       color: AppColors.primary,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //
// //               // Error Message
// //               if (_errorMessage != null) ...[
// //                 const SizedBox(height: 16),
// //                 Container(
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: Colors.red.withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(8),
// //                     border: Border.all(color: Colors.red.withOpacity(0.3)),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.error_outline,
// //                         color: Colors.red,
// //                         size: 20,
// //                       ),
// //                       const SizedBox(width: 8),
// //                       Expanded(
// //                         child: Text(
// //                           _errorMessage!,
// //                           style: const TextStyle(
// //                             color: Colors.red,
// //                             fontSize: 14,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //
// //               const SizedBox(height: 32),
// //
// //               // OTP Input Section
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text(
// //                     'Enter 6-digit OTP',
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       color: AppColors.textSecondary,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //
// //                   // OTP Boxes
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: List.generate(6, (index) {
// //                       return SizedBox(
// //                         width: 48,
// //                         height: 56,
// //                         child: TextField(
// //                           controller: _otpControllers[index],
// //                           focusNode: _focusNodes[index],
// //                           textAlign: TextAlign.center,
// //                           keyboardType: TextInputType.number,
// //                           maxLength: 1,
// //                           style: const TextStyle(
// //                             fontSize: 22,
// //                             fontWeight: FontWeight.bold,
// //                             color: AppColors.textPrimary,
// //                           ),
// //                           decoration: InputDecoration(
// //                             counterText: '',
// //                             filled: true,
// //                             fillColor: AppColors.cardBackground,
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                               borderSide: BorderSide.none,
// //                             ),
// //                             focusedBorder: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                               borderSide: const BorderSide(
// //                                 color: AppColors.primary,
// //                                 width: 2,
// //                               ),
// //                             ),
// //                             enabledBorder: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                               borderSide: BorderSide(
// //                                 color: _errorMessage != null
// //                                     ? Colors.red.withOpacity(0.5)
// //                                     : AppColors.border,
// //                               ),
// //                             ),
// //                           ),
// //                           onChanged: (value) {
// //                             if (value.isNotEmpty && index < 5) {
// //                               _focusNodes[index + 1].requestFocus();
// //                             } else if (value.isEmpty && index > 0) {
// //                               _focusNodes[index - 1].requestFocus();
// //                             }
// //
// //                             // Auto-submit when 6 digits are entered
// //                             if (value.isNotEmpty && index == 5) {
// //                               Future.delayed(const Duration(milliseconds: 100), () {
// //                                 _autoSubmitOnComplete();
// //                               });
// //                             }
// //
// //                             // Clear error when user starts typing
// //                             if (_errorMessage != null && value.isNotEmpty) {
// //                               setState(() {
// //                                 _errorMessage = null;
// //                               });
// //                             }
// //                           },
// //                           onTap: () {
// //                             // Clear field when tapped
// //                             if (_otpControllers[index].text.isNotEmpty) {
// //                               _otpControllers[index].clear();
// //                             }
// //                           },
// //                         ),
// //                       );
// //                     }),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 32),
// //
// //               // Timer Section
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: AppColors.cardBackground,
// //                   borderRadius: BorderRadius.circular(12),
// //                   border: Border.all(
// //                     color: _remainingSeconds > 0
// //                         ? AppColors.border
// //                         : AppColors.error.withOpacity(0.3),
// //                     width: 1.5,
// //                   ),
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           _remainingSeconds > 0 ? 'OTP Expires In' : 'OTP Expired',
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             color: _remainingSeconds > 0
// //                                 ? AppColors.textSecondary
// //                                 : AppColors.error,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           _getTimerText(),
// //                           style: TextStyle(
// //                             fontSize: 22,
// //                             fontWeight: FontWeight.bold,
// //                             color: _remainingSeconds > 0
// //                                 ? AppColors.textPrimary
// //                                 : AppColors.error,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     ElevatedButton(
// //                       onPressed: _remainingSeconds <= 30 ? _handleResend : null,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: _remainingSeconds <= 30
// //                             ? AppColors.primary
// //                             : AppColors.textLight.withOpacity(0.3),
// //                         foregroundColor: _remainingSeconds <= 30
// //                             ? Colors.white
// //                             : AppColors.textSecondary,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 20,
// //                           vertical: 10,
// //                         ),
// //                         elevation: 0,
// //                       ),
// //                       child: const Text(
// //                         'Resend OTP',
// //                         style: TextStyle(
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //
// //               // Resend Info
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 4),
// //                 child: Text(
// //                   _remainingSeconds > 30
// //                       ? 'You can request a new code in ${_remainingSeconds - 30} seconds'
// //                       : 'You can now request a new OTP',
// //                   style: const TextStyle(
// //                     fontSize: 12,
// //                     color: AppColors.textLight,
// //                   ),
// //                 ),
// //               ),
// //               const Spacer(),
// //
// //               // Verify Button
// //               CustomButton(
// //                 text: widget.purpose == 'register'
// //                     ? 'Verify & Continue'
// //                     : 'Verify & Login',
// //                 onPressed: _handleVerify,
// //                 isLoading: _isVerifying,
// //               ),
// //               const SizedBox(height: 16),
// //
// //               // Back Button
// //               TextButton(
// //                 onPressed: _isVerifying ? null : () => Navigator.pop(context),
// //                 child: const Center(
// //                   child: Text(
// //                     'Go Back',
// //                     style: TextStyle(
// //                       color: AppColors.textSecondary,
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 20),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import 'dart:async';
// // // import '../../core/constants/app_colors.dart';
// // // import '../../core/widgets/custom_button.dart';
// // // import '../../data/providers/auth_provider.dart';
// // // import '../../config/routes.dart';
// // // import '../../config/app_config.dart';
// // //
// // // class OtpScreen extends StatefulWidget {
// // //   final String? email;
// // //   final String? mobile;
// // //   final String? userId;
// // //   final String purpose; // 'register' or 'login'
// // //   final String? name;
// // //   final String? identifier;
// // //   final bool? isMobile;
// // //   final bool? isOtpLogin;
// // //
// // //   const OtpScreen({
// // //     super.key,
// // //     this.email,
// // //     this.mobile,
// // //     this.userId,
// // //     required this.purpose,
// // //     this.name,
// // //     this.identifier,
// // //     this.isMobile,
// // //     this.isOtpLogin,
// // //   });
// // //
// // //   @override
// // //   State<OtpScreen> createState() => _OtpScreenState();
// // // }
// // //
// // // class _OtpScreenState extends State<OtpScreen> {
// // //   final List<TextEditingController> _otpControllers =
// // //   List.generate(6, (_) => TextEditingController());
// // //   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
// // //
// // //   int _remainingSeconds = AppConfig.otpExpirySeconds;
// // //   Timer? _timer;
// // //   bool _isVerifying = false;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _startTimer();
// // //     // Auto-focus first OTP field
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       if (_focusNodes[0].hasFocus == false) {
// // //         _focusNodes[0].requestFocus();
// // //       }
// // //     });
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _timer?.cancel();
// // //     for (var controller in _otpControllers) {
// // //       controller.dispose();
// // //     }
// // //     for (var node in _focusNodes) {
// // //       node.dispose();
// // //     }
// // //     super.dispose();
// // //   }
// // //
// // //   void _startTimer() {
// // //     _timer?.cancel();
// // //     setState(() {
// // //       _remainingSeconds = AppConfig.otpExpirySeconds;
// // //     });
// // //
// // //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // //       if (_remainingSeconds > 0) {
// // //         setState(() {
// // //           _remainingSeconds--;
// // //         });
// // //       } else {
// // //         timer.cancel();
// // //       }
// // //     });
// // //   }
// // //
// // //   String _getTimerText() {
// // //     final minutes = _remainingSeconds ~/ 60;
// // //     final seconds = _remainingSeconds % 60;
// // //     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
// // //   }
// // //
// // //   String _getTargetInfo() {
// // //     if (widget.mobile != null && widget.mobile!.isNotEmpty) {
// // //       return 'mobile number ${widget.mobile}';
// // //     } else if (widget.email != null && widget.email!.isNotEmpty) {
// // //       return 'email ${widget.email}';
// // //     } else if (widget.identifier != null) {
// // //       return widget.identifier!;
// // //     }
// // //     return 'your contact';
// // //   }
// // //
// // //   bool _isTargetMobile() {
// // //     if (widget.isMobile != null) return widget.isMobile!;
// // //     if (widget.mobile != null && widget.mobile!.isNotEmpty) return true;
// // //     return false;
// // //   }
// // //
// // //   Future<void> _handleResend() async {
// // //     if (_remainingSeconds > 30) {
// // //       _showErrorSnackbar('Please wait ${_remainingSeconds - 30} more seconds before resending');
// // //       return;
// // //     }
// // //
// // //     // In a real app, you would call API to resend OTP
// // //     // For now, we'll just restart the timer
// // //     _startTimer();
// // //     _showSuccessSnackbar('New OTP sent to ${_getTargetInfo()}');
// // //   }
// // //
// // //   Future<void> _handleVerify() async {
// // //     final otp = _otpControllers.map((c) => c.text).join();
// // //
// // //     if (otp.length != 6) {
// // //       _showErrorSnackbar('Please enter complete 6-digit OTP');
// // //       return;
// // //     }
// // //
// // //     // Validate OTP contains only numbers
// // //     if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
// // //       _showErrorSnackbar('Please enter valid 6-digit OTP');
// // //       return;
// // //     }
// // //
// // //     setState(() {
// // //       _isVerifying = true;
// // //     });
// // //
// // //     try {
// // //       final authProvider = Provider.of<AuthProvider>(context, listen: false);
// // //
// // //       if (widget.purpose == 'register') {
// // //         await _handleRegistrationVerification(authProvider, otp);
// // //       } else {
// // //         await _handleLoginVerification(authProvider, otp);
// // //       }
// // //     } catch (e) {
// // //       if (!mounted) return;
// // //       _showErrorSnackbar('Verification error: ${e.toString()}');
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() {
// // //           _isVerifying = false;
// // //         });
// // //       }
// // //     }
// // //   }
// // //
// // //   Future<void> _handleRegistrationVerification(AuthProvider authProvider, String otp) async {
// // //     // Determine the verification target
// // //     final String? verificationTarget;
// // //     if (_isTargetMobile() && widget.mobile != null) {
// // //       verificationTarget = widget.mobile!;
// // //     } else if (widget.email != null) {
// // //       verificationTarget = widget.email!;
// // //     } else if (widget.identifier != null) {
// // //       verificationTarget = widget.identifier!;
// // //     } else {
// // //       _showErrorSnackbar('Unable to verify. Please try again.');
// // //       return;
// // //     }
// // //
// // //     final result = await authProvider.verifyRegistrationOtp(
// // //       mobile: verificationTarget!,
// // //       otp: otp,
// // //     );
// // //
// // //     if (!mounted) return;
// // //
// // //     if (result != null && result['success'] == true) {
// // //       _showSuccessSnackbar('Account verified successfully!');
// // //
// // //       // Check if user data is available
// // //       final userData = authProvider.currentUser;
// // //
// // //       if (userData != null && userData.id.isNotEmpty) {
// // //         // Navigate to profile setup if needed, otherwise go to home
// // //         // For now, go directly to home
// // //         Navigator.pushNamedAndRemoveUntil(
// // //           context,
// // //           AppRoutes.bottomNav,
// // //               (route) => false,
// // //         );
// // //       } else {
// // //         // If user data is not complete, go to profile setup
// // //         Navigator.pushNamedAndRemoveUntil(
// // //           context,
// // //           AppRoutes.profileSetup,
// // //               (route) => false,
// // //         );
// // //       }
// // //     } else {
// // //       _showErrorSnackbar(result?['message'] ?? 'Invalid OTP');
// // //     }
// // //   }
// // //
// // //   Future<void> _handleLoginVerification(AuthProvider authProvider, String otp) async {
// // //     // Determine the verification target
// // //     final String? verificationTarget;
// // //     if (_isTargetMobile() && widget.mobile != null) {
// // //       verificationTarget = widget.mobile!;
// // //     } else if (widget.email != null) {
// // //       verificationTarget = widget.email!;
// // //     } else if (widget.identifier != null) {
// // //       verificationTarget = widget.identifier!;
// // //     } else {
// // //       _showErrorSnackbar('Unable to verify. Please try again.');
// // //       return;
// // //     }
// // //
// // //     final result = await authProvider.verifyLoginOtp(
// // //       mobile: verificationTarget!,
// // //       otp: otp,
// // //     );
// // //
// // //     if (!mounted) return;
// // //
// // //     if (result != null && result['success'] == true) {
// // //       _showSuccessSnackbar('Login successful!');
// // //
// // //       // Navigate to home screen
// // //       Navigator.pushNamedAndRemoveUntil(
// // //         context,
// // //         AppRoutes.bottomNav,
// // //             (route) => false,
// // //       );
// // //     } else {
// // //       _showErrorSnackbar(result?['message'] ?? 'Invalid OTP');
// // //     }
// // //   }
// // //
// // //   void _showSuccessSnackbar(String message) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message),
// // //         backgroundColor: Colors.green,
// // //         duration: const Duration(seconds: 3),
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _showErrorSnackbar(String message) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message),
// // //         backgroundColor: Colors.red,
// // //         duration: const Duration(seconds: 3),
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _autoSubmitOnComplete() {
// // //     final otp = _otpControllers.map((c) => c.text).join();
// // //     if (otp.length == 6 && RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
// // //       _handleVerify();
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.white,
// // //       appBar: AppBar(
// // //         backgroundColor: Colors.white,
// // //         elevation: 0,
// // //         leading: IconButton(
// // //           icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
// // //           onPressed: () => Navigator.pop(context),
// // //         ),
// // //         title: Text(
// // //           widget.purpose == 'register' ? 'Verify Account' : 'Verify Login',
// // //           style: const TextStyle(
// // //             color: AppColors.textPrimary,
// // //             fontSize: 18,
// // //             fontWeight: FontWeight.w600,
// // //           ),
// // //         ),
// // //       ),
// // //       body: SafeArea(
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(24),
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               const SizedBox(height: 20),
// // //
// // //               // Title
// // //               Text(
// // //                 widget.purpose == 'register' ? 'Verify Your Account' : 'Verify Login',
// // //                 style: const TextStyle(
// // //                   fontSize: 24,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: AppColors.textPrimary,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 8),
// // //
// // //               // Subtitle
// // //               const Text(
// // //                 'Enter the 6-digit verification code',
// // //                 style: TextStyle(
// // //                   fontSize: 16,
// // //                   color: AppColors.textSecondary,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 4),
// // //
// // //               // Target info
// // //               Text(
// // //                 'sent to ${_getTargetInfo()}',
// // //                 style: TextStyle(
// // //                   fontSize: 16,
// // //                   fontWeight: FontWeight.w600,
// // //                   color: AppColors.primary,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 32),
// // //
// // //               // OTP Input Section
// // //               Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   const Text(
// // //                     'Enter OTP',
// // //                     style: TextStyle(
// // //                       fontSize: 14,
// // //                       color: AppColors.textSecondary,
// // //                       fontWeight: FontWeight.w500,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 12),
// // //
// // //                   // OTP Boxes
// // //                   Row(
// // //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                     children: List.generate(6, (index) {
// // //                       return SizedBox(
// // //                         width: 50,
// // //                         height: 60,
// // //                         child: TextField(
// // //                           controller: _otpControllers[index],
// // //                           focusNode: _focusNodes[index],
// // //                           textAlign: TextAlign.center,
// // //                           keyboardType: TextInputType.number,
// // //                           maxLength: 1,
// // //                           style: const TextStyle(
// // //                             fontSize: 24,
// // //                             fontWeight: FontWeight.bold,
// // //                             color: AppColors.textPrimary,
// // //                           ),
// // //                           decoration: InputDecoration(
// // //                             counterText: '',
// // //                             filled: true,
// // //                             fillColor: AppColors.cardBackground,
// // //                             border: OutlineInputBorder(
// // //                               borderRadius: BorderRadius.circular(12),
// // //                               borderSide: BorderSide.none,
// // //                             ),
// // //                             focusedBorder: OutlineInputBorder(
// // //                               borderRadius: BorderRadius.circular(12),
// // //                               borderSide: const BorderSide(
// // //                                 color: AppColors.primary,
// // //                                 width: 2,
// // //                               ),
// // //                             ),
// // //                             enabledBorder: OutlineInputBorder(
// // //                               borderRadius: BorderRadius.circular(12),
// // //                               borderSide: const BorderSide(
// // //                                 color: AppColors.border,
// // //                               ),
// // //                             ),
// // //                             errorBorder: OutlineInputBorder(
// // //                               borderRadius: BorderRadius.circular(12),
// // //                               borderSide: const BorderSide(
// // //                                 color: AppColors.error,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                           onChanged: (value) {
// // //                             if (value.isNotEmpty && index < 5) {
// // //                               _focusNodes[index + 1].requestFocus();
// // //                             } else if (value.isEmpty && index > 0) {
// // //                               _focusNodes[index - 1].requestFocus();
// // //                             }
// // //
// // //                             // Auto-submit when 6 digits are entered
// // //                             if (value.isNotEmpty && index == 5) {
// // //                               Future.delayed(const Duration(milliseconds: 100), () {
// // //                                 _autoSubmitOnComplete();
// // //                               });
// // //                             }
// // //                           },
// // //                           onTap: () {
// // //                             // Clear field when tapped
// // //                             _otpControllers[index].clear();
// // //                           },
// // //                         ),
// // //                       );
// // //                     }),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 32),
// // //
// // //               // Timer Section
// // //               Container(
// // //                 padding: const EdgeInsets.all(16),
// // //                 decoration: BoxDecoration(
// // //                   color: AppColors.cardBackground,
// // //                   borderRadius: BorderRadius.circular(12),
// // //                   border: Border.all(
// // //                     color: _remainingSeconds > 0
// // //                         ? AppColors.border
// // //                         : AppColors.error.withOpacity(0.3),
// // //                   ),
// // //                 ),
// // //                 child: Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //                     Column(
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         Text(
// // //                           _remainingSeconds > 0 ? 'OTP Expires In' : 'OTP Expired',
// // //                           style: TextStyle(
// // //                             fontSize: 14,
// // //                             color: _remainingSeconds > 0
// // //                                 ? AppColors.textSecondary
// // //                                 : AppColors.error,
// // //                           ),
// // //                         ),
// // //                         const SizedBox(height: 4),
// // //                         Text(
// // //                           _getTimerText(),
// // //                           style: TextStyle(
// // //                             fontSize: 20,
// // //                             fontWeight: FontWeight.bold,
// // //                             color: _remainingSeconds > 0
// // //                                 ? AppColors.textPrimary
// // //                                 : AppColors.error,
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     if (_remainingSeconds <= 0)
// // //                       ElevatedButton(
// // //                         onPressed: _handleResend,
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: AppColors.primary,
// // //                           foregroundColor: Colors.white,
// // //                           shape: RoundedRectangleBorder(
// // //                             borderRadius: BorderRadius.circular(8),
// // //                           ),
// // //                           padding: const EdgeInsets.symmetric(
// // //                             horizontal: 20,
// // //                             vertical: 10,
// // //                           ),
// // //                         ),
// // //                         child: const Text('Resend OTP'),
// // //                       )
// // //                     else
// // //                       TextButton(
// // //                         onPressed: _remainingSeconds <= 30 ? _handleResend : null,
// // //                         child: Text(
// // //                           'Resend',
// // //                           style: TextStyle(
// // //                             color: _remainingSeconds <= 30
// // //                                 ? AppColors.primary
// // //                                 : AppColors.textLight,
// // //                             fontWeight: FontWeight.w600,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                   ],
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 8),
// // //
// // //               // Resend Info
// // //               Text(
// // //                 _remainingSeconds > 30
// // //                     ? 'You can request a new code in ${_remainingSeconds - 30} seconds'
// // //                     : 'You can now request a new OTP',
// // //                 style: const TextStyle(
// // //                   fontSize: 12,
// // //                   color: AppColors.textLight,
// // //                 ),
// // //               ),
// // //               const Spacer(),
// // //
// // //               // Verify Button
// // //               CustomButton(
// // //                 text: 'Verify & Continue',
// // //                 onPressed: _handleVerify,
// // //                 isLoading: _isVerifying,
// // //               ),
// // //               const SizedBox(height: 16),
// // //
// // //               // Back Button
// // //               TextButton(
// // //                 onPressed: () => Navigator.pop(context),
// // //                 child: const Center(
// // //                   child: Text(
// // //                     'Go Back',
// // //                     style: TextStyle(
// // //                       color: AppColors.textSecondary,
// // //                       fontSize: 14,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 20),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import 'dart:async';
// // // import '../../core/constants/app_colors.dart';
// // // import '../../core/widgets/custom_button.dart';
// // // import '../../data/providers/auth_provider.dart';
// // // import '../../config/routes.dart';
// // // import '../../config/app_config.dart';
// // //
// // // class OtpScreen extends StatefulWidget {
// // //   final String? email;
// // //   final String? userId;
// // //   final String? phone;
// // //   final String purpose; // 'register' or 'login'
// // //   final String? firstName;
// // //   final String? lastName;
// // //   final String? mobile; // For compatibility
// // //
// // //   const OtpScreen({
// // //     super.key,
// // //     this.email,
// // //     this.userId,
// // //     this.phone,
// // //     required this.purpose,
// // //     this.firstName,
// // //     this.lastName,
// // //     this.mobile,
// // //   });
// // //
// // //   @override
// // //   State<OtpScreen> createState() => _OtpScreenState();
// // // }
// // //
// // // class _OtpScreenState extends State<OtpScreen> {
// // //   final List<TextEditingController> _otpControllers =
// // //   List.generate(6, (_) => TextEditingController());
// // //   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
// // //
// // //   int _remainingSeconds = AppConfig.otpExpirySeconds;
// // //   Timer? _timer;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _startTimer();
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _timer?.cancel();
// // //     for (var controller in _otpControllers) {
// // //       controller.dispose();
// // //     }
// // //     for (var node in _focusNodes) {
// // //       node.dispose();
// // //     }
// // //     super.dispose();
// // //   }
// // //
// // //   void _startTimer() {
// // //     _timer?.cancel();
// // //     setState(() {
// // //       _remainingSeconds = AppConfig.otpExpirySeconds;
// // //     });
// // //
// // //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // //       if (_remainingSeconds > 0) {
// // //         setState(() {
// // //           _remainingSeconds--;
// // //         });
// // //       } else {
// // //         timer.cancel();
// // //       }
// // //     });
// // //   }
// // //
// // //   String _getTimerText() {
// // //     final minutes = _remainingSeconds ~/ 60;
// // //     final seconds = _remainingSeconds % 60;
// // //     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
// // //   }
// // //
// // //   Future<void> _handleResend() async {
// // //     if (_remainingSeconds > 0) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(
// // //           content: Text('Please wait before requesting a new OTP'),
// // //           backgroundColor: Colors.orange,
// // //         ),
// // //       );
// // //       return;
// // //     }
// // //
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       const SnackBar(
// // //         content: Text('Please go back and try again'),
// // //         backgroundColor: Colors.orange,
// // //       ),
// // //     );
// // //   }
// // //
// // //   Future<void> _handleVerify() async {
// // //     final otp = _otpControllers.map((c) => c.text).join();
// // //
// // //     if (otp.length != 6) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(
// // //           content: Text('Please enter complete 6-digit OTP'),
// // //           backgroundColor: Colors.red,
// // //         ),
// // //       );
// // //       return;
// // //     }
// // //
// // //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// // //     bool success = false;
// // //
// // //     if (widget.purpose == 'register') {
// // //       // Verify Registration
// // //       success = await authProvider.verifyRegistration(
// // //         email: widget.email ?? '',
// // //         userId: widget.userId ?? '',
// // //         otp: otp,
// // //         phone: widget.phone,
// // //       );
// // //
// // //       if (!mounted) return;
// // //
// // //       if (success) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text('Account verified successfully!'),
// // //             backgroundColor: Colors.green,
// // //           ),
// // //         );
// // //         Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
// // //       } else {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(
// // //             content: Text(authProvider.error ?? 'Invalid OTP'),
// // //             backgroundColor: Colors.red,
// // //           ),
// // //         );
// // //       }
// // //     } else {
// // //       // Verify Login
// // //       success = await authProvider.verifyLoginOtp(
// // //         email: widget.email ?? '',
// // //         otp: otp,
// // //       );
// // //
// // //       if (!mounted) return;
// // //
// // //       if (success) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(
// // //             content: Text('Login successful!'),
// // //             backgroundColor: Colors.green,
// // //           ),
// // //         );
// // //         Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
// // //       } else {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(
// // //             content: Text(authProvider.error ?? 'Invalid OTP'),
// // //             backgroundColor: Colors.red,
// // //           ),
// // //         );
// // //       }
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.white,
// // //       appBar: AppBar(
// // //         backgroundColor: Colors.white,
// // //         elevation: 0,
// // //         leading: IconButton(
// // //           icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
// // //           onPressed: () => Navigator.pop(context),
// // //         ),
// // //       ),
// // //       body: SafeArea(
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(24),
// // //           child: Column(
// // //             children: [
// // //               // App Logo
// // //               Container(
// // //                 width: 60,
// // //                 height: 60,
// // //                 decoration: BoxDecoration(
// // //                   gradient: AppColors.primaryGradient,
// // //                   borderRadius: BorderRadius.circular(15),
// // //                 ),
// // //                 child: const Icon(
// // //                   Icons.verified_user,
// // //                   size: 30,
// // //                   color: Colors.white,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 24),
// // //
// // //               // Title
// // //               Text(
// // //                 widget.purpose == 'register'
// // //                     ? 'Verify Your Account'
// // //                     : 'Verify Login',
// // //                 style: const TextStyle(
// // //                   fontSize: 20,
// // //                   fontWeight: FontWeight.w600,
// // //                   color: AppColors.textPrimary,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 8),
// // //
// // //               // Subtitle
// // //               const Text(
// // //                 'Enter the 6-digit code sent to',
// // //                 style: TextStyle(
// // //                   fontSize: 14,
// // //                   color: AppColors.textSecondary,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Text(
// // //                 widget.email ?? '',
// // //                 style: const TextStyle(
// // //                   fontSize: 14,
// // //                   fontWeight: FontWeight.w600,
// // //                   color: AppColors.primary,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 32),
// // //
// // //               // OTP Input
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // //                 children: List.generate(6, (index) {
// // //                   return SizedBox(
// // //                     width: 45,
// // //                     child: TextField(
// // //                       controller: _otpControllers[index],
// // //                       focusNode: _focusNodes[index],
// // //                       textAlign: TextAlign.center,
// // //                       keyboardType: TextInputType.number,
// // //                       maxLength: 1,
// // //                       style: const TextStyle(
// // //                         fontSize: 24,
// // //                         fontWeight: FontWeight.bold,
// // //                       ),
// // //                       decoration: InputDecoration(
// // //                         counterText: '',
// // //                         filled: true,
// // //                         fillColor: AppColors.cardBackground,
// // //                         border: OutlineInputBorder(
// // //                           borderRadius: BorderRadius.circular(12),
// // //                           borderSide: const BorderSide(color: AppColors.border),
// // //                         ),
// // //                         focusedBorder: OutlineInputBorder(
// // //                           borderRadius: BorderRadius.circular(12),
// // //                           borderSide: const BorderSide(
// // //                             color: AppColors.primary,
// // //                             width: 2,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                       onChanged: (value) {
// // //                         if (value.isNotEmpty && index < 5) {
// // //                           _focusNodes[index + 1].requestFocus();
// // //                         } else if (value.isEmpty && index > 0) {
// // //                           _focusNodes[index - 1].requestFocus();
// // //                         }
// // //                       },
// // //                     ),
// // //                   );
// // //                 }),
// // //               ),
// // //               const SizedBox(height: 24),
// // //
// // //               // Timer
// // //               if (_remainingSeconds > 0)
// // //                 Text(
// // //                   'OTP expires in ${_getTimerText()}',
// // //                   style: const TextStyle(
// // //                     fontSize: 14,
// // //                     color: AppColors.textSecondary,
// // //                   ),
// // //                 )
// // //               else
// // //                 const Text(
// // //                   'OTP has expired',
// // //                   style: TextStyle(
// // //                     fontSize: 14,
// // //                     color: AppColors.error,
// // //                     fontWeight: FontWeight.w600,
// // //                   ),
// // //                 ),
// // //               const SizedBox(height: 8),
// // //
// // //               // Resend
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.center,
// // //                 children: [
// // //                   const Text(
// // //                     "Didn't receive code? ",
// // //                     style: TextStyle(
// // //                       fontSize: 14,
// // //                       color: AppColors.textSecondary,
// // //                     ),
// // //                   ),
// // //                   TextButton(
// // //                     onPressed: _handleResend,
// // //                     child: Text(
// // //                       'Resend',
// // //                       style: TextStyle(
// // //                         fontSize: 14,
// // //                         color: _remainingSeconds > 0
// // //                             ? AppColors.textLight
// // //                             : AppColors.primary,
// // //                         fontWeight: FontWeight.w600,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const Spacer(),
// // //
// // //               // Verify Button
// // //               Consumer<AuthProvider>(
// // //                 builder: (context, authProvider, _) {
// // //                   return CustomButton(
// // //                     text: 'Verify',
// // //                     onPressed: _handleVerify,
// // //                     isLoading: authProvider.isLoading,
// // //                   );
// // //                 },
// // //               ),
// // //               const SizedBox(height: 24),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// // // // import 'package:flutter/material.dart';
// // // // import 'package:provider/provider.dart';
// // // // import 'dart:async';
// // // // import '../../core/constants/app_colors.dart';
// // // // import '../../core/widgets/custom_button.dart';
// // // // import '../../data/providers/auth_provider.dart';
// // // // import '../../config/routes.dart';
// // // // import '../../config/app_config.dart';
// // // //
// // // // class OtpScreen extends StatefulWidget {
// // // //   final String? email;
// // // //   final String? userId;
// // // //   final String? phone;
// // // //   final String purpose; // 'register' or 'login'
// // // //   final String? firstName;
// // // //   final String? lastName;
// // // //
// // // //   const OtpScreen({
// // // //     super.key,
// // // //     this.email,
// // // //     this.userId,
// // // //     this.phone,
// // // //     required this.purpose,
// // // //     this.firstName,
// // // //     this.lastName, required mobile,
// // // //   });
// // // //
// // // //   @override
// // // //   State<OtpScreen> createState() => _OtpScreenState();
// // // // }
// // // //
// // // // class _OtpScreenState extends State<OtpScreen> {
// // // //   final List<TextEditingController> _otpControllers =
// // // //   List.generate(6, (_) => TextEditingController());
// // // //   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
// // // //
// // // //   int _remainingSeconds = AppConfig.otpExpirySeconds; // 2 minutes
// // // //   Timer? _timer;
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _startTimer();
// // // //   }
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     _timer?.cancel();
// // // //     for (var controller in _otpControllers) {
// // // //       controller.dispose();
// // // //     }
// // // //     for (var node in _focusNodes) {
// // // //       node.dispose();
// // // //     }
// // // //     super.dispose();
// // // //   }
// // // //
// // // //   void _startTimer() {
// // // //     _timer?.cancel();
// // // //     setState(() {
// // // //       _remainingSeconds = AppConfig.otpExpirySeconds;
// // // //     });
// // // //
// // // //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // // //       if (_remainingSeconds > 0) {
// // // //         setState(() {
// // // //           _remainingSeconds--;
// // // //         });
// // // //       } else {
// // // //         timer.cancel();
// // // //       }
// // // //     });
// // // //   }
// // // //
// // // //   String _getTimerText() {
// // // //     final minutes = _remainingSeconds ~/ 60;
// // // //     final seconds = _remainingSeconds % 60;
// // // //     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
// // // //   }
// // // //
// // // //   Future<void> _handleResend() async {
// // // //     if (_remainingSeconds > 0) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(
// // // //           content: Text('Please wait before requesting a new OTP'),
// // // //           backgroundColor: Colors.orange,
// // // //         ),
// // // //       );
// // // //       return;
// // // //     }
// // // //
// // // //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// // // //
// // // //     if (widget.purpose == 'register') {
// // // //       // Re-register to get new OTP
// // // //       final result = await authProvider.register(
// // // //         firstName: widget.firstName ?? '',
// // // //         lastName: widget.lastName ?? '',
// // // //         email: widget.email ?? '',
// // // //         password: '', // Need to store password or re-ask
// // // //         phone: widget.phone,
// // // //       );
// // // //
// // // //       if (!mounted) return;
// // // //
// // // //       if (result != null && result['success'] == true) {
// // // //         _startTimer();
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           const SnackBar(
// // // //             content: Text('OTP resent successfully'),
// // // //             backgroundColor: Colors.green,
// // // //           ),
// // // //         );
// // // //       }
// // // //     } else {
// // // //       // Re-login to get new OTP
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(
// // // //           content: Text('Please go back and login again'),
// // // //           backgroundColor: Colors.orange,
// // // //         ),
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   Future<void> _handleVerify() async {
// // // //     final otp = _otpControllers.map((c) => c.text).join();
// // // //
// // // //     if (otp.length != 6) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(
// // // //           content: Text('Please enter complete 6-digit OTP'),
// // // //           backgroundColor: Colors.red,
// // // //         ),
// // // //       );
// // // //       return;
// // // //     }
// // // //
// // // //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// // // //     bool success = false;
// // // //
// // // //     if (widget.purpose == 'register') {
// // // //       // Verify Registration
// // // //       success = await authProvider.verifyRegistration(
// // // //         email: widget.email ?? '',
// // // //         userId: widget.userId ?? '',
// // // //         otp: otp,
// // // //         phone: widget.phone,
// // // //       );
// // // //
// // // //       if (!mounted) return;
// // // //
// // // //       if (success) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           const SnackBar(
// // // //             content: Text('Account verified successfully!'),
// // // //             backgroundColor: Colors.green,
// // // //           ),
// // // //         );
// // // //         // Navigate to profile setup
// // // //         Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
// // // //       } else {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           SnackBar(
// // // //             content: Text(authProvider.error ?? 'Invalid OTP'),
// // // //             backgroundColor: Colors.red,
// // // //           ),
// // // //         );
// // // //       }
// // // //     } else {
// // // //       // Verify Login
// // // //       success = await authProvider.verifyLoginOtp(
// // // //         email: widget.email ?? '',
// // // //         otp: otp,
// // // //       );
// // // //
// // // //       if (!mounted) return;
// // // //
// // // //       if (success) {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           const SnackBar(
// // // //             content: Text('Login successful!'),
// // // //             backgroundColor: Colors.green,
// // // //           ),
// // // //         );
// // // //         // Navigate to home
// // // //         Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
// // // //       } else {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           SnackBar(
// // // //             content: Text(authProvider.error ?? 'Invalid OTP'),
// // // //             backgroundColor: Colors.red,
// // // //           ),
// // // //         );
// // // //       }
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: Colors.white,
// // // //       appBar: AppBar(
// // // //         backgroundColor: Colors.white,
// // // //         elevation: 0,
// // // //         leading: IconButton(
// // // //           icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
// // // //           onPressed: () => Navigator.pop(context),
// // // //         ),
// // // //       ),
// // // //       body: SafeArea(
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(24),
// // // //           child: Column(
// // // //             children: [
// // // //               // App Logo
// // // //               Container(
// // // //                 width: 60,
// // // //                 height: 60,
// // // //                 decoration: BoxDecoration(
// // // //                   gradient: AppColors.primaryGradient,
// // // //                   borderRadius: BorderRadius.circular(15),
// // // //                 ),
// // // //                 child: const Icon(
// // // //                   Icons.verified_user,
// // // //                   size: 30,
// // // //                   color: Colors.white,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 24),
// // // //
// // // //               // Title
// // // //               Text(
// // // //                 widget.purpose == 'register'
// // // //                     ? 'Verify Your Account'
// // // //                     : 'Verify Login',
// // // //                 style: const TextStyle(
// // // //                   fontSize: 20,
// // // //                   fontWeight: FontWeight.w600,
// // // //                   color: AppColors.textPrimary,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 8),
// // // //
// // // //               // Subtitle
// // // //               Text(
// // // //                 'Enter the 6-digit code sent to',
// // // //                 style: TextStyle(
// // // //                   fontSize: 14,
// // // //                   color: AppColors.textSecondary,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 4),
// // // //               Text(
// // // //                 widget.email ?? '',
// // // //                 style: const TextStyle(
// // // //                   fontSize: 14,
// // // //                   fontWeight: FontWeight.w600,
// // // //                   color: AppColors.primary,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 32),
// // // //
// // // //               // OTP Input
// // // //               Row(
// // // //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // // //                 children: List.generate(6, (index) {
// // // //                   return SizedBox(
// // // //                     width: 45,
// // // //                     child: TextField(
// // // //                       controller: _otpControllers[index],
// // // //                       focusNode: _focusNodes[index],
// // // //                       textAlign: TextAlign.center,
// // // //                       keyboardType: TextInputType.number,
// // // //                       maxLength: 1,
// // // //                       style: const TextStyle(
// // // //                         fontSize: 24,
// // // //                         fontWeight: FontWeight.bold,
// // // //                       ),
// // // //                       decoration: InputDecoration(
// // // //                         counterText: '',
// // // //                         filled: true,
// // // //                         fillColor: AppColors.cardBackground,
// // // //                         border: OutlineInputBorder(
// // // //                           borderRadius: BorderRadius.circular(12),
// // // //                           borderSide: const BorderSide(color: AppColors.border),
// // // //                         ),
// // // //                         focusedBorder: OutlineInputBorder(
// // // //                           borderRadius: BorderRadius.circular(12),
// // // //                           borderSide: const BorderSide(
// // // //                             color: AppColors.primary,
// // // //                             width: 2,
// // // //                           ),
// // // //                         ),
// // // //                       ),
// // // //                       onChanged: (value) {
// // // //                         if (value.isNotEmpty && index < 5) {
// // // //                           _focusNodes[index + 1].requestFocus();
// // // //                         } else if (value.isEmpty && index > 0) {
// // // //                           _focusNodes[index - 1].requestFocus();
// // // //                         }
// // // //                       },
// // // //                     ),
// // // //                   );
// // // //                 }),
// // // //               ),
// // // //               const SizedBox(height: 24),
// // // //
// // // //               // Timer and Resend
// // // //               if (_remainingSeconds > 0)
// // // //                 Text(
// // // //                   'OTP expires in ${_getTimerText()}',
// // // //                   style: const TextStyle(
// // // //                     fontSize: 14,
// // // //                     color: AppColors.textSecondary,
// // // //                   ),
// // // //                 )
// // // //               else
// // // //                 const Text(
// // // //                   'OTP has expired',
// // // //                   style: TextStyle(
// // // //                     fontSize: 14,
// // // //                     color: AppColors.error,
// // // //                     fontWeight: FontWeight.w600,
// // // //                   ),
// // // //                 ),
// // // //               const SizedBox(height: 8),
// // // //
// // // //               Row(
// // // //                 mainAxisAlignment: MainAxisAlignment.center,
// // // //                 children: [
// // // //                   const Text(
// // // //                     "Didn't receive code? ",
// // // //                     style: TextStyle(
// // // //                       fontSize: 14,
// // // //                       color: AppColors.textSecondary,
// // // //                     ),
// // // //                   ),
// // // //                   TextButton(
// // // //                     onPressed: _handleResend,
// // // //                     child: Text(
// // // //                       'Resend',
// // // //                       style: TextStyle(
// // // //                         fontSize: 14,
// // // //                         color: _remainingSeconds > 0
// // // //                             ? AppColors.textLight
// // // //                             : AppColors.primary,
// // // //                         fontWeight: FontWeight.w600,
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //               const Spacer(),
// // // //
// // // //               // Verify Button
// // // //               Consumer<AuthProvider>(
// // // //                 builder: (context, authProvider, _) {
// // // //                   return CustomButton(
// // // //                     text: 'Verify',
// // // //                     onPressed: _handleVerify,
// // // //                     isLoading: authProvider.isLoading,
// // // //                   );
// // // //                 },
// // // //               ),
// // // //               const SizedBox(height: 24),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:provider/provider.dart';
// // // // // import 'dart:async';
// // // // // import '../../core/constants/app_colors.dart';
// // // // // import '../../core/widgets/custom_button.dart';
// // // // // import '../../data/providers/auth_provider.dart';
// // // // // import '../../config/routes.dart';
// // // // //
// // // // // class OtpScreen extends StatefulWidget {
// // // // //   final String? mobile;
// // // // //   final String? email;
// // // // //   final String purpose;
// // // // //
// // // // //   const OtpScreen({
// // // // //     super.key,
// // // // //     this.mobile,
// // // // //     this.email,
// // // // //     required this.purpose,
// // // // //   });
// // // // //
// // // // //   @override
// // // // //   State<OtpScreen> createState() => _OtpScreenState();
// // // // // }
// // // // //
// // // // // class _OtpScreenState extends State<OtpScreen> {
// // // // //   final List<TextEditingController> _otpControllers =
// // // // //   List.generate(4, (_) => TextEditingController());
// // // // //   final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
// // // // //
// // // // //   int _remainingSeconds = 600; // 10 minutes
// // // // //   Timer? _timer;
// // // // //
// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _startTimer();
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   void dispose() {
// // // // //     _timer?.cancel();
// // // // //     for (var controller in _otpControllers) {
// // // // //       controller.dispose();
// // // // //     }
// // // // //     for (var node in _focusNodes) {
// // // // //       node.dispose();
// // // // //     }
// // // // //     super.dispose();
// // // // //   }
// // // // //
// // // // //   void _startTimer() {
// // // // //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // // // //       if (_remainingSeconds > 0) {
// // // // //         setState(() {
// // // // //           _remainingSeconds--;
// // // // //         });
// // // // //       } else {
// // // // //         timer.cancel();
// // // // //       }
// // // // //     });
// // // // //   }
// // // // //
// // // // //   String _getTimerText() {
// // // // //     final minutes = _remainingSeconds ~/ 60;
// // // // //     final seconds = _remainingSeconds % 60;
// // // // //     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
// // // // //   }
// // // // //
// // // // //   Future<void> _handleResend() async {
// // // // //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// // // // //
// // // // //     final success = await authProvider.sendOtp(
// // // // //       mobileOrEmail: widget.mobile ?? widget.email ?? '',
// // // // //       purpose: widget.purpose,
// // // // //     );
// // // // //
// // // // //     if (!mounted) return;
// // // // //
// // // // //     if (success) {
// // // // //       setState(() {
// // // // //         _remainingSeconds = 600;
// // // // //       });
// // // // //       _startTimer();
// // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // //         const SnackBar(content: Text('OTP sent successfully')),
// // // // //       );
// // // // //     }
// // // // //   }
// // // // //
// // // // //   Future<void> _handleVerify() async {
// // // // //     final otp = _otpControllers.map((c) => c.text).join();
// // // // //
// // // // //     if (otp.length != 4) {
// // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // //         const SnackBar(content: Text('Please enter complete OTP')),
// // // // //       );
// // // // //       return;
// // // // //     }
// // // // //
// // // // //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
// // // // //
// // // // //     final success = await authProvider.verifyOtp(
// // // // //       mobileOrEmail: widget.mobile ?? widget.email ?? '',
// // // // //       otp: otp,
// // // // //     );
// // // // //
// // // // //     if (!mounted) return;
// // // // //
// // // // //     if (success) {
// // // // //       if (widget.purpose == 'register') {
// // // // //         Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
// // // // //       } else {
// // // // //         Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
// // // // //       }
// // // // //     } else {
// // // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // // //         SnackBar(content: Text(authProvider.error ?? 'Invalid OTP')),
// // // // //       );
// // // // //     }
// // // // //   }
// // // // //
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       backgroundColor: Colors.white,
// // // // //       appBar: AppBar(
// // // // //         backgroundColor: Colors.white,
// // // // //         elevation: 0,
// // // // //         leading: IconButton(
// // // // //           icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
// // // // //           onPressed: () => Navigator.pop(context),
// // // // //         ),
// // // // //       ),
// // // // //       body: SafeArea(
// // // // //         child: Padding(
// // // // //           padding: const EdgeInsets.all(24),
// // // // //           child: Column(
// // // // //             children: [
// // // // //               // App Logo
// // // // //               Container(
// // // // //                 width: 60,
// // // // //                 height: 60,
// // // // //                 decoration: BoxDecoration(
// // // // //                   gradient: AppColors.primaryGradient,
// // // // //                   borderRadius: BorderRadius.circular(15),
// // // // //                 ),
// // // // //                 child: const Icon(
// // // // //                   Icons.touch_app_rounded,
// // // // //                   size: 30,
// // // // //                   color: Colors.white,
// // // // //                 ),
// // // // //               ),
// // // // //               const SizedBox(height: 24),
// // // // //               // Title
// // // // //               const Text(
// // // // //                 'Log in via OTP',
// // // // //                 style: TextStyle(
// // // // //                   fontSize: 20,
// // // // //                   fontWeight: FontWeight.w600,
// // // // //                   color: AppColors.textPrimary,
// // // // //                 ),
// // // // //               ),
// // // // //               const SizedBox(height: 32),
// // // // //               // Mobile/Email Display
// // // // //               Container(
// // // // //                 padding: const EdgeInsets.all(16),
// // // // //                 decoration: BoxDecoration(
// // // // //                   color: AppColors.cardBackground,
// // // // //                   borderRadius: BorderRadius.circular(12),
// // // // //                   border: Border.all(color: AppColors.border),
// // // // //                 ),
// // // // //                 child: Row(
// // // // //                   children: [
// // // // //                     Text(
// // // // //                       widget.mobile ?? widget.email ?? '',
// // // // //                       style: const TextStyle(
// // // // //                         fontSize: 16,
// // // // //                         fontWeight: FontWeight.w500,
// // // // //                       ),
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //               ),
// // // // //               const SizedBox(height: 24),
// // // // //               // OTP Input
// // // // //               Row(
// // // // //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // // // //                 children: List.generate(4, (index) {
// // // // //                   return SizedBox(
// // // // //                     width: 60,
// // // // //                     child: TextField(
// // // // //                       controller: _otpControllers[index],
// // // // //                       focusNode: _focusNodes[index],
// // // // //                       textAlign: TextAlign.center,
// // // // //                       keyboardType: TextInputType.number,
// // // // //                       maxLength: 1,
// // // // //                       style: const TextStyle(
// // // // //                         fontSize: 24,
// // // // //                         fontWeight: FontWeight.bold,
// // // // //                       ),
// // // // //                       decoration: InputDecoration(
// // // // //                         counterText: '',
// // // // //                         filled: true,
// // // // //                         fillColor: AppColors.cardBackground,
// // // // //                         border: OutlineInputBorder(
// // // // //                           borderRadius: BorderRadius.circular(12),
// // // // //                           borderSide: const BorderSide(color: AppColors.border),
// // // // //                         ),
// // // // //                         focusedBorder: OutlineInputBorder(
// // // // //                           borderRadius: BorderRadius.circular(12),
// // // // //                           borderSide: const BorderSide(
// // // // //                             color: AppColors.primary,
// // // // //                             width: 2,
// // // // //                           ),
// // // // //                         ),
// // // // //                       ),
// // // // //                       onChanged: (value) {
// // // // //                         if (value.isNotEmpty && index < 3) {
// // // // //                           _focusNodes[index + 1].requestFocus();
// // // // //                         } else if (value.isEmpty && index > 0) {
// // // // //                           _focusNodes[index - 1].requestFocus();
// // // // //                         }
// // // // //                       },
// // // // //                     ),
// // // // //                   );
// // // // //                 }),
// // // // //               ),
// // // // //               const SizedBox(height: 16),
// // // // //               // Timer and Resend
// // // // //               Text(
// // // // //                 'The OTP will expire in ${_getTimerText()} mins. Click here to ',
// // // // //                 style: const TextStyle(
// // // // //                   fontSize: 12,
// // // // //                   color: AppColors.textSecondary,
// // // // //                 ),
// // // // //               ),
// // // // //               TextButton(
// // // // //                 onPressed: _remainingSeconds > 0 ? null : _handleResend,
// // // // //                 child: Text(
// // // // //                   'resend',
// // // // //                   style: TextStyle(
// // // // //                     fontSize: 12,
// // // // //                     color: _remainingSeconds > 0
// // // // //                         ? AppColors.textLight
// // // // //                         : AppColors.primary,
// // // // //                     fontWeight: FontWeight.w600,
// // // // //                   ),
// // // // //                 ),
// // // // //               ),
// // // // //               const Spacer(),
// // // // //               // Verify Button
// // // // //               Consumer<AuthProvider>(
// // // // //                 builder: (context, authProvider, _) {
// // // // //                   return CustomButton(
// // // // //                     text: 'Log in',
// // // // //                     onPressed: _handleVerify,
// // // // //                     isLoading: authProvider.isLoading,
// // // // //                   );
// // // // //                 },
// // // // //               ),
// // // // //               const SizedBox(height: 16),
// // // // //               // Back to Login
// // // // //               CustomButton(
// // // // //                 text: 'Create new Account',
// // // // //                 onPressed: () {
// // // // //                   Navigator.pushNamed(context, AppRoutes.signup);
// // // // //                 },
// // // // //                 isOutlined: true,
// // // // //               ),
// // // // //               const SizedBox(height: 24),
// // // // //               // Footer
// // // // //               Row(
// // // // //                 mainAxisAlignment: MainAxisAlignment.center,
// // // // //                 children: [
// // // // //                   TextButton(
// // // // //                     onPressed: () {},
// // // // //                     child: const Text(
// // // // //                       'About',
// // // // //                       style: TextStyle(
// // // // //                         color: AppColors.textSecondary,
// // // // //                         fontSize: 12,
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                   TextButton(
// // // // //                     onPressed: () {},
// // // // //                     child: const Text(
// // // // //                       'Help',
// // // // //                       style: TextStyle(
// // // // //                         color: AppColors.textSecondary,
// // // // //                         fontSize: 12,
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                   TextButton(
// // // // //                     onPressed: () {},
// // // // //                     child: const Text(
// // // // //                       'More',
// // // // //                       style: TextStyle(
// // // // //                         color: AppColors.textSecondary,
// // // // //                         fontSize: 12,
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ],
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }