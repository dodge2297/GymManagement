import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_app/pages/login_register.dart';
import 'HomePage.dart';
import 'adminpage.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
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
                  bool isAdmin =
                      firestoreSnapshot.data!.get('isAdmin') ?? false;
                  return isAdmin ? const AdminPage() : const HomePage();
                }
                return const HomePage();
              },
            );
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
