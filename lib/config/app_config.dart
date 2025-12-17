class AppConfig {
  // REAL API Base URL
  static const String baseUrl = 'https://social-media-backend-a7wy.onrender.com';
  static const int apiTimeout = 60;

  // API Version-for proper endpoint construction
  static const String apiVersion = "/api/v1";

  // Full API Base URL
  static String get apiBaseUrl => "$baseUrl$apiVersion";

  // Change this to false for real API
  static const bool useDummyData = false;

  // App Info
  static const String appName = 'clickME';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int postsPerPage = 10;
  static const int storiesPerPage = 20;

  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB

  // Session
  static const int tokenExpiryHours = 24;

  // OTP Timer (in seconds)
  static const int otpExpirySeconds = 120; // 2 minutes as per API doc


// API Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

// API Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}


// class AppConfig {

//   // API Base URL - Yahan sirf ye URL change karna hai later
//   static const String baseUrl = 'https://api.clickme.com'; // Dummy URL
//   // static const String baseUrl = 'https://social-media-backend-a7wy.onrender.com';
//   //   static const String baseUrl = 'https://social-media-backend-a7wy.onrender.com';
//
//   // Change this to false when real API is ready
//   static const bool useDummyData = true;
//   // static const bool useDummyData = false;
//
//   // App Info
//   static const String appName = 'clickME';
//   static const String appVersion = '1.0.0';
//
//   // Pagination
//   static const int postsPerPage = 10;
//   static const int storiesPerPage = 20;
//
//   // File Upload
//   static const int maxImageSize = 5 * 1024 * 1024; // 5MB
//   static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
//
//   // Session
//   static const int tokenExpiryHours = 24;
// }