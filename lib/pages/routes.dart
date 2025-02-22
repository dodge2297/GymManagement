import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'Exercises.dart';

class AppRoutes {
  static const String home = '/';
  static const String exercises = '/exercises';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case exercises:
        return MaterialPageRoute(builder: (_) => Exercises());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page Not Found')),
          ),
        );
    }
  }
}
