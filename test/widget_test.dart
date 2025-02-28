import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/pages/HomePage.dart';

void main() {
  testWidgets('HomeScreen UI Test', (WidgetTester tester) async {
    // Load the HomeScreen widget
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    // Check if the app bar title "GYM TRACK" is displayed
    expect(find.text('GYM TRACK'), findsOneWidget);

    // Check if the "Exercises" button exists
    expect(find.text('Exercises'), findsOneWidget);
  });
}
