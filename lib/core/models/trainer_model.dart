import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerModel {
  String? id;
  String name;
  String email;
  String phone;
  String specialty;

  TrainerModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
  });

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    return TrainerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      specialty: json['specialty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialty': specialty,
    };
  }
} 