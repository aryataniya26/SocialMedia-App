import 'package:clickme_app/core/constants/api_endpoints.dart';
import 'package:clickme_app/data/services/api_service.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;
  String? _tempUserId;
  String? _tempEmail;

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

  // Initialize and check existing session
  Future<void> initialize() async {
    try {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        final userData = await StorageService.getUser();
        if (userData != null) {
          _currentUser = UserModel.fromJson(userData);
          notifyListeners();
          print('✅ User loaded from storage: ${_currentUser?.email}');
        }
      }
    } catch (e) {
      print('❌ Error initializing auth: $e');
    }
  }

  // ==================== REGISTER (Step 1) ====================
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
      );

      _setLoading(false);

      if (response['success'] == true) {
        // Save temp data for OTP verification
        _tempUserId = response['data']?['userId'];
        _tempEmail = response['data']?['email'];

        return {
          'success': true,
          'userId': _tempUserId,
          'email': _tempEmail,
          'message': response['message'] ?? 'OTP sent to your email',
        };
      } else {
        _setError(response['message'] ?? 'Registration failed');
        return {
          'success': false,
          'message': response['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      _setLoading(false);
      _setError('Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
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
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.verifyRegistrationOtp(
        email: email,
        userId: userId,
        otp: otp,
        phone: phone,
      );

      _setLoading(false);

      if (response['success'] == true) {
        // User is now verified (but not logged in yet)
        // They will login separately
        return {
          'success': true,
          'message': response['message'] ?? 'Registration successful',
        };
      } else {
        _setError(response['message'] ?? 'Invalid OTP');
        return {
          'success': false,
          'message': response['message'] ?? 'Invalid OTP',
        };
      }
    } catch (e) {
      _setLoading(false);
      _setError('Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ==================== LOGIN (Step 1: Send OTP) ====================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      _setLoading(false);

      if (response['success'] == true) {
        // Save temp data for OTP verification
        _tempUserId = response['data']?['userId'];
        _tempEmail = response['data']?['email'];

        return {
          'success': true,
          'userId': _tempUserId,
          'email': _tempEmail,
          'message': response['message'] ?? 'OTP sent to your email',
        };
      } else {
        _setError(response['message'] ?? 'Login failed');
        return {
          'success': false,
          'message': response['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      _setLoading(false);
      _setError('Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ==================== VERIFY LOGIN OTP (Step 2) ====================
  Future<Map<String, dynamic>> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.verifyLoginOtp(
        email: email,
        otp: otp,
      );

      _setLoading(false);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        if (data['user'] != null) {
          _currentUser = UserModel.fromJson(data['user']);
          notifyListeners();
          print('✅ User logged in: ${_currentUser?.email}');
        }

        return {
          'success': true,
          'user': _currentUser,
          'message': response['message'] ?? 'Login successful',
        };
      } else {
        _setError(response['message'] ?? 'Invalid OTP');
        return {
          'success': false,
          'message': response['message'] ?? 'Invalid OTP',
        };
      }
    } catch (e) {
      _setLoading(false);
      _setError('Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      print('Logout error: $e');
    }

    _currentUser = null;
    _tempUserId = null;
    _tempEmail = null;
    notifyListeners();
  }

  // ==================== RESET PASSWORD ====================
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // We'll add the resetPassword method to AuthService first
      // For now, we'll use the API service directly
      final response = await ApiService().post(
      ApiEndpoints.resetPassword,
        body: {
          'token': token,
          'newPassword': newPassword,
        },
        requiresAuth: false,
      );

      _setLoading(false);

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Password reset successful',
        };
      } else {
        _setError(response['message'] ?? 'Failed to reset password');
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      _setLoading(false);
      _setError('Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
  // ==================== FORGOT PASSWORD ====================
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _authService.forgotPassword(email);

      _setLoading(false);

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Reset link sent',
        };
      } else {
        _setError(response['message'] ?? 'Failed to send reset link');
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to send reset link',
        };
      }
    } catch (e) {
      _setLoading(false);
      _setError('Error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ==================== GET CURRENT USER FROM API ====================
  Future<bool> fetchCurrentUser() async {
    _setLoading(true);

    try {
      final response = await _authService.getCurrentUser();

      _setLoading(false);

      if (response['success'] == true && response['data'] != null) {
        _currentUser = UserModel.fromJson(response['data']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear temp data
  void clearTempData() {
    _tempUserId = null;
    _tempEmail = null;
  }
}
