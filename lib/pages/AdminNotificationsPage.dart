// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_app/pages/routes.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _selectedUserId; // Nullable
  late Future<List<Map<String, String>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture =
        FirebaseFirestore.instance.collection('users').get().then((snapshot) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final isAdmin = data['isAdmin'] as bool? ?? false;
        print(
            'User ${doc.id} isAdmin: $isAdmin, Current User: ${currentUser?.uid}'); // Debug log
        return !isAdmin &&
            doc.id != currentUser?.uid; // Exclude admins and current user
      }).toList();
      return filteredDocs
          .map((doc) => <String, String>{
                'uid': doc.id,
                'name': doc.data()['name'] ?? 'Unknown User',
                'email': doc.data()['email'] ?? 'No Email',
              })
          .toList();
    });
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginRegister);
      } else if (mounted) {
        setState(() {}); // Refresh the dropdown when user changes
      }
    });

    // Add listeners to trigger rebuild on text changes
    _titleController.addListener(_updateButtonState);
    _bodyController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {}); // Rebuild to update button state
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateButtonState);
    _bodyController.removeListener(_updateButtonState);
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _sendNotification() async {
    if (_formKey.currentState!.validate() && _selectedUserId != null) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin not logged in')),
          );
          return;
        }
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': _titleController.text,
          'body': _bodyController.text,
          'targetUserId': _selectedUserId!,
          'senderId': currentUser.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent!')),
        );
        _titleController.clear();
        _bodyController.clear();
        setState(() {
          _selectedUserId = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending notification: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target user')),
      );
    }
  }

  void _sendBulkNotification() async {
    print(
        'Attempting bulk send - Title: ${_titleController.text}, Body: ${_bodyController.text}');
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and body')),
      );
      return;
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin not logged in')),
        );
        return;
      }

      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final nonAdminUsers = usersSnapshot.docs.where((doc) {
        final data = doc.data();
        final isAdmin = data['isAdmin'] ?? false;
        return !isAdmin && doc.id != currentUser.uid;
      }).toList();

      if (nonAdminUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No non-admin users to notify')),
        );
        return;
      }

      for (var userDoc in nonAdminUsers) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': _titleController.text,
          'body': _bodyController.text,
          'targetUserId': userDoc.id,
          'senderId': currentUser.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Notifications sent to ${nonAdminUsers.length} users!')),
      );
      _titleController.clear();
      _bodyController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending bulk notification: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in as admin')),
      );
    }

    print(
        'Build - Title: ${_titleController.text}, Body: ${_bodyController.text}, '
        'Send Enabled: ${_titleController.text.isNotEmpty && _bodyController.text.isNotEmpty && _selectedUserId != null}, '
        'Bulk Enabled: ${_titleController.text.isNotEmpty && _bodyController.text.isNotEmpty}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch buttons to full width
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bodyController,
                    decoration: const InputDecoration(labelText: 'Body'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a body';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, String>>>(
                    future: _usersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error loading users: ${snapshot.error}');
                      }
                      final users = snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: 'Select Target User'),
                        value: _selectedUserId,
                        hint: const Text('Select Target User'),
                        items: users.map<DropdownMenuItem<String>>((user) {
                          return DropdownMenuItem<String>(
                            value: user['uid'],
                            child: Text('${user['name']} (${user['email']})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUserId = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a user' : null,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _titleController.text.isNotEmpty &&
                      _bodyController.text.isNotEmpty &&
                      _selectedUserId != null
                  ? _sendNotification
                  : null,
              child: const Text('Send Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _titleController.text.isNotEmpty &&
                      _bodyController.text.isNotEmpty
                  ? _sendBulkNotification
                  : null,
              child: const Text('Send to All Users'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
