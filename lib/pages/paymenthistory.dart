import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    print("Current User: ${FirebaseAuth.instance.currentUser}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseAuth.instance.currentUser != null
            ? FirebaseFirestore.instance
                .collection('payments')
                .where('userId',
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .orderBy('timestamp', descending: true)
                .snapshots()
            : const Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                      'Error loading payment history. Please try again later.'),
                  const SizedBox(height: 10),
                  Text('Details: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No payment history available.'),
            );
          }

          final payments = snapshot.data!.docs;
          final total = payments.fold(0.0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return sum + ((data['amount'] as num?)?.toDouble() ?? 0.0);
          });
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Total Paid: ₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment =
                        payments[index].data() as Map<String, dynamic>? ?? {};
                    final timestamp =
                        (payment['timestamp'] as Timestamp?)?.toDate() ??
                            DateTime.now();
                    final amount =
                        (payment['amount'] as num?)?.toDouble() ?? 0.0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.payment, color: Colors.black),
                        title: Text('Plan: ${payment['plan'] ?? 'Unknown'}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Amount: ₹${amount.toStringAsFixed(2)}'),
                            Text(
                                'Trainer: ${payment['trainer'] == true ? 'Yes' : 'No'}'),
                            Text(
                                'Date: ${DateFormat('yyyy-MM-dd').format(timestamp)}'),
                          ],
                        ),
                        trailing: Text(payment['status'] ?? 'Unknown'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
