import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../../core/constants/api_endpoints.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _profile;
  bool _isLoading = false;

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;

  // Fetch User Profile
  Future<void> fetchProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiEndpoints.userProfile(userId),
        requiresAuth: true,
      );

      if (response['success'] == true) {
        _profile = UserModel.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update Profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.put(
        ApiEndpoints.updateProfile,
        body: data,
        requiresAuth: true,
      );

      _isLoading = false;
      notifyListeners();

      return response['success'] == true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}