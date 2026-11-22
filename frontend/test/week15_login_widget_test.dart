import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:student_feedback_routing/login_page.dart';

void main() {
  Widget createTestApp() {
    return const MaterialApp(
      home: LoginPage(),
    );
  }

  testWidgets(
    'W15-UI-001: Login screen displays required controls',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      expect(
        find.text('Student Feedback Routing System'),
        findsOneWidget,
      );

      expect(
        find.text('Sign in to continue'),
        findsOneWidget,
      );

      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      );

      expect(find.text('Sign In'), findsOneWidget);
    },
  );

  testWidgets(
    'W15-UI-002: Empty login form displays validation errors',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(
        find.text('Enter a valid email address.'),
        findsOneWidget,
      );

      expect(
        find.text('Enter your password.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'W15-UI-003: Invalid email is rejected',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      final fields = find.byType(TextFormField);

      await tester.enterText(
        fields.at(0),
        'invalid-email',
      );

      await tester.enterText(
        fields.at(1),
        'TestPassword123!',
      );

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(
        find.text('Enter a valid email address.'),
        findsOneWidget,
      );

      expect(
        find.text('Enter your password.'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'W15-UI-004: Password is hidden by default',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      // EditableText exposes the actual password visibility state.
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText).at(1),
      );

      expect(editableText.obscureText, isTrue);

      expect(
        find.byIcon(Icons.visibility),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'W15-UI-005: Password visibility can be toggled',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      // Initially, the password must be hidden.
      EditableText editableText = tester.widget<EditableText>(
        find.byType(EditableText).at(1),
      );

      expect(editableText.obscureText, isTrue);

      // Show the password.
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      editableText = tester.widget<EditableText>(
        find.byType(EditableText).at(1),
      );

      expect(editableText.obscureText, isFalse);

      expect(
        find.byIcon(Icons.visibility_off),
        findsOneWidget,
      );

      // Hide the password again.
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      editableText = tester.widget<EditableText>(
        find.byType(EditableText).at(1),
      );

      expect(editableText.obscureText, isTrue);

      expect(
        find.byIcon(Icons.visibility),
        findsOneWidget,
      );
    },
  );
}

