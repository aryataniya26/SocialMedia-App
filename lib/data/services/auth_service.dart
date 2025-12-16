// lib/data/services/auth_service.dart

import 'api_service.dart';
import 'storage_service.dart';
import '../../core/constants/api_endpoints.dart';

class AuthService {
  final ApiService _api = ApiService();

  // ==================== SEND OTP ====================
  Future<Map<String, dynamic>> sendOtp({
    required String mobileOrEmail,
    required String purpose,
  }) async {
    try {
      print('📱 AuthService: Sending OTP to $mobileOrEmail');

      final response = await _api.post(
        ApiEndpoints.sendOtp,
        body: {
          if (mobileOrEmail.contains('@'))
            'email': mobileOrEmail
          else
            'mobile': mobileOrEmail,
          'purpose': purpose,
        },
        requiresAuth: false,
      );

      print('✅ AuthService: Send OTP Response - $response');
      return response;
    } catch (e) {
      print('❌ AuthService: Send OTP Error - $e');
      return {
        'success': false,
        'message': 'Failed to send OTP: ${e.toString()}',
      };
    }
  }

  // ==================== VERIFY OTP ====================
  Future<Map<String, dynamic>> verifyOtp({
    required String mobileOrEmail,
    required String otp,
  }) async {
    try {
      print('🔐 AuthService: Verifying OTP for $mobileOrEmail');

      final response = await _api.post(
        ApiEndpoints.verifyOtp,
        body: {
          if (mobileOrEmail.contains('@'))
            'email': mobileOrEmail
          else
            'mobile': mobileOrEmail,
          'otp': otp,
        },
        requiresAuth: false,
      );

      print('✅ AuthService: Verify OTP Response - $response');
      return response;
    } catch (e) {
      print('❌ AuthService: Verify OTP Error - $e');
      return {
        'success': false,
        'message': 'Failed to verify OTP: ${e.toString()}',
      };
    }
  }

  // ==================== REGISTER ====================
  Future<Map<String, dynamic>> register({
    required String name,
    required String mobile,
    String? email,
    required String gender,
    required String dob,
  }) async {
    try {
      print('📝 AuthService: Registering user');

      final response = await _api.post(
        ApiEndpoints.register,
        body: {
          'name': name,
          'full_name': name,
          'mobile': mobile,
          if (email != null && email.isNotEmpty) 'email': email,
          'gender': gender,
          'dob': dob,
        },
        requiresAuth: false,
      );

      print('✅ AuthService: Register Response - $response');
      return response;
    } catch (e) {
      print('❌ AuthService: Register Error - $e');
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // ==================== LOGIN ====================
  Future<Map<String, dynamic>> login({
    String? mobile,
    String? email,
    String? password,
    String? otp,
  }) async {
    try {
      print('🔐 AuthService: Login attempt');

      final response = await _api.post(
        ApiEndpoints.login,
        body: {
          if (mobile != null) 'mobile': mobile,
          if (email != null) 'email': email,
          if (password != null) 'password': password,
          if (otp != null) 'otp': otp,
        },
        requiresAuth: false,
      );

      print('✅ AuthService: Login Response - $response');
      return response;
    } catch (e) {
      print('❌ AuthService: Login Error - $e');
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
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

      // Clear storage even if API fails
      await StorageService.logout();

      print('✅ AuthService: Logout successful');
      return response;
    } catch (e) {
      print('❌ AuthService: Logout Error - $e');
      // Still clear local storage
      await StorageService.logout();
      return {
        'success': true, // Return success since local logout worked
        'message': 'Logged out locally',
      };
    }
  }

  // ==================== CHANGE PASSWORD ====================
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.changePassword,
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        requiresAuth: true,
      );

      return response;
    } catch (e) {
      print('❌ AuthService: Change Password Error - $e');
      return {
        'success': false,
        'message': 'Failed to change password: ${e.toString()}',
      };
    }
  }

  // ==================== FORGOT PASSWORD ====================
  Future<Map<String, dynamic>> forgotPassword(String mobileOrEmail) async {
    try {
      final response = await _api.post(
        ApiEndpoints.forgotPassword,
        body: {
          if (mobileOrEmail.contains('@'))
            'email': mobileOrEmail
          else
            'mobile': mobileOrEmail,
        },
        requiresAuth: false,
      );

      return response;
    } catch (e) {
      print('❌ AuthService: Forgot Password Error - $e');
      return {
        'success': false,
        'message': 'Failed to send reset link: ${e.toString()}',
      };
    }
  }

  // ==================== REFRESH TOKEN ====================
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = StorageService.getRefreshToken();

      if (refreshToken == null) {
        return {
          'success': false,
          'message': 'No refresh token found',
        };
      }

      final response = await _api.post(
        ApiEndpoints.refreshToken,
        body: {'refresh_token': refreshToken},
        requiresAuth: false,
      );

      // Save new tokens if successful
      if (response['success'] == true) {
        if (response['token'] != null) {
          await StorageService.saveToken(response['token']);
        }
        if (response['access_token'] != null) {
          await StorageService.saveToken(response['access_token']);
        }
      }

      return response;
    } catch (e) {
      print('❌ AuthService: Refresh Token Error - $e');
      return {
        'success': false,
        'message': 'Failed to refresh token: ${e.toString()}',
      };
    }
  }
}