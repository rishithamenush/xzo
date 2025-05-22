import 'package:cloud_firestore/cloud_firestore.dart';

class GymClassModel {
  String? id;
  String name;
  String trainerId;
  DateTime startTime;
  DateTime endTime;
  List<String> daysOfWeek;

  GymClassModel({
    this.id,
    required this.name,
    required this.trainerId,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
  });

  factory GymClassModel.fromJson(Map<String, dynamic> json) {
    return GymClassModel(
      id: json['id'],
      name: json['name'],
      trainerId: json['trainerId'],
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      daysOfWeek: List<String>.from(json['daysOfWeek']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trainerId': trainerId,
      'startTime': startTime,
      'endTime': endTime,
      'daysOfWeek': daysOfWeek,
    };
  }
} 