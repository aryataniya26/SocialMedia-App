import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  // Initialize
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserData = 'user_data';

  // Auth Token
  static Future<bool> saveToken(String token) async {
    return await _prefs.setString(_keyToken, token);
  }

  static String? getToken() {
    return _prefs.getString(_keyToken);
  }

  static Future<bool> removeToken() async {
    return await _prefs.remove(_keyToken);
  }

  // Refresh Token
  static Future<bool> saveRefreshToken(String token) async {
    return await _prefs.setString(_keyRefreshToken, token);
  }

  static String? getRefreshToken() {
    return _prefs.getString(_keyRefreshToken);
  }

  // User ID
  static Future<bool> saveUserId(String userId) async {
    return await _prefs.setString(_keyUserId, userId);
  }

  static String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Login Status
  static Future<bool> setLoggedIn(bool value) async {
    return await _prefs.setBool(_keyIsLoggedIn, value);
  }

  static bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // User Data
  static Future<bool> saveUserData(String jsonData) async {
    return await _prefs.setString(_keyUserData, jsonData);
  }

  static String? getUserData() {
    return _prefs.getString(_keyUserData);
  }

  // Clear All
  static Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  // Logout
  static Future<void> logout() async {
    await removeToken();
    await setLoggedIn(false);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserData);
  }
}