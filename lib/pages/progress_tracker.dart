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
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _goalWeightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  DateTime _selectedDate = DateTime.now();
  double? _height;
  double? _goalWeight;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (mounted) {
        setState(() {
          _height = userDoc.data()?['height']?.toDouble();
          _goalWeight = userDoc.data()?['goalWeight']?.toDouble();
          if (_height != null) _heightController.text = _height.toString();
          if (_goalWeight != null)
            _goalWeightController.text = _goalWeight.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading user data: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setHeight() async {
    if (!_validateInput(_heightController.text, 'height')) return;

    double height = double.parse(_heightController.text);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({'height': height}, SetOptions(merge: true));
      if (mounted) {
        setState(() => _height = height);
        _showSnackBar('Height set successfully!');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Failed to set height: $e');
    }
  }

  Future<void> _setGoalWeight() async {
    if (!_validateInput(_goalWeightController.text, 'goal weight')) return;

    double goalWeight = double.parse(_goalWeightController.text);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({'goalWeight': goalWeight}, SetOptions(merge: true));
      if (mounted) {
        setState(() => _goalWeight = goalWeight);
        _showSnackBar('Goal weight set successfully!');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Failed to set goal weight: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _addWeightEntry() async {
    if (!_validateInput(_weightController.text, 'weight')) return;

    double weight = double.parse(_weightController.text);
    try {
      final entry = WeightEntry(
        weight: weight,
        date: _selectedDate.toUtc(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        id: '',
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('weight_entries')
          .add(entry.toMap());
      if (mounted) {
        _weightController.clear();
        _notesController.clear();
        setState(() => _selectedDate = DateTime.now());
        _showSnackBar('Weight added successfully!');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Failed to add weight: $e');
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
      if (mounted) _showSnackBar('Weight entry deleted successfully!');
    } catch (e) {
      if (mounted) _showSnackBar('Failed to delete entry: $e');
    }
  }

  bool _validateInput(String text, String fieldName) {
    if (text.isEmpty) {
      _showSnackBar('Please enter your $fieldName');
      return false;
    }
    double? value = double.tryParse(text);
    if (value == null || value <= 0) {
      _showSnackBar('$fieldName must be a positive number');
      return false;
    }
    return true;
  }

  String _calculateBMI(double weight) {
    if (_height == null || _height! <= 0) return 'Height not set';
    final bmi = weight / (_height! * _height!);
    String category;
    if (bmi < 18.5) {
      category = 'Underweight';
    } else if (bmi < 25) {
      category = 'Normal';
    } else if (bmi < 30) {
      category = 'Overweight';
    } else {
      category = 'Obese';
    }
    return 'BMI: ${bmi.toStringAsFixed(1)} ($category)';
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Progress Tracker',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.normal)),
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: const Center(
          child: Text('Please sign in to use this feature.',
              style: TextStyle(color: Colors.black, fontSize: 16)),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracker',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Set Your Height'),
                const SizedBox(height: 8),
                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  decoration: _inputDecoration('Enter your height (m)'),
                ),
                const SizedBox(height: 16),
                _buildButton('Set Height', _setHeight),
                const SizedBox(height: 24),
                _buildSectionTitle('Set Your Goal Weight'),
                const SizedBox(height: 8),
                TextField(
                  controller: _goalWeightController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  decoration: _inputDecoration('Set your goal weight (kg)'),
                ),
                const SizedBox(height: 16),
                _buildButton('Set Goal Weight', _setGoalWeight),
                const SizedBox(height: 24),
                _buildSectionTitle('Add a Weight Entry'),
                const SizedBox(height: 8),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  decoration: _inputDecoration('Enter your weight (kg)'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    _buildButton('Select Date', () => _selectDate(context)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  style: const TextStyle(color: Colors.black),
                  decoration: _inputDecoration('Add a note (optional)'),
                ),
                const SizedBox(height: 16),
                _buildButton('Add Weight', _addWeightEntry),
                const SizedBox(height: 24),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .collection('weight_entries')
                      .orderBy('date', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.black)));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.black));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text(
                              'No weight entries yet. Add one to start!',
                              style: TextStyle(color: Colors.black)));
                    }

                    final allEntries = snapshot.data!.docs.map((doc) {
                      try {
                        return WeightEntry.fromMap(
                            doc.data() as Map<String, dynamic>, doc.id);
                      } catch (e) {
                        return WeightEntry(
                          weight: 0.0,
                          date: DateTime.now(),
                          notes: 'Error parsing: $e',
                          id: doc.id,
                        );
                      }
                    }).toList();

                    final initialWeight = allEntries.first.weight;
                    final currentWeight = allEntries.last.weight;
                    final weightChange = currentWeight - initialWeight;
                    final progressText = weightChange >= 0
                        ? '+${weightChange.toStringAsFixed(1)} kg (Gain)'
                        : '${weightChange.toStringAsFixed(1)} kg (Loss)';
                    String goalProgressText = '';
                    if (_goalWeight != null) {
                      final goalDifference = currentWeight - _goalWeight!;
                      goalProgressText = goalDifference >= 0
                          ? '${goalDifference.toStringAsFixed(1)} kg above goal'
                          : '${(-goalDifference).toStringAsFixed(1)} kg to goal';
                    }
                    final bmiText = _calculateBMI(currentWeight);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Progress Summary'),
                        const SizedBox(height: 8),
                        Text('Progress: $progressText',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 14)),
                        if (_goalWeight != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('Goal Progress: $goalProgressText',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14)),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(bmiText,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 14)),
                        ),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Weight Over Time'),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: LineChart(_buildLineChartData(allEntries)),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Weight History'),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: allEntries.length,
                            itemBuilder: (context, index) {
                              final entry =
                                  allEntries[allEntries.length - 1 - index];
                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                color: Colors.grey[800],
                                child: ListTile(
                                  title: Text(
                                      '${entry.weight.toStringAsFixed(1)} kg',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.date.toString(),
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12)),
                                      if (entry.notes != null)
                                        Text('Note: ${entry.notes}',
                                            style: const TextStyle(
                                                color: Colors.white70)),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      bool confirm = await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: const Text(
                                                  'Confirm Delete',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              content: const Text(
                                                  'Are you sure you want to delete this entry?',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('Cancel',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.black)),
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
      ),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      border:
          const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      enabledBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      focusedBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
    );
  }

  // Button builder helper
  Widget _buildButton(String text, VoidCallback onPressed) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Line chart data
  LineChartData _buildLineChartData(List<WeightEntry> entries) {
    final spots = entries.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final weight = entry.value.weight;
      return FlSpot(index, weight);
    }).toList();

    final weights = entries.map((e) => e.weight).toList();
    final minWeight = weights.isNotEmpty
        ? (weights.reduce((a, b) => a < b ? a : b) - 5).floorToDouble()
        : 0.0;
    final maxWeight = weights.isNotEmpty
        ? (weights.reduce((a, b) => a > b ? a : b) + 5).ceilToDouble()
        : 100.0;
    final minX = 0.0;
    final maxX = entries.length > 1 ? (entries.length - 1).toDouble() : 1.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Colors.grey,
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
      ),
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: minX,
      maxX: maxX,
      minY: minWeight,
      maxY: maxWeight,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 4,
              color: Colors.blue,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _goalWeightController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
