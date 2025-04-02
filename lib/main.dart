import 'package:firebase_core/firebase_core.dart';
import 'package:gym_track/pages/auth_page.dart';
import 'package:gym_track/pages/adminpage.dart';
import 'package:gym_track/pages/homepage.dart';
import 'firebase_options.dart';
import 'package:gym_track/pages/routes.dart';
import 'package:gym_track/pages/adminroutes.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print(
      'Firebase project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
  print('Firebase app ID: ${DefaultFirebaseOptions.currentPlatform.appId}');
  print('Firebase API key: ${DefaultFirebaseOptions.currentPlatform.apiKey}');

  final initialUser = FirebaseAuth.instance.currentUser;
  if (initialUser != null) {
    try {
      final token = await initialUser.getIdToken(true);
      print(
          'Initial auth state: ${initialUser.uid}, Email: ${initialUser.email}, Token: $token');
      print('Token length: ${token != null ? token.length : "null"}');
    } catch (e) {
      print('Error refreshing initial token: $e');
      await FirebaseAuth.instance.signOut();
    }
  } else {
    print('Initial auth state: No user logged in');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.material(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, firestoreSnapshot) {
                if (firestoreSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (firestoreSnapshot.hasData &&
                    firestoreSnapshot.data!.exists) {
                  final data =
                      firestoreSnapshot.data!.data() as Map<String, dynamic>?;
                  final isAdmin = data?['isAdmin'] == true;
                  return isAdmin ? const AdminPage() : const HomePage();
                }
                return const HomePage();
              },
            );
          }
          return const AuthPage();
        },
      ),
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name != null && settings.name!.startsWith('/admin')) {
          return AdminRoutes.onGenerateRoute(settings);
        }
        return AppRoutes.onGenerateRoute(settings);
      },
    );
  }
}
