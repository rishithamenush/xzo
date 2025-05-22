import 'package:cloud_firestore/cloud_firestore.dart';

class Guide {
  final String id;
  final String name;
  final String photoUrl;
  final String mobile;
  final String city;
  final String? email;
  final String? description;
  final double? rating;
  final List<String>? languages;
  final List<String>? specialties;
  final bool isActive;

  Guide({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.mobile,
    required this.city,
    this.email,
    this.description,
    this.rating,
    this.languages,
    this.specialties,
    this.isActive = true,
  });

  factory Guide.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Guide(
      id: doc.id,
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      mobile: data['mobile'] ?? '',
      city: data['city'] ?? '',
      email: data['email'],
      description: data['description'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      languages: List<String>.from(data['languages'] ?? []),
      specialties: List<String>.from(data['specialties'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'mobile': mobile,
      'city': city,
      'email': email,
      'description': description,
      'rating': rating,
      'languages': languages,
      'specialties': specialties,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Guide copyWith({
    String? name,
    String? photoUrl,
    String? mobile,
    String? city,
    String? email,
    String? description,
    double? rating,
    List<String>? languages,
    List<String>? specialties,
    bool? isActive,
  }) {
    return Guide(
      id: id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      mobile: mobile ?? this.mobile,
      city: city ?? this.city,
      email: email ?? this.email,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      languages: languages ?? this.languages,
      specialties: specialties ?? this.specialties,
      isActive: isActive ?? this.isActive,
    );
  }
} 