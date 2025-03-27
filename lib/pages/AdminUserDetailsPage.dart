import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserDetailsPage extends StatelessWidget {
  final String userId;
  const AdminUserDetailsPage({super.key, required this.userId});

  Future<Map<String, dynamic>> _getSubscriptionStatus() async {
    print('Checking subscription status for userId: $userId');
    try {
      final paymentSnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'COMPLETED')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (paymentSnapshot.docs.isEmpty) {
        print('No completed payments found for userId: $userId');
        return {'hasPaid': false, 'plan': 'None', 'expiresOn': null};
      }

      final latestPayment = paymentSnapshot.docs.first.data();
      final timestamp = (latestPayment['timestamp'] as Timestamp?)?.toDate();
      final planDuration = latestPayment['plan'] as String?;

      print('Latest payment: $latestPayment');

      if (timestamp == null || planDuration == null) {
        print('Invalid payment data: timestamp or plan missing');
        return {'hasPaid': false, 'plan': 'Unknown', 'expiresOn': null};
      }

      int months = int.tryParse(planDuration.split(' ').first) ?? 0;
      final expirationDate = timestamp.add(Duration(days: months * 30));
      final currentDate = DateTime.now();

      final hasPaid = currentDate.isBefore(expirationDate);
      return {
        'hasPaid': hasPaid,
        'plan': planDuration,
        'expiresOn': expirationDate,
      };
    } catch (e) {
      print('Error fetching subscription status: $e');
      return {'hasPaid': false, 'plan': 'Error', 'expiresOn': null};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          final user = userSnapshot.data!.data() as Map<String, dynamic>;
          final name = user['name'] ?? 'Unknown';
          final email = user['email'] ?? 'No Email';
          final isAdmin = user['isAdmin'] ?? false;
          final createdAt =
              (user['createdAt'] as Timestamp?)?.toDate().toString() ??
                  'Unknown';
          final isDisabled = user['isDisabled'] ?? false;
          final age = user['age']?.toString() ?? 'Not set';
          final phone = user['phone']?.toString() ?? 'Not set';
          final address = user['address']?.toString() ?? 'Not set';
          final countryCode = user['countryCode']?.toString() ?? 'Not set';
          final bloodGroup = user['bloodGroup']?.toString() ?? 'Not set';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                    isAdmin ? Colors.blue : Colors.orange,
                                child: Text(
                                  name[0].toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      email,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('Admin: ${isAdmin ? 'Yes' : 'No'}'),
                          Text('Disabled: ${isDisabled ? 'Yes' : 'No'}'),
                          Text('Created: $createdAt'),
                          const SizedBox(height: 8),
                          Text('Age: $age'),
                          Text('Phone: $countryCode $phone'),
                          Text('Address: $address'),
                          Text('Blood Group: $bloodGroup'),
                          const SizedBox(height: 16),
                          FutureBuilder<Map<String, dynamic>>(
                            future: _getSubscriptionStatus(),
                            builder: (context, paymentSnapshot) {
                              if (paymentSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text(
                                    'Subscription Status: Checking...');
                              }
                              if (paymentSnapshot.hasError) {
                                return Text(
                                    'Subscription Status: Error - ${paymentSnapshot.error}');
                              }
                              final status = paymentSnapshot.data!;
                              final hasPaid = status['hasPaid'] as bool;
                              final plan = status['plan'] as String;
                              final expiresOn =
                                  status['expiresOn'] as DateTime?;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fees Paid: ${hasPaid ? 'Yes' : 'No'}',
                                    style: TextStyle(
                                      color:
                                          hasPaid ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Plan: $plan'),
                                  Text(
                                    'Expires On: ${expiresOn != null ? expiresOn.toString().split(' ')[0] : 'N/A'}',
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
