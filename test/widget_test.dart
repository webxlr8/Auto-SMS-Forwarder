// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sms_forward_app/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SMSForwardApp());

    // Verify that the app title appears
    expect(find.text('SMS Forward'), findsOneWidget);
    
    // Since the app initially asks for permissions, we should see the permission request screen
    expect(find.text('SMS permissions are required to use this app'), findsOneWidget);
    expect(find.text('Grant Permissions'), findsOneWidget);
  });
}
