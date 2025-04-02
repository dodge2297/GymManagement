import 'package:cloud_firestore/cloud_firestore.dart';

class WeightEntry {
  final double weight;
  final DateTime date;
  final String? notes;
  final String id;

  WeightEntry({
    required this.weight,
    required this.date,
    this.notes,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'date': Timestamp.fromDate(date),
      'notes': notes,
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map, String id) {
    DateTime date;
    if (map['date'] is Timestamp) {
      date = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      date = DateTime.parse(map['date'] as String);
    } else {
      date = DateTime.now();
    }

    return WeightEntry(
      weight: map['weight']?.toDouble() ?? 0.0,
      date: date,
      notes: map['notes'] as String?,
      id: id,
    );
  }
}
