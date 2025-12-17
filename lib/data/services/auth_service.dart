import 'dart:convert';
import 'api_service.dart';
import 'storage_service.dart';
import '../../core/constants/api_endpoints.dart';

class AuthService {
  final ApiService _api = ApiService();

  // ==================== REGISTER (Step 1: Send OTP) ====================
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      print('📝 AuthService: Registering $email');

      final response = await _api.post(
        ApiEndpoints.register,
        body: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
        requiresAuth: false,
      );

      print('✅ Register Response: ${json.encode(response)}');
      return response;
    } catch (e) {
      print('❌ Register Error: $e');
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
        'statusCode': 500,
      };
    }
  }


  // ==================== RESET PASSWORD ====================
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      print('🔑 AuthService: Resetting password');

      final response = await _api.post(
        ApiEndpoints.resetPassword,
        body: {
          'token': token,
          'newPassword': newPassword,
        },
        requiresAuth: false,
      );

      print('✅ Reset Password Response: ${json.encode(response)}');
      return response;
    } catch (e) {
      print('❌ Reset Password Error: $e');
      return {
        'success': false,
        'message': 'Password reset failed: ${e.toString()}',
        'statusCode': 500,
      };
    }
  }


  // ==================== VERIFY REGISTRATION OTP (Step 2) ====================
  Future<Map<String, dynamic>> verifyRegistrationOtp({
    required String email,
    required String userId,
    required String otp,
    String? phone,
  }) async {
    try {
      print('🔐 AuthService: Verifying registration OTP for $email');

      final response = await _api.post(
        ApiEndpoints.verifyRegister,
        body: {
          'email': email,
          'userId': userId,
          'otp': otp,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
        requiresAuth: false,
      );

      print('✅ Verify Registration OTP Response: ${json.encode(response)}');
      return response;
    } catch (e) {
      print('❌ Verify Registration OTP Error: $e');
      return {
        'success': false,
        'message': 'OTP verification failed: ${e.toString()}',
        'statusCode': 500,
      };
    }
  }

  // // ==================== LOGIN (Step 1: Send OTP) ====================
  // lib/data/services/auth_service.dart
// login method change karein:

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 AuthService: Login attempt for $email');

      final response = await _api.post(
        ApiEndpoints.login,
        body: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      print('✅ Login Response: ${json.encode(response)}');

      // ✅ DIRECT LOGIN - Save tokens if successful
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        if (data['accessToken'] != null) {
          await StorageService.saveToken(data['accessToken']);
          print('🔑 Access token saved');
        }

        if (data['refreshToken'] != null) {
          await StorageService.saveRefreshToken(data['refreshToken']);
          print('🔑 Refresh token saved');
        }

        if (data['user'] != null) {
          await StorageService.saveUser(data['user']);
          print('👤 User data saved');
        }
      }

      return response;
    } catch (e) {
      print('❌ Login Error: $e');
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
        'statusCode': 500,
      };
    }
  }

  // Future<Map<String, dynamic>> login({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     print('🔐 AuthService: Login attempt for $email');
  //
  //     final response = await _api.post(
  //       ApiEndpoints.login,
  //       body: {
  //         'email': email,
  //         'password': password,
  //       },
  //       requiresAuth: false,
  //     );
  //
  //     print('✅ Login Response: ${json.encode(response)}');
  //     return response;
  //   } catch (e) {
  //     print('❌ Login Error: $e');
  //     return {
  //       'success': false,
  //       'message': 'Login failed: ${e.toString()}',
  //       'statusCode': 500,
  //     };
  //   }
  // }

  // ==================== VERIFY LOGIN OTP (Step 2) ====================
  Future<Map<String, dynamic>> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print('🔐 AuthService: Verifying login OTP for $email');

      final response = await _api.post(
        ApiEndpoints.verifyLogin,
        body: {
          'email': email,
          'otp': otp,
        },
        requiresAuth: false,
      );

      print('✅ Verify Login OTP Response: ${json.encode(response)}');

      // Save tokens and user data if successful
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        if (data['accessToken'] != null) {
          await StorageService.saveToken(data['accessToken']);
          print('🔑 Access token saved');
        }

        if (data['refreshToken'] != null) {
          await StorageService.saveRefreshToken(data['refreshToken']);
          print('🔑 Refresh token saved');
        }

        if (data['user'] != null) {
          await StorageService.saveUser(data['user']);
          print('👤 User data saved');
        }
      }

      return response;
    } catch (e) {
      print('❌ Verify Login OTP Error: $e');
      return {
        'success': false,
        'message': 'OTP verification failed: ${e.toString()}',
        'statusCode': 500,
      };
    }
  }

  // ==================== LOGOUT ====================
  Future<Map<String, dynamic>> logout() async {
    try {
      print('🚪 AuthService: Logging out');

      final response = await _api.post(
        ApiEndpoints.logout,
        requiresAuth: true,
      );

      // Always clear local storage
      await StorageService.logout();

      return response;
    } catch (e) {
      print('⚠️ Logout Error: $e');
      // Still clear local storage
      await StorageService.logout();
      return {
        'success': true,
        'message': 'Logged out locally',
      };
    }
  }

  // ==================== GET CURRENT USER ====================
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      print('👤 AuthService: Getting current user');

      final response = await _api.get(
        ApiEndpoints.currentUser,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        await StorageService.saveUser(response['data']);
      }

      return response;
    } catch (e) {
      print('❌ Get Current User Error: $e');
      return {
        'success': false,
        'message': 'Failed to get user: ${e.toString()}',
        'statusCode': 500,
      };
    }
  }

  // ==================== FORGOT PASSWORD ====================
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      print('🔑 AuthService: Forgot password for $email');

      final response = await _api.post(
        ApiEndpoints.forgotPassword,
        body: {'email': email},
        requiresAuth: false,
      );

      return response;
    } catch (e) {
      print('❌ Forgot Password Error: $e');
      return {
        'success': false,
        'message': 'Failed to send reset link: ${e.toString()}',
        'statusCode': 500,
      };
    }
  }

  // ==================== CHECK AUTH STATUS ====================
  Future<bool> isLoggedIn() async {
    try {
      final token = await StorageService.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('❌ Check Auth Status Error: $e');
      return false;
    }
  }

  // ==================== GET TOKEN ====================
  Future<String?> getToken() async {
    return await StorageService.getToken();
  }
}