import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_track/pages/HomePage.dart';

void main() {
  testWidgets('HomeScreen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomePage()));
    expect(find.text('GYM TRACK'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
  });
}
