import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class FeedbackApiService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<Map<String, dynamic>> submitFeedback({
    required String title,
    required String category,
    required String description,
  }) async {
    if (!AuthService.isAuthenticated) {
      throw Exception('Please log in before submitting feedback.');
    }

    if (AuthService.role != 'student') {
      throw Exception('Only students can submit feedback.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: AuthService.authHeaders,
      body: jsonEncode({
        'title': title,
        'category': category,
        'description': description,
      }),
    );

    if (response.statusCode == 401) {
      AuthService.clearSession();
      throw Exception('Your session has expired. Please log in again.');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data is Map && data['message'] != null
          ? data['message'].toString()
          : 'Failed to submit feedback.',
    );
  }

  static Future<List<dynamic>> getFeedback() async {
    if (!AuthService.isAuthenticated) {
      throw Exception('Please log in to view feedback.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/feedback'),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 401) {
      AuthService.clearSession();
      throw Exception('Your session has expired. Please log in again.');
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    if (response.statusCode == 403) {
      throw Exception('You are not authorized to view this feedback.');
    }

    throw Exception('Failed to load feedback.');
  }
}
