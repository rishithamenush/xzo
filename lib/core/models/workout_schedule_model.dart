import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutScheduleModel {
  String? id;
  String memberId;
  String workoutType;
  String trainerId;
  DateTime startTime;
  DateTime endTime;
  List<String> daysOfWeek;
  String? notes;
  bool isActive;

  WorkoutScheduleModel({
    this.id,
    required this.memberId,
    required this.workoutType,
    required this.trainerId,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    this.notes,
    this.isActive = true,
  });

  factory WorkoutScheduleModel.fromJson(Map<String, dynamic> json) {
    return WorkoutScheduleModel(
      id: json['id'],
      memberId: json['memberId'],
      workoutType: json['workoutType'],
      trainerId: json['trainerId'],
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      daysOfWeek: List<String>.from(json['daysOfWeek']),
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'workoutType': workoutType,
      'trainerId': trainerId,
      'startTime': startTime,
      'endTime': endTime,
      'daysOfWeek': daysOfWeek,
      'notes': notes,
      'isActive': isActive,
    };
  }
}

void printCurrentUserUID() {
  print("Current user UID: ${FirebaseAuth.instance.currentUser?.uid}");
} 