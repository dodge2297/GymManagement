// admin_user_management.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AdminUserManagementPage extends StatefulWidget {
  final bool isAdmin;

  const AdminUserManagementPage({super.key, required this.isAdmin});

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      print('Auth state changed: ${user?.uid}');
    });
    if (!widget.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You do not have admin privileges')),
        );
      });
    }
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleUserStatus(String userId, bool currentStatus) async {
    final user = FirebaseAuth.instance.currentUser;
    print('Authenticated UID: ${user?.uid}');
    if (!widget.isAdmin || user == null) {
      print('User is not an admin or not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin privileges required')),
      );
      return;
    }
    print(
        'Attempting to toggle status for user: $userId, current status: $currentStatus');
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isDisabled': !currentStatus,
      });
      print('Successfully toggled status for user: $userId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'User ${!currentStatus ? 'disabled' : 'enabled'} successfully')),
      );
    } catch (e) {
      print('Error toggling user status for $userId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user status: $e')),
      );
    }
  }

  Future<void> _deleteUser(String userId) async {
    final user = FirebaseAuth.instance.currentUser;
    print('Authenticated UID: ${user?.uid}');
    if (!widget.isAdmin || user == null) {
      print('User is not an admin or not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin privileges required')),
      );
      return;
    }
    print('User email: ${user.email}');
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: 'admin123',
      );
      await user.reauthenticateWithCredential(credential);
      print('User re-authenticated successfully');
    } catch (e) {
      print('Error re-authenticating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to re-authenticate: $e')),
      );
      return;
    }

    print('Attempting to delete user: $userId');
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
            'Are you sure you want to delete this user? This will remove them from both Firestore and Authentication.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Call the deleteUser Cloud Function using cloud_functions
        final HttpsCallable callable =
            FirebaseFunctions.instanceFor(region: 'us-central1')
                .httpsCallable('deleteUser');
        print('Calling Cloud Function: deleteUser with userId: $userId');
        final result = await callable.call(<String, dynamic>{
          'userId': userId,
        });

        print('Function result: ${result.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.data['message'])),
        );
      } catch (e) {
        print('Error deleting user $userId: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid == null) {
      return const Center(child: Text('Not authenticated'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name or email',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                final users = snapshot.data!.docs.where((doc) {
                  final user = doc.data() as Map<String, dynamic>;
                  final name = (user['name'] ?? '').toString().toLowerCase();
                  final email = (user['email'] ?? '').toString().toLowerCase();
                  return doc.id != currentUserUid &&
                      (name.contains(_searchQuery) ||
                          email.contains(_searchQuery));
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text('No matching users found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    final userId = users[index].id;
                    final name = user['name'] ?? 'Unknown';
                    final email = user['email'] ?? 'No Email';
                    final isDisabled = user['isDisabled'] ?? false;
                    final isAdmin = user['isAdmin'] ?? false;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isAdmin ? Colors.blue : Colors.orange,
                          child: Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(email),
                            Text(
                              'Status: ${isDisabled ? 'Disabled' : 'Enabled'}',
                              style: TextStyle(
                                color: isDisabled ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShadButton(
                              onPressed: () =>
                                  _toggleUserStatus(userId, isDisabled),
                              child: Text(isDisabled ? 'Enable' : 'Disable'),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(userId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
