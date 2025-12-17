import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== TOKEN MANAGEMENT ====================
  static Future<void> saveToken(String token) async {
    await _prefs?.setString('auth_token', token);
    print('🔑 Token saved: ${token.substring(0, 20)}...');
  }

  static Future<String?> getToken() async {
    final token = _prefs?.getString('auth_token');
    print('🔑 Token retrieved: ${token != null ? 'Exists' : 'Null'}');
    return token;
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    await _prefs?.setString('refresh_token', refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    return _prefs?.getString('refresh_token');
  }

  static Future<void> clearTokens() async {
    await _prefs?.remove('auth_token');
    await _prefs?.remove('refresh_token');
    print('🔑 Tokens cleared');
  }

  // ==================== USER DATA MANAGEMENT ====================
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await _prefs?.setString('user_data', json.encode(userData));
      print('👤 User data saved: ${userData['email'] ?? 'No email'}');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final userString = _prefs?.getString('user_data');
      if (userString != null && userString.isNotEmpty) {
        final userData = json.decode(userString);
        print('👤 User data retrieved');
        return userData;
      }
    } catch (e) {
      print('❌ Error getting user data: $e');
    }
    return null;
  }

  static Future<void> saveUserId(String userId) async {
    await _prefs?.setString('user_id', userId);
  }

  static Future<String?> getUserId() async {
    return _prefs?.getString('user_id');
  }

  static Future<void> clearUserData() async {
    await _prefs?.remove('user_data');
    await _prefs?.remove('user_id');
    print('👤 User data cleared');
  }

  // ==================== AUTH STATUS ====================
  static Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool('is_logged_in', value);
  }

  static bool isLoggedIn() {
    return _prefs?.getBool('is_logged_in') ?? false;
  }

  // ==================== LOGOUT (CLEAR ALL) ====================
  static Future<void> logout() async {
    try {
      await clearTokens();
      await clearUserData();
      await setLoggedIn(false);
      print('🚪 Storage: All data cleared (logout)');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  // ==================== TEMP DATA (FOR OTP FLOW) ====================
  static Future<void> saveTempEmail(String email) async {
    await _prefs?.setString('temp_email', email);
  }

  static Future<String?> getTempEmail() async {
    return _prefs?.getString('temp_email');
  }

  static Future<void> saveTempUserId(String userId) async {
    await _prefs?.setString('temp_user_id', userId);
  }

  static Future<String?> getTempUserId() async {
    return _prefs?.getString('temp_user_id');
  }

  static Future<void> clearTempData() async {
    await _prefs?.remove('temp_email');
    await _prefs?.remove('temp_user_id');
  }

  // ==================== APP SETTINGS ====================
  static Future<void> saveLanguage(String language) async {
    await _prefs?.setString('app_language', language);
  }

  static Future<String?> getLanguage() async {
    return _prefs?.getString('app_language');
  }

  static Future<void> saveThemeMode(bool isDark) async {
    await _prefs?.setBool('is_dark_mode', isDark);
  }

  static bool getThemeMode() {
    return _prefs?.getBool('is_dark_mode') ?? false;
  }
}
