// lib/models/weight_entry.dart
class WeightEntry {
  final double weight;
  final DateTime date;
  final String id;

  WeightEntry({
    required this.weight,
    required this.date,
    this.id = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'date': date.toIso8601String(),
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map, String id) {
    return WeightEntry(
      weight: map['weight']?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date']),
      id: id,
    );
  }
}
