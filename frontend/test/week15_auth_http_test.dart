import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:student_feedback_routing/services/auth_service.dart';

void main() {
  setUp(() {
    AuthService.clearSession();
  });

  tearDown(() {
    AuthService.clearSession();
  });

  test('W15-UI-009: Successful login saves authentication state', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/login');

      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['email'], 'student@example.test');
      expect(body['password'], 'TestPassword123!');

      return http.Response(
        jsonEncode({
          'token': 'fictional-test-token',
          'user': {
            'id': 1,
            'name': 'Week 15 Student',
            'email': 'student@example.test',
            'role': 'student',
            'office': null,
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final user = await http.runWithClient(
      () => AuthService.login(
        email: ' student@example.test ',
        password: 'TestPassword123!',
      ),
      () => client,
    );

    expect(user['role'], 'student');
    expect(AuthService.isAuthenticated, isTrue);
    expect(AuthService.token, 'fictional-test-token');
    expect(AuthService.studentName, 'Week 15 Student');
    expect(AuthService.role, 'student');
    expect(
      AuthService.authHeaders['Authorization'],
      'Bearer fictional-test-token',
    );
  });

  test('W15-UI-010: Failed login does not save a session', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/login');

      return http.Response(
        jsonEncode({
          'message': 'Invalid credentials.',
        }),
        422,
        headers: {'content-type': 'application/json'},
      );
    });

    await expectLater(
      http.runWithClient(
        () => AuthService.login(
          email: 'student@example.test',
          password: 'WrongPassword',
        ),
        () => client,
      ),
      throwsException,
    );

    expect(AuthService.isAuthenticated, isFalse);
    expect(AuthService.token, isNull);
    expect(AuthService.currentUser, isNull);
  });

  test('W15-UI-011: Unsupported role is rejected', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'token': 'unsupported-role-test-token',
          'user': {
            'id': 2,
            'name': 'Unsupported Role',
            'email': 'unsupported@example.test',
            'role': 'administrator',
            'office': null,
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await expectLater(
      http.runWithClient(
        () => AuthService.login(
          email: 'unsupported@example.test',
          password: 'TestPassword123!',
        ),
        () => client,
      ),
      throwsException,
    );

    expect(AuthService.isAuthenticated, isFalse);
    expect(AuthService.token, isNull);
  });

  test('W15-UI-012: Logout clears session and sends token', () async {
    var logoutRequested = false;

    final client = MockClient((request) async {
      if (request.url.path == '/api/login') {
        return http.Response(
          jsonEncode({
            'token': 'logout-test-token',
            'user': {
              'id': 3,
              'name': 'Logout Test Student',
              'email': 'logout@example.test',
              'role': 'student',
              'office': null,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.url.path == '/api/logout') {
        logoutRequested = true;

        expect(request.method, 'POST');
        expect(
          request.headers['Authorization'],
          'Bearer logout-test-token',
        );

        // Local authentication must already be cleared.
        expect(AuthService.isAuthenticated, isFalse);

        return http.Response(
          jsonEncode({'message': 'Logged out successfully.'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('Not found', 404);
    });

    await http.runWithClient(() async {
      await AuthService.login(
        email: 'logout@example.test',
        password: 'TestPassword123!',
      );

      expect(AuthService.isAuthenticated, isTrue);

      await AuthService.logout();
    }, () => client);

    expect(logoutRequested, isTrue);
    expect(AuthService.isAuthenticated, isFalse);
    expect(AuthService.token, isNull);
    expect(AuthService.currentUser, isNull);
  });
}
