import 'package:flutter/material.dart';
import 'routes.dart';

class WorkoutPlanPage extends StatefulWidget {
  const WorkoutPlanPage({super.key});

  @override
  _WorkoutPlanPageState createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {
  final List<Map<String, dynamic>> workoutPlans = [
    {"duration": "1 Month", "withTrainer": true, "price": 1.0},
    {"duration": "3 Months", "withTrainer": true, "price": 1.0},
    {"duration": "6 Months", "withTrainer": true, "price": 1.0},
  ];

  late List<bool> trainerSelections;

  @override
  void initState() {
    super.initState();
    trainerSelections =
        workoutPlans.map((plan) => plan['withTrainer'] as bool).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plan'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: workoutPlans.length,
        itemBuilder: (context, index) {
          final plan = workoutPlans[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        plan['duration'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trainerSelections[index]
                            ? "Includes Trainer"
                            : "No Trainer",
                        style: TextStyle(
                          color: trainerSelections[index]
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                      Switch(
                        value: trainerSelections[index],
                        onChanged: (value) {
                          setState(() {
                            trainerSelections[index] = value;
                          });
                        },
                        activeColor: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.workoutPlanDetail,
                        arguments: {
                          'duration': plan['duration'],
                          'withTrainer': trainerSelections[index],
                          'price': 1.0,
                        },
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text(
                      "Select Plan (₹1.00)",
                      style: TextStyle(color: Colors.white),
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
