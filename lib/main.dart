import 'package:firebase_core/firebase_core.dart';
import 'package:gym_app/pages/auth_page.dart';
import 'firebase_options.dart';
import 'pages/routes.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.material(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
