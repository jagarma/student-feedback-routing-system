import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:student_feedback_routing/services/auth_service.dart';
import 'package:student_feedback_routing/services/feedback_api_service.dart';

void main() {
  setUp(() {
    AuthService.clearSession();
  });

  tearDown(() {
    AuthService.clearSession();
  });

  Future<void> mockLogin({
    required String role,
    required MockClient client,
  }) async {
    await http.runWithClient(
      () => AuthService.login(
        email: 'week15@example.test',
        password: 'TestPassword123!',
      ),
      () => client,
    );
  }

  MockClient createLoginClient(String role) {
    return MockClient((request) async {
      if (request.url.path == '/api/login') {
        return http.Response(
          jsonEncode({
            'token': 'week15-fictional-token',
            'user': {
              'id': 1,
              'name': 'Week 15 Test User',
              'email': 'week15@example.test',
              'role': role,
              'office': role == 'staff'
                  ? 'Academic Affairs Office'
                  : null,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('Not found', 404);
    });
  }

  test(
    'W15-UI-013: Student submits feedback successfully',
    () async {
      var submissionCount = 0;

      final client = MockClient((request) async {
        if (request.url.path == '/api/login') {
          return http.Response(
            jsonEncode({
              'token': 'submission-test-token',
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
          submissionCount++;

          expect(request.method, 'POST');
          expect(
            request.headers['Authorization'],
            'Bearer submission-test-token',
          );

          final body =
              jsonDecode(request.body) as Map<String, dynamic>;

          expect(body['title'], 'Classroom Feedback');
          expect(body['category'], 'Facilities');
          expect(body['description'], 'Broken classroom chair.');
          expect(body.containsKey('user_id'), isFalse);

          return http.Response(
            jsonEncode({
              'message': 'Feedback submitted and routed successfully!',
              'routing_success': true,
              'feedback': {
                'id': 15,
                'title': 'Classroom Feedback',
                'category': 'Facilities',
                'assigned_office': 'Facilities Management Office',
                'status': 'Pending',
              },
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('Not found', 404);
      });

      await http.runWithClient(() async {
        await AuthService.login(
          email: 'week15@example.test',
          password: 'TestPassword123!',
        );

        final result = await FeedbackApiService.submitFeedback(
          title: 'Classroom Feedback',
          category: 'Facilities',
          description: 'Broken classroom chair.',
        );

        expect(result['routing_success'], isTrue);
        expect(result['feedback']['id'], 15);
        expect(
          result['feedback']['assigned_office'],
          'Facilities Management Office',
        );
      }, () => client);

      expect(submissionCount, 1);
    },
  );

  test(
    'W15-UI-014: Submission without login is rejected',
    () async {
      await expectLater(
        FeedbackApiService.submitFeedback(
          title: 'Anonymous Feedback',
          category: 'Academic',
          description: 'This should not be submitted.',
        ),
        throwsA(
          predicate(
            (error) => error.toString().contains(
              'Please log in before submitting feedback.',
            ),
          ),
        ),
      );

      expect(AuthService.isAuthenticated, isFalse);
    },
  );

  test(
    'W15-UI-015: Staff cannot submit student feedback',
    () async {
      final client = createLoginClient('staff');

      await mockLogin(role: 'staff', client: client);

      expect(AuthService.role, 'staff');

      await expectLater(
        FeedbackApiService.submitFeedback(
          title: 'Staff Submission',
          category: 'Academic',
          description: 'Staff should not submit student feedback.',
        ),
        throwsA(
          predicate(
            (error) => error.toString().contains(
              'Only students can submit feedback.',
            ),
          ),
        ),
      );
    },
  );

  test(
    'W15-UI-016: Invalid feedback response is handled',
    () async {
      final client = MockClient((request) async {
        if (request.url.path == '/api/login') {
          return http.Response(
            jsonEncode({
              'token': 'validation-test-token',
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
          return http.Response(
            jsonEncode({
              'message': 'The selected category is invalid.',
              'errors': {
                'category': ['The selected category is invalid.'],
              },
            }),
            422,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('Not found', 404);
      });

      await http.runWithClient(() async {
        await AuthService.login(
          email: 'week15@example.test',
          password: 'TestPassword123!',
        );

        await expectLater(
          FeedbackApiService.submitFeedback(
            title: 'Invalid Category',
            category: 'Unknown',
            description: 'Testing validation response.',
          ),
          throwsA(
            predicate(
              (error) => error.toString().contains(
                'The selected category is invalid.',
              ),
            ),
          ),
        );

        expect(AuthService.isAuthenticated, isTrue);
      }, () => client);
    },
  );

  test(
    'W15-UI-017: Expired session clears authentication',
    () async {
      final client = MockClient((request) async {
        if (request.url.path == '/api/login') {
          return http.Response(
            jsonEncode({
              'token': 'expired-session-test-token',
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
          return http.Response(
            jsonEncode({'message': 'Unauthenticated.'}),
            401,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('Not found', 404);
      });

      await http.runWithClient(() async {
        await AuthService.login(
          email: 'week15@example.test',
          password: 'TestPassword123!',
        );

        expect(AuthService.isAuthenticated, isTrue);

        await expectLater(
          FeedbackApiService.submitFeedback(
            title: 'Expired Session Test',
            category: 'Academic',
            description: 'Testing session expiration.',
          ),
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
    },
  );
}
