import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:student_feedback_routing/services/auth_service.dart';
import 'package:student_feedback_routing/services/feedback_api_service.dart';

void main() {
  setUp(AuthService.clearSession);
  tearDown(AuthService.clearSession);

  Future<void> simulateLogin(
    MockClient client, {
    String role = 'student',
  }) async {
    await http.runWithClient(
      () => AuthService.login(
        email: 'week15@example.test',
        password: 'TestPassword123!',
      ),
      () => client,
    );
  }

  MockClient createClient({
    required int feedbackStatus,
    required String feedbackBody,
  }) {
    return MockClient((request) async {
      if (request.url.path == '/api/login') {
        return http.Response(
          jsonEncode({
            'token': 'week15-retrieval-token',
            'user': {
              'id': 1,
              'name': 'Week 15 Student',
              'email': 'week15@example.test',
              'role': 'student',
              'office': null,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.url.path == '/api/feedback') {
        expect(request.method, 'GET');
        expect(
          request.headers['Authorization'],
          'Bearer week15-retrieval-token',
        );

        return http.Response(
          feedbackBody,
          feedbackStatus,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('Not found', 404);
    });
  }

  test('W15-UI-018: Feedback list loads successfully', () async {
    final client = createClient(
      feedbackStatus: 200,
      feedbackBody: jsonEncode([
        {
          'id': 1,
          'title': 'Academic Concern',
          'category': 'Academic',
          'status': 'Pending',
        },
        {
          'id': 2,
          'title': 'Facilities Concern',
          'category': 'Facilities',
          'status': 'Pending',
        },
      ]),
    );

    await simulateLogin(client);

    await http.runWithClient(() async {
      final feedback = await FeedbackApiService.getFeedback();

      expect(feedback.length, 2);
      expect(feedback[0]['title'], 'Academic Concern');
      expect(feedback[1]['category'], 'Facilities');
      expect(AuthService.isAuthenticated, isTrue);
    }, () => client);
  });

  test('W15-UI-019: Empty feedback list is handled', () async {
    final client = createClient(
      feedbackStatus: 200,
      feedbackBody: '[]',
    );

    await simulateLogin(client);

    await http.runWithClient(() async {
      final feedback = await FeedbackApiService.getFeedback();

      expect(feedback, isEmpty);
      expect(AuthService.isAuthenticated, isTrue);
    }, () => client);
  });

  test('W15-UI-020: Feedback retrieval requires login', () async {
    await expectLater(
      FeedbackApiService.getFeedback(),
      throwsA(
        predicate(
          (error) => error.toString().contains(
            'Please log in to view feedback.',
          ),
        ),
      ),
    );

    expect(AuthService.isAuthenticated, isFalse);
  });

  test('W15-UI-021: Forbidden feedback access is rejected', () async {
    final client = createClient(
      feedbackStatus: 403,
      feedbackBody: jsonEncode({
        'message': 'Forbidden.',
      }),
    );

    await simulateLogin(client);

    await http.runWithClient(() async {
      await expectLater(
        FeedbackApiService.getFeedback(),
        throwsA(
          predicate(
            (error) => error.toString().contains(
              'You are not authorized to view this feedback.',
            ),
          ),
        ),
      );

      expect(AuthService.isAuthenticated, isTrue);
    }, () => client);
  });

  test('W15-UI-022: Expired session clears login state', () async {
    final client = createClient(
      feedbackStatus: 401,
      feedbackBody: jsonEncode({
        'message': 'Unauthenticated.',
      }),
    );

    await simulateLogin(client);

    await http.runWithClient(() async {
      await expectLater(
        FeedbackApiService.getFeedback(),
        throwsA(
          predicate(
            (error) => error.toString().contains(
              'Your session has expired.',
            ),
          ),
        ),
      );

      expect(AuthService.isAuthenticated, isFalse);
      expect(AuthService.token, isNull);
      expect(AuthService.currentUser, isNull);
    }, () => client);
  });
}
