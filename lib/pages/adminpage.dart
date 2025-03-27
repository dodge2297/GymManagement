// admin_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_app/pages/routes.dart';
import 'package:gym_app/pages/adminroutes.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.loginRegister, (route) => false);
  }

  Future<String> _getAdminName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['name'] ?? 'Admin';
    }
    return 'Admin';
  }

  Future<void> _navigateToUserManagement(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      bool isAdmin = doc.exists ? (doc.data()!['isAdmin'] ?? false) : false;
      Navigator.pushNamed(
        context,
        AdminRoutes.adminUserManagement,
        arguments: isAdmin, // Pass isAdmin as an argument
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _getAdminName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading admin name'));
          }

          final adminName = snapshot.data ?? 'Admin';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome, $adminName!',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ShadButton(
                  width: double.infinity,
                  onPressed: () => Navigator.pushNamed(
                      context, AdminRoutes.adminNotifications),
                  child: const Text('Send Notifications'),
                ),
                const SizedBox(height: 15),
                ShadButton(
                  width: double.infinity,
                  onPressed: () =>
                      Navigator.pushNamed(context, AdminRoutes.adminUserList),
                  child: const Text('View User List'),
                ),
                const SizedBox(height: 15),
                ShadButton(
                  width: double.infinity,
                  onPressed: () => _navigateToUserManagement(context),
                  child: const Text('Manage Accounts'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
