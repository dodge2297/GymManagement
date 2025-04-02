import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_track/pages/login_page.dart';
import 'package:gym_track/pages/register_page.dart';
import 'package:gym_track/pages/adminpage.dart';
import 'package:gym_track/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final isAdmin = userDoc.get('isAdmin') ?? false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  isAdmin ? const AdminPage() : const HomePage()),
        );
      } catch (e) {
        print('Error fetching user role: $e');
      }
    }
  }

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return RegisterPage(onTap: togglePages);
    }
  }
}
