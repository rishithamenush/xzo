import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutProgressModel {
  final String? id;
  final DateTime date;
  final String status; // e.g., 'started', 'completed'
  final String? notes;

  WorkoutProgressModel({
    this.id,
    required this.date,
    required this.status,
    this.notes,
  });

  factory WorkoutProgressModel.fromJson(Map<String, dynamic> json) {
    return WorkoutProgressModel(
      id: json['id'],
      date: (json['date'] as Timestamp).toDate(),
      status: json['status'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': Timestamp.fromDate(date),
      'status': status,
      'notes': notes,
    };
  }
} 