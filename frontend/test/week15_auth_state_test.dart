import 'package:flutter_test/flutter_test.dart';
import 'package:student_feedback_routing/services/auth_service.dart';

void main() {
  setUp(() {
    AuthService.clearSession();
  });

  tearDown(() {
    AuthService.clearSession();
  });

  test('W15-UI-006: Clearing session removes authentication state', () {
    AuthService.clearSession();

    expect(AuthService.token, isNull);
    expect(AuthService.currentUser, isNull);
    expect(AuthService.isAuthenticated, isFalse);
    expect(AuthService.role, isEmpty);
    expect(AuthService.assignedOffice, isEmpty);
    expect(AuthService.studentName, isEmpty);
  });

  test('W15-UI-007: Anonymous requests have no bearer token', () {
    final headers = AuthService.authHeaders;

    expect(headers['Accept'], 'application/json');
    expect(headers['Content-Type'], 'application/json');

    expect(headers.containsKey('Authorization'), isFalse);
  });

  test('W15-UI-008: Logout without a session completes safely', () async {
    await AuthService.logout();

    expect(AuthService.isAuthenticated, isFalse);
    expect(AuthService.token, isNull);
    expect(AuthService.currentUser, isNull);
  });
}
