import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final double pricePerDay;
  final int seats;
  final String? description;
  final bool isActive;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.pricePerDay,
    required this.seats,
    this.description,
    this.isActive = true,
  });

  factory Car.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Car(
      id: doc.id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      pricePerDay: (data['pricePerDay'] ?? 0.0).toDouble(),
      seats: (data['seats'] ?? 0),
      description: data['description'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'pricePerDay': pricePerDay,
      'seats': seats,
      'description': description,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
} 