import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:gym_track/pages/routes.dart';

final Map<String, Future<String>> _senderNameFutures = {};

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Map<String, String> _userNames = {};
  final Map<String, Future<String>> _localSenderFutures = {};

  @override
  void initState() {
    super.initState();
    _loadUserNames();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginRegister);
      } else if (mounted) {
        print('Current user UID: ${user?.uid}');
        _checkAdminStatus(user?.uid);
      }
    });
  }

  Future<void> _loadUserNames() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      print('Fetched ${snapshot.docs.length} user documents');
      setState(() {
        _userNames = {
          for (var doc in snapshot.docs)
            doc.id: (doc.data()['name'] as String? ?? 'Unknown')
        };
      });
      print('User names map: $_userNames');
    } catch (e) {
      print('Error loading user names: $e');
    }
  }

  Future<void> _checkAdminStatus(String? uid) async {
    if (uid == null) return;
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final isAdmin = userDoc.data()?['isAdmin'] ?? false;
      print('User $uid isAdmin: $isAdmin');
    } catch (e) {
      print('Error checking admin status: $e');
    }
  }

  String _getCachedSenderName(String senderId) {
    return _userNames[senderId] ?? 'Loading...';
  }

  Future<String> _getSenderName(String senderId) async {
    if (!_localSenderFutures.containsKey(senderId)) {
      _localSenderFutures[senderId] = _senderNameFutures[senderId] ??
          (() async {
            try {
              return _userNames[senderId] ??
                  (await FirebaseFirestore.instance
                      .collection('users')
                      .doc(senderId)
                      .get()
                      .then((doc) =>
                          doc.data()?['name'] as String? ?? 'Unknown'));
            } catch (e) {
              print('Error fetching sender name for $senderId: $e');
              return 'Unknown';
            }
          })() as Future<String>;
    }
    return _localSenderFutures[senderId]!;
  }

  void _refreshNotifications() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleReadStatus(
      String notificationId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': !currentStatus});
      print('Toggled read status for $notificationId to ${!currentStatus}');
    } catch (e) {
      print('Error updating read status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update read status: $e')),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(notificationId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting notification: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotifications,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('targetUserId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          print(
              'Snapshot status: ${snapshot.connectionState}, Has error: ${snapshot.hasError}, Data length: ${snapshot.data?.docs.length}, Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading notifications: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>; // Cast needed
              String title = data['title'] ?? 'No Title';
              String body = data['body'] ?? 'No Body';
              Timestamp? timestamp = data['timestamp'];
              String senderId = data['senderId'] ?? 'Unknown Sender';
              bool isRead = data['isRead'] ?? false;
              String formattedTime = timestamp != null
                  ? DateFormat('MMM dd, hh:mm a').format(timestamp.toDate())
                  : 'Unknown';
              String senderName = _getCachedSenderName(senderId);
              if (!_localSenderFutures.containsKey(senderId)) {
                _localSenderFutures[senderId] = _getSenderName(senderId);
              }

              return FutureBuilder<String>(
                future: _localSenderFutures[senderId]!,
                builder: (context, senderSnapshot) {
                  if (senderSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: const Icon(Icons.notification_important),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isRead ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(body),
                            const SizedBox(height: 4),
                            Text(
                              'From: $senderName',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                            Text(formattedTime),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isRead
                                    ? Icons.mark_email_read
                                    : Icons.mark_email_unread,
                                color: isRead ? Colors.green : Colors.red,
                              ),
                              onPressed: () =>
                                  _toggleReadStatus(doc.id, isRead),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNotification(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  senderName = senderSnapshot.data ?? senderName;
                  if (senderSnapshot.data != _userNames[senderId]) {
                    print(
                        'Notification $index: senderId=$senderId, senderName=$senderName');
                  }

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: const Icon(Icons.notification_important),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isRead ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(body),
                          const SizedBox(height: 4),
                          Text(
                            'From: $senderName',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          Text(formattedTime),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isRead
                                  ? Icons.mark_email_read
                                  : Icons.mark_email_unread,
                              color: isRead ? Colors.green : Colors.red,
                            ),
                            onPressed: () => _toggleReadStatus(doc.id, isRead),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNotification(doc.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
