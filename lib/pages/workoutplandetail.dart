import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';
import 'dart:async';

class WorkoutPlanDetailPage extends StatefulWidget {
  final Map<String, dynamic> plan;

  const WorkoutPlanDetailPage({super.key, required this.plan});

  @override
  _WorkoutPlanDetailPageState createState() => _WorkoutPlanDetailPageState();
}

class _WorkoutPlanDetailPageState extends State<WorkoutPlanDetailPage> {
  final String upiId = "dhiyabhisham8482@oksbi";
  String? upiUrl;
  bool paymentComplete = false;
  String transactionId = "Txn${DateTime.now().millisecondsSinceEpoch}";

  double getPrice() {
    return 1.0;
  }

  @override
  void initState() {
    super.initState();
    _generateUpiUrl();
  }

  void _generateUpiUrl() {
    upiUrl =
        "upi://pay?pa=$upiId&pn=Gym%20Admin&am=${getPrice()}&tn=Subscription%20for%20${Uri.encodeComponent(widget.plan['duration'])}&tr=$transactionId&cu=INR";
    setState(() {});
  }

  Future<void> _completePayment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to complete the payment.")),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.auth);
      return;
    }

    setState(() {
      paymentComplete = true;
    });

    try {
      await _storePaymentDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Recorded Successfully!"),
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error recording payment: $e")),
      );
      setState(() {
        paymentComplete = false;
      });
    }
  }

  Future<void> _storePaymentDetails() async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw Exception("User not authenticated");
    }
    await FirebaseFirestore.instance.collection('payments').add({
      'plan': widget.plan['duration'],
      'trainer': widget.plan['withTrainer'],
      'amount': getPrice(),
      'transactionId': transactionId,
      'status': "COMPLETED",
      'timestamp': FieldValue.serverTimestamp(),
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.plan['duration']} Plan Details"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${widget.plan['duration']} Plan",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                widget.plan['withTrainer']
                    ? "Includes Trainer Support"
                    : "No Trainer Included",
                style: TextStyle(
                  fontSize: 18,
                  color: widget.plan['withTrainer'] ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Price: ₹1.00",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (upiUrl != null && !paymentComplete)
                Column(
                  children: [
                    const Text(
                      "Scan this QR code to pay",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    QrImageView(
                      data: upiUrl!,
                      version: QrVersions.auto,
                      size: 200.0,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      onPressed: _completePayment,
                      child: const Text(
                        "I've Completed the Payment",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              if (paymentComplete)
                const Column(
                  children: [
                    Text(
                      "Payment Complete! Redirecting...",
                      style: TextStyle(fontSize: 18, color: Colors.green),
                    ),
                    SizedBox(height: 10),
                    CircularProgressIndicator(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
