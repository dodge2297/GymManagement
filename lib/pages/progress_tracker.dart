import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weight_entry.dart';

class ProgressTrackerPage extends StatefulWidget {
  const ProgressTrackerPage({super.key});

  @override
  _ProgressTrackerPageState createState() => _ProgressTrackerPageState();
}

class _ProgressTrackerPageState extends State<ProgressTrackerPage> {
  final TextEditingController _weightController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _addWeightEntry() async {
    if (_weightController.text.isEmpty) return;

    double weight = double.tryParse(_weightController.text) ?? 0.0;
    if (weight <= 0) return;

    try {
      final entry = WeightEntry(weight: weight, date: DateTime.now());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('weight_entries')
          .add(entry.toMap());
      _weightController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add weight: $e')),
      );
    }
  }

  Future<void> _deleteWeightEntry(String entryId) async {
    if (entryId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('weight_entries')
          .doc(entryId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight entry deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete entry: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter your weight (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addWeightEntry,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('Add Weight',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              // Graph and history
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('weight_entries')
                    .orderBy('date',
                        descending: false) // Ascending order for the graph
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final entries = snapshot.data!.docs
                      .map((doc) => WeightEntry.fromMap(
                          doc.data() as Map<String, dynamic>, doc.id))
                      .toList();

                  if (entries.isEmpty) {
                    return const Center(
                      child: Text(
                        'No entries yet. Add your first weight!',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  // Calculate progress (change from first to last entry)
                  final initialWeight = entries.first.weight;
                  final currentWeight = entries.last.weight;
                  final weightChange = currentWeight - initialWeight;
                  final progressText = weightChange >= 0
                      ? '+${weightChange.toStringAsFixed(1)} kg (Gain)'
                      : '${weightChange.toStringAsFixed(1)} kg (Loss)';

                  return Column(
                    children: [
                      // Progress summary
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Progress: $progressText',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Graph showing weight over time
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          _buildLineChartData(entries),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // History list with delete option
                      SizedBox(
                        height:
                            300, // Define a fixed height for the history list
                        child: ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[entries.length -
                                1 -
                                index]; // Reverse for display
                            return Card(
                              color: Colors.grey[850],
                              child: ListTile(
                                title: Text(
                                  '${entry.weight} kg',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  entry.date.toString(),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    bool confirm = await showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirm Delete'),
                                            content: const Text(
                                                'Are you sure you want to delete this entry?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        ) ??
                                        false;
                                    if (confirm && entry.id.isNotEmpty) {
                                      _deleteWeightEntry(entry.id);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the line chart data for weight over time
  LineChartData _buildLineChartData(List<WeightEntry> entries) {
    // Convert dates to a scaled timestamp for the X-axis (days since epoch / 10000 for readability)
    final spots = entries.map((entry) {
      final timestamp = entry.date.millisecondsSinceEpoch /
          10000000; // Scaled down for better spacing
      return FlSpot(timestamp, entry.weight);
    }).toList();

    // Determine min and max for Y-axis (weights)
    final weights = entries.map((e) => e.weight).toList();
    final minWeight =
        (weights.reduce((a, b) => a < b ? a : b) - 10).floorToDouble();
    final maxWeight =
        (weights.reduce((a, b) => a > b ? a : b) + 10).ceilToDouble();

    // Determine min and max for X-axis (time)
    final minTime = entries.first.date.millisecondsSinceEpoch / 10000000;
    final maxTime = entries.last.date.millisecondsSinceEpoch / 10000000;

    // Set a default interval if the time range is too small
    double interval = (maxTime - minTime) / 4;
    if (interval <= 0 || entries.length <= 1) {
      interval = 1.0; // Default interval to avoid zero
    }

    return LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: interval, // Use the calculated or default interval
            getTitlesWidget: (value, meta) {
              final timestamp = (value * 10000000).round();
              final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
              if (date.isBefore(entries.last.date) &&
                  date.isAfter(entries.first.date)) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${date.day} ${const [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec'
                    ][date.month - 1]}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: minTime,
      maxX: maxTime,
      minY: minWeight,
      maxY: maxWeight,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          dotData:
              const FlDotData(show: true), // Show dots to highlight data points
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }
}
