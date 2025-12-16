import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';
import '../../core/constants/api_endpoints.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;
  String? _tempUserId; // Store userId from registration
  String? _tempEmail; // Store email for OTP verification

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // STEP 1: Register User (sends OTP)
  Future<Map<String, dynamic>?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post(
        ApiEndpoints.register,
        body: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );

      _setLoading(false);

      if (response['success'] == true) {
        // Store userId and email for verification
        _tempUserId = response['data']?['userId'];
        _tempEmail = response['data']?['email'];

        return {
          'success': true,
          'userId': _tempUserId,
          'email': _tempEmail,
          'message': response['message'],
        };
      } else {
        _setError(response['message'] ?? 'Registration failed');
        return null;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Network error: ${e.toString()}');
      return null;
    }
  }

  // STEP 2: Verify Registration OTP
  Future<bool> verifyRegistration({
    required String email,
    required String userId,
    required String otp,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post(
        ApiEndpoints.verifyRegister,
        body: {
          'email': email,
          'userId': userId,
          'otp': otp,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );

      _setLoading(false);

      if (response['success'] == true) {
        // User is now verified but not logged in yet
        // They need to complete profile setup
        return true;
      } else {
        _setError(response['message'] ?? 'Invalid OTP');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Network error: ${e.toString()}');
      return false;
    }
  }

  // STEP 3: Login (sends OTP)
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      _setLoading(false);

      if (response['success'] == true) {
        // Store userId and email for OTP verification
        _tempUserId = response['data']?['userId'];
        _tempEmail = response['data']?['email'];

        return {
          'success': true,
          'userId': _tempUserId,
          'email': _tempEmail,
          'message': response['message'],
        };
      } else {
        _setError(response['message'] ?? 'Login failed');
        return null;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Network error: ${e.toString()}');
      return null;
    }
  }

  // STEP 4: Verify Login OTP
  Future<bool> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post(
        ApiEndpoints.verifyLogin,
        body: {
          'email': email,
          'otp': otp,
        },
      );

      _setLoading(false);

      if (response['success'] == true && response['data'] != null) {
        // Extract tokens and user data
        final data = response['data'];

        if (data['accessToken'] != null) {
          await StorageService.saveToken(data['accessToken']);
        }

        if (data['refreshToken'] != null) {
          await StorageService.saveRefreshToken(data['refreshToken']);
        }

        if (data['user'] != null) {
          _currentUser = UserModel.fromJson(data['user']);
          await StorageService.saveUserId(_currentUser!.userId);
          await StorageService.saveUserData(json.encode(data['user']));
        }

        await StorageService.setLoggedIn(true);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Invalid OTP');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Network error: ${e.toString()}');
      return false;
    }
  }

  // Get Current User
  Future<bool> getCurrentUser() async {
    _setLoading(true);

    try {
      final response = await _apiService.get(
        ApiEndpoints.currentUser,
        requiresAuth: true,
      );

      _setLoading(false);

      if (response['success'] == true && response['data'] != null) {
        _currentUser = UserModel.fromJson(response['data']);
        await StorageService.saveUserData(json.encode(response['data']));
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(
        ApiEndpoints.logout,
        requiresAuth: true,
      );
    } catch (e) {
      print('Logout API error: $e');
    }

    await StorageService.logout();
    _currentUser = null;
    _tempUserId = null;
    _tempEmail = null;
    notifyListeners();
  }

  // Check Auth Status
  Future<bool> checkAuthStatus() async {
    final isLoggedIn = StorageService.isLoggedIn();

    if (isLoggedIn) {
      final userDataString = StorageService.getUserData();
      if (userDataString != null) {
        try {
          final userData = json.decode(userDataString);
          _currentUser = UserModel.fromJson(userData);
          notifyListeners();
          return true;
        } catch (e) {
          print('Error loading user data: $e');
          await StorageService.logout();
          return false;
        }
      }
    }

    return false;
  }

  // Forgot Password
  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.post(
        ApiEndpoints.forgotPassword,
        body: {'email': email},
      );

      _setLoading(false);

      if (response['success'] == true) {
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to send reset link');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('Network error: ${e.toString()}');
      return false;
    }
  }

  // Clear temp data
  void clearTempData() {
    _tempUserId = null;
    _tempEmail = null;
  }
}


