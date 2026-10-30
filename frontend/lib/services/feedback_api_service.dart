
import 'dart:convert';
import 'package:http/http.dart' as http;

class FeedbackApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>> submitFeedback({
    required String studentName,
    required String title,
    required String category,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'student_name': studentName,
        'title': title,
        'category': category,
        'description': description,
      }),
    );

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
    final response = await http.get(
      Uri.parse('$baseUrl/feedback'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load feedback.');
  }
}
