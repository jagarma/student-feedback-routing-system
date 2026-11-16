import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_feedback_routing/main.dart';

void main() {
  testWidgets('Login screen displays correctly', (tester) async {
    await tester.pumpWidget(const StudentFeedbackApp());

    expect(find.text('Student Feedback Routing System'), findsOneWidget);

    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign In'), findsOneWidget);
  });
}
