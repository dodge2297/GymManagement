import 'package:flutter/material.dart';
import 'package:gym_app/pages/edit_profile_page.dart';
import 'auth_page.dart';
import 'HomePage.dart';
import 'Exercises.dart';
import 'login_register.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'abs_exercises.dart';
import 'legs_exercises.dart';
import 'upperbody_exercises.dart';
 



class AppRoutes {
  static const String auth = '/';
  static const String home = '/home';
  static const String exercises = '/exercises';
  static const String loginRegister = '/login_register';
  static const String login = '/login';
  static const String register = '/register';
  static const String absExercises = '/absExercises';
  static const String legsExercises = '/legsExercises';
  static const String upperBodyExercises = '/upperBodyExercises';
  static const String editProfile = '/edit_profile'; // Added Edit Profile Route

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return MaterialPageRoute(builder: (_) => AuthPage());
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case exercises:
        return MaterialPageRoute(builder: (_) => Exercises());
      case loginRegister:
        return MaterialPageRoute(builder: (_) => LoginOrRegister());
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage(onTap: () {}));
      case register:
        return MaterialPageRoute(builder: (_) => RegisterPage(onTap: () {}));
      case absExercises:
        return MaterialPageRoute(builder: (_) => AbsExercisesListPage());
      case legsExercises:
        return MaterialPageRoute(builder: (_) => LegsExercisesListPage());
      case upperBodyExercises:
        return MaterialPageRoute(builder: (_) => UpperBodyExercisesListPage());
      case editProfile:
        return MaterialPageRoute(builder: (_) => EditProfilePage()); // New Route
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Page Not Found')),
          ),
        );
    }
  }
}