// import 'package:flutter/material.dart';
// import 'dart:convert';
// import '../services/api_service.dart';
// import '../services/storage_service.dart';
// import '../models/user_model.dart';
// import '../../core/constants/api_endpoints.dart';
//
// class AuthProvider with ChangeNotifier {
//   final ApiService _apiService = ApiService();
//
//   bool _isLoading = false;
//   String? _error;
//   UserModel? _currentUser;
//   String? _tempUserId; // Store userId from registration
//   String? _tempEmail; // Store email for OTP verification
//
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   UserModel? get currentUser => _currentUser;
//   bool get isAuthenticated => _currentUser != null;
//
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
//
//   void _setError(String? value) {
//     _error = value;
//     notifyListeners();
//   }
//
//   // STEP 1: Register User (sends OTP)
//   Future<Map<String, dynamic>?> register({
//     required String firstName,
//     required String lastName,
//     required String email,
//     required String password,
//     String? phone,
//   }) async {
//     _setLoading(true);
//     _setError(null);
//
//     try {
//       final response = await _apiService.post(
//         ApiEndpoints.register,
//         body: {
//           'firstName': firstName,
//           'lastName': lastName,
//           'email': email,
//           'password': password,
//           if (phone != null && phone.isNotEmpty) 'phone': phone,
//         },
//       );
//
//       _setLoading(false);
//
//       if (response['success'] == true) {
//         // Store userId and email for verification
//         _tempUserId = response['data']?['userId'];
//         _tempEmail = response['data']?['email'];
//
//         return {
//           'success': true,
//           'userId': _tempUserId,
//           'email': _tempEmail,
//           'message': response['message'],
//         };
//       } else {
//         _setError(response['message'] ?? 'Registration failed');
//         return null;
//       }
//     } catch (e) {
//       _setLoading(false);
//       _setError('Network error: ${e.toString()}');
//       return null;
//     }
//   }
//
//   // STEP 2: Verify Registration OTP
//   Future<bool> verifyRegistration({
//     required String email,
//     required String userId,
//     required String otp,
//     String? phone,
//   }) async {
//     _setLoading(true);
//     _setError(null);
//
//     try {
//       final response = await _apiService.post(
//         ApiEndpoints.verifyRegister,
//         body: {
//           'email': email,
//           'userId': userId,
//           'otp': otp,
//           if (phone != null && phone.isNotEmpty) 'phone': phone,
//         },
//       );
//
//       _setLoading(false);
//
//       if (response['success'] == true) {
//         // User is now verified but not logged in yet
//         // They need to complete profile setup
//         return true;
//       } else {
//         _setError(response['message'] ?? 'Invalid OTP');
//         return false;
//       }
//     } catch (e) {
//       _setLoading(false);
//       _setError('Network error: ${e.toString()}');
//       return false;
//     }
//   }
//
//   // STEP 3: Login (sends OTP)
//   Future<Map<String, dynamic>?> login({
//     required String email,
//     required String password,
//   }) async {
//     _setLoading(true);
//     _setError(null);
//
//     try {
//       final response = await _apiService.post(
//         ApiEndpoints.login,
//         body: {
//           'email': email,
//           'password': password,
//         },
//       );
//
//       _setLoading(false);
//
//       if (response['success'] == true) {
//         // Store userId and email for OTP verification
//         _tempUserId = response['data']?['userId'];
//         _tempEmail = response['data']?['email'];
//
//         return {
//           'success': true,
//           'userId': _tempUserId,
//           'email': _tempEmail,
//           'message': response['message'],
//         };
//       } else {
//         _setError(response['message'] ?? 'Login failed');
//         return null;
//       }
//     } catch (e) {
//       _setLoading(false);
//       _setError('Network error: ${e.toString()}');
//       return null;
//     }
//   }
//
//   // STEP 4: Verify Login OTP
//   Future<bool> verifyLoginOtp({
//     required String email,
//     required String otp,
//   }) async {
//     _setLoading(true);
//     _setError(null);
//
//     try {
//       final response = await _apiService.post(
//         ApiEndpoints.verifyLogin,
//         body: {
//           'email': email,
//           'otp': otp,
//         },
//       );
//
//       _setLoading(false);
//
//       if (response['success'] == true && response['data'] != null) {
//         // Extract tokens and user data
//         final data = response['data'];
//
//         if (data['accessToken'] != null) {
//           await StorageService.saveToken(data['accessToken']);
//         }
//
//         if (data['refreshToken'] != null) {
//           await StorageService.saveRefreshToken(data['refreshToken']);
//         }
//
//         if (data['user'] != null) {
//           _currentUser = UserModel.fromJson(data['user']);
//           await StorageService.saveUserId(_currentUser!.userId);
//           await StorageService.saveUserData(json.encode(data['user']));
//         }
//
//         await StorageService.setLoggedIn(true);
//         notifyListeners();
//         return true;
//       } else {
//         _setError(response['message'] ?? 'Invalid OTP');
//         return false;
//       }
//     } catch (e) {
//       _setLoading(false);
//       _setError('Network error: ${e.toString()}');
//       return false;
//     }
//   }
//
//   // Get Current User
//   Future<bool> getCurrentUser() async {
//     _setLoading(true);
//
//     try {
//       final response = await _apiService.get(
//         ApiEndpoints.currentUser,
//         requiresAuth: true,
//       );
//
//       _setLoading(false);
//
//       if (response['success'] == true && response['data'] != null) {
//         _currentUser = UserModel.fromJson(response['data']);
//         await StorageService.saveUserData(json.encode(response['data']));
//         notifyListeners();
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       _setLoading(false);
//       return false;
//     }
//   }
//
//   // Logout
//   Future<void> logout() async {
//     try {
//       await _apiService.post(
//         ApiEndpoints.logout,
//         requiresAuth: true,
//       );
//     } catch (e) {
//       print('Logout API error: $e');
//     }
//
//     await StorageService.logout();
//     _currentUser = null;
//     _tempUserId = null;
//     _tempEmail = null;
//     notifyListeners();
//   }
//
//   // Check Auth Status
//   Future<bool> checkAuthStatus() async {
//     final isLoggedIn = StorageService.isLoggedIn();
//
//     if (isLoggedIn) {
//       final userDataString = StorageService.getUserData();
//       if (userDataString != null) {
//         try {
//           final userData = json.decode(userDataString);
//           _currentUser = UserModel.fromJson(userData);
//           notifyListeners();
//           return true;
//         } catch (e) {
//           print('Error loading user data: $e');
//           await StorageService.logout();
//           return false;
//         }
//       }
//     }
//
//     return false;
//   }
//
//   // Forgot Password
//   Future<bool> forgotPassword({required String email}) async {
//     _setLoading(true);
//     _setError(null);
//
//     try {
//       final response = await _apiService.post(
//         ApiEndpoints.forgotPassword,
//         body: {'email': email},
//       );
//
//       _setLoading(false);
//
//       if (response['success'] == true) {
//         return true;
//       } else {
//         _setError(response['message'] ?? 'Failed to send reset link');
//         return false;
//       }
//     } catch (e) {
//       _setLoading(false);
//       _setError('Network error: ${e.toString()}');
//       return false;
//     }
//   }
//
//   // Clear temp data
//   void clearTempData() {
//     _tempUserId = null;
//     _tempEmail = null;
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'dart:convert';
// // import '../services/api_service.dart';
// // import '../services/storage_service.dart';
// // import '../models/user_model.dart';
// //
// // class AuthProvider with ChangeNotifier {
// //   final ApiService _apiService = ApiService();
// //
// //   bool _isLoading = false;
// //   String? _error;
// //   UserModel? _currentUser;
// //
// //   bool get isLoading => _isLoading;
// //   String? get error => _error;
// //   UserModel? get currentUser => _currentUser;
// //   bool get isAuthenticated => _currentUser != null;
// //
// //   // Set Loading
// //   void _setLoading(bool value) {
// //     _isLoading = value;
// //     notifyListeners();
// //   }
// //
// //   // Set Error
// //   void _setError(String? value) {
// //     _error = value;
// //     notifyListeners();
// //   }
// //
// //   // Send OTP
// //   Future<bool> sendOtp({
// //     required String mobileOrEmail,
// //     required String purpose,
// //   }) async {
// //     _setLoading(true);
// //     _setError(null);
// //
// //     try {
// //       final response = await _apiService.post(
// //         '/auth/send-otp',
// //         body: {
// //           if (mobileOrEmail.contains('@'))
// //             'email': mobileOrEmail
// //           else
// //             'mobile': mobileOrEmail,
// //           'purpose': purpose,
// //         },
// //       );
// //
// //       _setLoading(false);
// //
// //       if (response['success'] == true) {
// //         return true;
// //       } else {
// //         _setError(response['message'] ?? 'Failed to send OTP');
// //         return false;
// //       }
// //     } catch (e) {
// //       _setLoading(false);
// //       _setError('Something went wrong: ${e.toString()}');
// //       return false;
// //     }
// //   }
// //
// //   // Verify OTP
// //   Future<bool> verifyOtp({
// //     required String mobileOrEmail,
// //     required String otp,
// //   }) async {
// //     _setLoading(true);
// //     _setError(null);
// //
// //     try {
// //       final response = await _apiService.post(
// //         '/auth/verify-otp',
// //         body: {
// //           if (mobileOrEmail.contains('@'))
// //             'email': mobileOrEmail
// //           else
// //             'mobile': mobileOrEmail,
// //           'otp': otp,
// //         },
// //       );
// //
// //       _setLoading(false);
// //
// //       if (response['success'] == true) {
// //         // Handle token from response
// //         if (response['token'] != null) {
// //           await StorageService.saveToken(response['token']);
// //           await StorageService.setLoggedIn(true);
// //         }
// //         if (response['access_token'] != null) {
// //           await StorageService.saveToken(response['access_token']);
// //           await StorageService.setLoggedIn(true);
// //         }
// //         if (response['refreshToken'] != null) {
// //           await StorageService.saveRefreshToken(response['refreshToken']);
// //         }
// //
// //         return true;
// //       } else {
// //         _setError(response['message'] ?? 'Invalid OTP');
// //         return false;
// //       }
// //     } catch (e) {
// //       _setLoading(false);
// //       _setError('Something went wrong: ${e.toString()}');
// //       return false;
// //     }
// //   }
// //
// //   // Register
// //   Future<bool> register({
// //     required String name,
// //     required String mobile,
// //     String? email,
// //     required String gender,
// //     required String dob,
// //   }) async {
// //     _setLoading(true);
// //     _setError(null);
// //
// //     try {
// //       final response = await _apiService.post(
// //         '/auth/register',
// //         body: {
// //           'name': name,
// //           'full_name': name,
// //           'mobile': mobile,
// //           if (email != null && email.isNotEmpty) 'email': email,
// //           'gender': gender,
// //           'dob': dob,
// //         },
// //       );
// //
// //       _setLoading(false);
// //
// //       if (response['success'] == true) {
// //         return true;
// //       } else {
// //         _setError(response['message'] ?? 'Registration failed');
// //         return false;
// //       }
// //     } catch (e) {
// //       _setLoading(false);
// //       _setError('Something went wrong: ${e.toString()}');
// //       return false;
// //     }
// //   }
// //
// //   // Login
// //   Future<bool> login({
// //     String? mobile,
// //     String? email,
// //     String? password,
// //     String? otp,
// //   }) async {
// //     _setLoading(true);
// //     _setError(null);
// //
// //     try {
// //       final response = await _apiService.post(
// //         '/auth/login',
// //         body: {
// //           if (mobile != null) 'mobile': mobile,
// //           if (email != null) 'email': email,
// //           if (password != null) 'password': password,
// //           if (otp != null) 'otp': otp,
// //         },
// //       );
// //
// //       _setLoading(false);
// //
// //       if (response['success'] == true) {
// //         // Handle different token response formats
// //         String? token;
// //
// //         if (response['token'] != null) {
// //           token = response['token'];
// //         } else if (response['access_token'] != null) {
// //           token = response['access_token'];
// //         } else if (response['data'] != null && response['data']['token'] != null) {
// //           token = response['data']['token'];
// //         } else if (response['data'] != null && response['data']['access_token'] != null) {
// //           token = response['data']['access_token'];
// //         }
// //
// //         if (token != null) {
// //           await StorageService.saveToken(token);
// //           await StorageService.setLoggedIn(true);
// //
// //           // Save user data if present
// //           if (response['user'] != null) {
// //             _currentUser = UserModel.fromJson(response['user']);
// //             await StorageService.saveUserId(_currentUser!.userId);
// //             await StorageService.saveUserData(json.encode(response['user']));
// //           } else if (response['data'] != null && response['data']['user'] != null) {
// //             _currentUser = UserModel.fromJson(response['data']['user']);
// //             await StorageService.saveUserId(_currentUser!.userId);
// //             await StorageService.saveUserData(json.encode(response['data']['user']));
// //           }
// //
// //           notifyListeners();
// //           return true;
// //         } else {
// //           _setError('No token received');
// //           return false;
// //         }
// //       } else {
// //         _setError(response['message'] ?? 'Login failed');
// //         return false;
// //       }
// //     } catch (e) {
// //       _setLoading(false);
// //       _setError('Something went wrong: ${e.toString()}');
// //       return false;
// //     }
// //   }
// //
// //   // Logout
// //   Future<void> logout() async {
// //     try {
// //       // Call logout API if needed
// //       await _apiService.post('/auth/logout', requiresAuth: true);
// //     } catch (e) {
// //       print('Logout API error: $e');
// //     }
// //
// //     await StorageService.logout();
// //     _currentUser = null;
// //     notifyListeners();
// //   }
// //
// //   // Check if logged in
// //   Future<bool> checkAuthStatus() async {
// //     final isLoggedIn = StorageService.isLoggedIn();
// //
// //     if (isLoggedIn) {
// //       // Try to load user data
// //       final userDataString = StorageService.getUserData();
// //       if (userDataString != null) {
// //         try {
// //           final userData = json.decode(userDataString);
// //           _currentUser = UserModel.fromJson(userData);
// //         } catch (e) {
// //           print('Error loading user data: $e');
// //         }
// //       }
// //     }
// //
// //     return isLoggedIn;
// //   }
// // }
// //
// //
// // // import 'package:flutter/material.dart';
// // // import '../services/api_service.dart';
// // // import '../services/storage_service.dart';
// // // import '../models/user_model.dart';
// // // import '../../core/constants/api_endpoints.dart';
// // //
// // // class AuthProvider with ChangeNotifier {
// // //   final ApiService _apiService = ApiService();
// // //
// // //   bool _isLoading = false;
// // //   String? _error;
// // //   UserModel? _currentUser;
// // //
// // //   bool get isLoading => _isLoading;
// // //   String? get error => _error;
// // //   UserModel? get currentUser => _currentUser;
// // //   bool get isAuthenticated => _currentUser != null;
// // //
// // //   // Set Loading
// // //   void _setLoading(bool value) {
// // //     _isLoading = value;
// // //     notifyListeners();
// // //   }
// // //
// // //   // Set Error
// // //   void _setError(String? value) {
// // //     _error = value;
// // //     notifyListeners();
// // //   }
// // //
// // //   // Send OTP
// // //   Future<bool> sendOtp({
// // //     required String mobileOrEmail,
// // //     required String purpose,
// // //   }) async {
// // //     _setLoading(true);
// // //     _setError(null);
// // //
// // //     try {
// // //       final response = await _apiService.post(
// // //         ApiEndpoints.sendOtp,
// // //         body: {
// // //           'mobile': mobileOrEmail.contains('@') ? null : mobileOrEmail,
// // //           'email': mobileOrEmail.contains('@') ? mobileOrEmail : null,
// // //           'purpose': purpose,
// // //         },
// // //       );
// // //
// // //       _setLoading(false);
// // //
// // //       if (response['success'] == true) {
// // //         return true;
// // //       } else {
// // //         _setError(response['message'] ?? 'Failed to send OTP');
// // //         return false;
// // //       }
// // //     } catch (e) {
// // //       _setLoading(false);
// // //       _setError('Something went wrong');
// // //       return false;
// // //     }
// // //   }
// // //
// // //   // Verify OTP
// // //   Future<bool> verifyOtp({
// // //     required String mobileOrEmail,
// // //     required String otp,
// // //   }) async {
// // //     _setLoading(true);
// // //     _setError(null);
// // //
// // //     try {
// // //       final response = await _apiService.post(
// // //         ApiEndpoints.verifyOtp,
// // //         body: {
// // //           'mobile': mobileOrEmail.contains('@') ? null : mobileOrEmail,
// // //           'email': mobileOrEmail.contains('@') ? mobileOrEmail : null,
// // //           'otp': otp,
// // //         },
// // //       );
// // //
// // //       _setLoading(false);
// // //
// // //       if (response['success'] == true) {
// // //         final data = response['data'];
// // //         await StorageService.saveToken(data['access_token']);
// // //         await StorageService.saveRefreshToken(data['refresh_token']);
// // //         await StorageService.setLoggedIn(true);
// // //         return true;
// // //       } else {
// // //         _setError(response['message'] ?? 'Invalid OTP');
// // //         return false;
// // //       }
// // //     } catch (e) {
// // //       _setLoading(false);
// // //       _setError('Something went wrong');
// // //       return false;
// // //     }
// // //   }
// // //
// // //   // Register
// // //   Future<bool> register({
// // //     required String name,
// // //     required String mobile,
// // //     String? email,
// // //     required String gender,
// // //     required String dob,
// // //   }) async {
// // //     _setLoading(true);
// // //     _setError(null);
// // //
// // //     try {
// // //       final response = await _apiService.post(
// // //         ApiEndpoints.register,
// // //         body: {
// // //           'name': name,
// // //           'mobile': mobile,
// // //           'email': email,
// // //           'gender': gender,
// // //           'dob': dob,
// // //         },
// // //       );
// // //
// // //       _setLoading(false);
// // //
// // //       if (response['success'] == true) {
// // //         return true;
// // //       } else {
// // //         _setError(response['message'] ?? 'Registration failed');
// // //         return false;
// // //       }
// // //     } catch (e) {
// // //       _setLoading(false);
// // //       _setError('Something went wrong');
// // //       return false;
// // //     }
// // //   }
// // //
// // //   // Login
// // //   Future<bool> login({
// // //     String? mobile,
// // //     String? email,
// // //     String? password,
// // //     String? otp,
// // //   }) async {
// // //     _setLoading(true);
// // //     _setError(null);
// // //
// // //     try {
// // //       final response = await _apiService.post(
// // //         ApiEndpoints.login,
// // //         body: {
// // //           if (mobile != null) 'mobile': mobile,
// // //           if (email != null) 'email': email,
// // //           if (password != null) 'password': password,
// // //           if (otp != null) 'otp': otp,
// // //         },
// // //       );
// // //
// // //       _setLoading(false);
// // //
// // //       if (response['success'] == true) {
// // //         final data = response['data'];
// // //         await StorageService.saveToken(data['access_token']);
// // //         await StorageService.saveRefreshToken(data['refresh_token']);
// // //         await StorageService.setLoggedIn(true);
// // //
// // //         if (data['user'] != null) {
// // //           _currentUser = UserModel.fromJson(data['user']);
// // //           await StorageService.saveUserId(_currentUser!.userId);
// // //         }
// // //
// // //         notifyListeners();
// // //         return true;
// // //       } else {
// // //         _setError(response['message'] ?? 'Login failed');
// // //         return false;
// // //       }
// // //     } catch (e) {
// // //       _setLoading(false);
// // //       _setError('Something went wrong');
// // //       return false;
// // //     }
// // //   }
// // //
// // //   // Logout
// // //   Future<void> logout() async {
// // //     await StorageService.logout();
// // //     _currentUser = null;
// // //     notifyListeners();
// // //   }
// // //
// // //   // Check if logged in
// // //   Future<bool> checkAuthStatus() async {
// // //     return StorageService.isLoggedIn();
// // //   }
// // // }