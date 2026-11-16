import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Stored in application memory only.
  static String? _token;
  static Map<String, dynamic>? _user;

  static String? get token => _token;
  static Map<String, dynamic>? get currentUser => _user;

  static bool get isAuthenticated => _token != null && _user != null;

  static String get role => _user?['role']?.toString() ?? '';

  static String get assignedOffice => _user?['office']?.toString() ?? '';

  static String get studentName => _user?['name']?.toString() ?? '';

  static Map<String, String> get authHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Never reuse credentials from an earlier login.
    clearSession();

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data is Map &&
        data['token'] is String &&
        data['user'] is Map) {
      final user = Map<String, dynamic>.from(data['user']);

      if (user['role'] != 'student' && user['role'] != 'staff') {
        throw Exception('Unsupported user role.');
      }

      _token = data['token'] as String;
      _user = user;

      return user;
    }

    throw Exception('Login failed. Please verify your credentials.');
  }

  static Future<void> logout() async {
    final existingToken = _token;

    // Immediately remove local access.
    clearSession();

    if (existingToken == null) return;

    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $existingToken',
        },
      );
    } catch (_) {
      // Local session remains cleared if the server is unreachable.
    }
  }

  static void clearSession() {
    _token = null;
    _user = null;
  }
}
