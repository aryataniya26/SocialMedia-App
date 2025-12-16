import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import 'storage_service.dart';
import 'dummy_data.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get Headers
  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = StorageService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Build Full URL
  // String _buildUrl(String endpoint) {
  //   // Remove leading slash if present
  //   final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
  //   return '${AppConfig.baseUrl}/$cleanEndpoint';
  // }
  String _buildUrl(String endpoint) {
    // Simply combine base + endpoint
    return '${AppConfig.baseUrl}$endpoint';
  }

// retry logic
  Future<Map<String, dynamic>> postWithRetry(
      String endpoint, {
        Map<String, dynamic>? body,
        bool requiresAuth = false,
        int maxRetries = 2,
      }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('🔄 Attempt $attempt/$maxRetries');

        if (attempt > 1) {
          // Wait before retry
          await Future.delayed(Duration(seconds: attempt * 5));
        }

        return await post(endpoint, body: body, requiresAuth: requiresAuth);
      } on Exception catch (e) {
        if (attempt == maxRetries) {
          rethrow;
        }
        continue;
      }
    }
    throw Exception('Failed after $maxRetries attempts');
  }
  // POST Request
  Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? body,
        bool requiresAuth = false,
      }) async {
    try {
      // Use Dummy Data if enabled
      if (AppConfig.useDummyData) {
        return DummyData.getResponse(endpoint, body);
      }

      final url = Uri.parse(_buildUrl(endpoint));

      print('🔵 POST Request: $url');
      print('📦 Body: ${json.encode(body)}');

      final response = await http.post(
        url,
        headers: _getHeaders(requiresAuth: requiresAuth),
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Backend is waking up (cold start). Please try again in 30 seconds.');
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // GET Request
  Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, String>? queryParams,
        bool requiresAuth = false,
      }) async {
    try {
      // Use Dummy Data if enabled
      if (AppConfig.useDummyData) {
        return DummyData.getResponse(endpoint);
      }

      var url = Uri.parse(_buildUrl(endpoint));

      if (queryParams != null && queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      print('🔵 GET Request: $url');

      final response = await http.get(
        url,
        headers: _getHeaders(requiresAuth: requiresAuth),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
      String endpoint, {
        Map<String, dynamic>? body,
        bool requiresAuth = false,
      }) async {
    try {
      if (AppConfig.useDummyData) {
        return DummyData.getResponse(endpoint, body);
      }

      final url = Uri.parse(_buildUrl(endpoint));

      print('🔵 PUT Request: $url');

      final response = await http.put(
        url,
        headers: _getHeaders(requiresAuth: requiresAuth),
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('📥 Response Status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(
      String endpoint, {
        bool requiresAuth = false,
      }) async {
    try {
      if (AppConfig.useDummyData) {
        return {'success': true, 'message': 'Deleted successfully'};
      }

      final url = Uri.parse(_buildUrl(endpoint));

      print('🔵 DELETE Request: $url');

      final response = await http.delete(
        url,
        headers: _getHeaders(requiresAuth: requiresAuth),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Handle Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final statusCode = response.statusCode;

      // Handle empty response
      if (response.body.isEmpty) {
        if (statusCode >= 200 && statusCode < 300) {
          return {'success': true, 'message': 'Success'};
        } else {
          return {
            'success': false,
            'message': 'Request failed with status: $statusCode',
            'code': statusCode,
          };
        }
      }

      final body = json.decode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        // Success response
        if (body is Map<String, dynamic>) {
          return {'success': true, ...body};
        } else {
          return {'success': true, 'data': body};
        }
      } else {
        // Error response
        return {
          'success': false,
          'message': body['message'] ?? body['error'] ?? 'Something went wrong',
          'code': statusCode,
        };
      }
    } catch (e) {
      print('❌ Response Parse Error: $e');
      return {
        'success': false,
        'message': 'Failed to parse response: ${e.toString()}',
      };
    }
  }
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../config/app_config.dart';
// import '../../core/constants/api_endpoints.dart';
// import 'storage_service.dart';
// import 'dummy_data.dart';
//
// class ApiService {
//   static final ApiService _instance = ApiService._internal();
//   factory ApiService() => _instance;
//   ApiService._internal();
//
//   // Get Headers
//   Map<String, String> _getHeaders({bool requiresAuth = false}) {
//     final headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };
//
//     if (requiresAuth) {
//       final token = StorageService.getToken();
//       if (token != null) {
//         headers['Authorization'] = 'Bearer $token';
//       }
//     }
//
//     return headers;
//   }
//
//   // POST Request
//   Future<Map<String, dynamic>> post(
//       String endpoint, {
//         Map<String, dynamic>? body,
//         bool requiresAuth = false,
//       }) async {
//     try {
//       // Use Dummy Data if enabled
//       if (AppConfig.useDummyData) {
//         return DummyData.getResponse(endpoint, body);
//       }
//
//       final url = Uri.parse(ApiEndpoints.getFullUrl(endpoint));
//       final response = await http.post(
//         url,
//         headers: _getHeaders(requiresAuth: requiresAuth),
//         body: json.encode(body),
//       );
//
//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }
//
//   // GET Request
//   Future<Map<String, dynamic>> get(
//       String endpoint, {
//         Map<String, String>? queryParams,
//         bool requiresAuth = false,
//       }) async {
//     try {
//       // Use Dummy Data if enabled
//       if (AppConfig.useDummyData) {
//         return DummyData.getResponse(endpoint);
//       }
//
//       var url = Uri.parse(ApiEndpoints.getFullUrl(endpoint));
//       if (queryParams != null) {
//         url = url.replace(queryParameters: queryParams);
//       }
//
//       final response = await http.get(
//         url,
//         headers: _getHeaders(requiresAuth: requiresAuth),
//       );
//
//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }
//
//   // PUT Request
//   Future<Map<String, dynamic>> put(
//       String endpoint, {
//         Map<String, dynamic>? body,
//         bool requiresAuth = false,
//       }) async {
//     try {
//       if (AppConfig.useDummyData) {
//         return DummyData.getResponse(endpoint, body);
//       }
//
//       final url = Uri.parse(ApiEndpoints.getFullUrl(endpoint));
//       final response = await http.put(
//         url,
//         headers: _getHeaders(requiresAuth: requiresAuth),
//         body: json.encode(body),
//       );
//
//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }
//
//   // DELETE Request
//   Future<Map<String, dynamic>> delete(
//       String endpoint, {
//         bool requiresAuth = false,
//       }) async {
//     try {
//       if (AppConfig.useDummyData) {
//         return {'success': true, 'message': 'Deleted successfully'};
//       }
//
//       final url = Uri.parse(ApiEndpoints.getFullUrl(endpoint));
//       final response = await http.delete(
//         url,
//         headers: _getHeaders(requiresAuth: requiresAuth),
//       );
//
//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'message': 'Network error: $e'};
//     }
//   }
//
//   // Handle Response
//   Map<String, dynamic> _handleResponse(http.Response response) {
//     final statusCode = response.statusCode;
//     final body = json.decode(response.body);
//
//     if (statusCode >= 200 && statusCode < 300) {
//       return {'success': true, ...body};
//     } else {
//       return {
//         'success': false,
//         'message': body['message'] ?? 'Something went wrong',
//         'code': statusCode,
//       };
//     }
//   }
// }