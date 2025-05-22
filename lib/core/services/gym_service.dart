import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';
import '../models/trainer_model.dart';
import '../models/class_model.dart';
import '../models/payment_model.dart';
import '../models/attendance_model.dart';
import '../models/announcement_model.dart';
import 'dart:developer';

class GymService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Members
  Future<void> addMember(MemberModel member) async {
    try {
      log('Starting addMember()...');
      
      // Convert MemberModel to user data
      final userData = {
        'id': member.id,
        'name': member.name,
        'email': member.email,
        'phone': member.phone,
        'membershipType': member.membershipType,
        'registrationNumber': member.registrationNumber,
        'joinDate': member.joinDate != null ? Timestamp.fromDate(member.joinDate!) : null,
        'expiryDate': member.expiryDate != null ? Timestamp.fromDate(member.expiryDate!) : null,
        'role': 'user', // Default role
        'longitude': 0.0, // Default values
        'latitude': 0.0,  // Default values
        'favList': [],    // Default empty list
      };
      
      log('User data to add: $userData');
      
      final doc = await _firestore.collection('users').add(userData);
      log('Created new user document with ID: ${doc.id}');
      
      await doc.update({'id': doc.id});
      log('Updated document with ID field');
      
      log('Successfully added member: ${member.name} (ID: ${doc.id})');
    } catch (e, stackTrace) {
      log('Error adding member: $e', error: e, stackTrace: stackTrace);
      if (e is FirebaseException) {
        log('Firebase error code: ${e.code}, message: ${e.message}');
      }
      rethrow;
    }
  }

  Future<List<MemberModel>> getMembers() async {
    try {
      log('Starting getMembers()...');
      
      log('Fetching users from Firestore collection: users');
      final snapshot = await _firestore.collection('users').get();
      log('Retrieved ${snapshot.docs.length} user documents from Firestore');
      
      if (snapshot.docs.isEmpty) {
        log('WARNING: No user documents found in Firestore collection: users');
        return [];
      }

      // Log raw data from each document
      for (var doc in snapshot.docs) {
        log('Document ID: ${doc.id}');
        log('Raw document data: ${doc.data().toString()}');
        log('Document exists: ${doc.exists}');
        log('Document metadata: ${doc.metadata.toString()}');
      }
      
      final members = snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          if (data.isEmpty) {
            log('WARNING: Empty document data for document ID: ${doc.id}');
            return null;
          }
          
          // Convert user data to member data
          final memberData = {
            'id': doc.id,
            'name': data['name'],
            'email': data['email'],
            'phone': data['phone'],
            'membershipType': data['membershipType'],
            'registrationNumber': data['registrationNumber'],
            'status': 'active', // Default status
            'joinDate': data['joinDate'],
            'expiryDate': data['expiryDate'],
          };
          
          log('Converting user document ${doc.id} to MemberModel with data: ${memberData.toString()}');
          
          final member = MemberModel.fromJson(memberData);
          log('Successfully converted member: ${member.name} (ID: ${member.id})');
          log('Member details - Status: ${member.status}, Join Date: ${member.joinDate}, Expiry Date: ${member.expiryDate}');
          return member;
        } catch (e, stackTrace) {
          log('ERROR converting document ${doc.id} to MemberModel: $e', error: e, stackTrace: stackTrace);
          log('Problematic document data: ${doc.data().toString()}');
          return null;
        }
      })
      .where((member) => member != null) // Filter out any failed conversions
      .cast<MemberModel>() // Cast back to MemberModel
      .toList();
      
      log('Successfully converted ${members.length} members out of ${snapshot.docs.length} documents');
      
      // Log final member list
      for (var member in members) {
        log('Final member list - Name: ${member.name}, ID: ${member.id}, Status: ${member.status}, Join Date: ${member.joinDate}, Expiry Date: ${member.expiryDate}');
      }
      
      return members;
    } catch (e, stackTrace) {
      log('ERROR in getMembers(): $e', error: e, stackTrace: stackTrace);
      if (e is FirebaseException) {
        log('Firebase error code: ${e.code}, message: ${e.message}');
      }
      rethrow;
    }
  }

  Future<void> updateMember(MemberModel member) async {
    try {
      log('Starting updateMember()...');
      
      // Convert MemberModel to user data
      final userData = {
        'name': member.name,
        'email': member.email,
        'phone': member.phone,
        'membershipType': member.membershipType,
        'registrationNumber': member.registrationNumber,
        'joinDate': member.joinDate != null ? Timestamp.fromDate(member.joinDate!) : null,
        'expiryDate': member.expiryDate != null ? Timestamp.fromDate(member.expiryDate!) : null,
      };
      
      log('Updating user with ID: ${member.id}');
      log('User data to update: $userData');
      
      await _firestore.collection('users').doc(member.id).update(userData);
      log('Successfully updated member: ${member.name} (ID: ${member.id})');
    } catch (e, stackTrace) {
      log('Error updating member: $e', error: e, stackTrace: stackTrace);
      if (e is FirebaseException) {
        log('Firebase error code: ${e.code}, message: ${e.message}');
      }
      rethrow;
    }
  }

  Future<void> deleteMember(String id) async {
    await _firestore.collection('users').doc(id).delete();
  }

  // Trainers
  Future<void> addTrainer(TrainerModel trainer) async {
    final doc = await _firestore.collection('trainers').add(trainer.toJson());
    await doc.update({'id': doc.id});
  }

  Future<List<TrainerModel>> getTrainers() async {
    final snapshot = await _firestore.collection('trainers').get();
    return snapshot.docs.map((doc) => TrainerModel.fromJson(doc.data())).toList();
  }

  Future<void> updateTrainer(TrainerModel trainer) async {
    await _firestore.collection('trainers').doc(trainer.id).update(trainer.toJson());
  }

  Future<void> deleteTrainer(String id) async {
    await _firestore.collection('trainers').doc(id).delete();
  }

  // Classes
  Future<void> addClass(GymClassModel gymClass) async {
    final doc = await _firestore.collection('classes').add(gymClass.toJson());
    await doc.update({'id': doc.id});
  }

  Future<List<GymClassModel>> getClasses() async {
    final snapshot = await _firestore.collection('classes').get();
    return snapshot.docs.map((doc) => GymClassModel.fromJson(doc.data())).toList();
  }

  Future<void> updateClass(GymClassModel gymClass) async {
    await _firestore.collection('classes').doc(gymClass.id).update(gymClass.toJson());
  }

  Future<void> deleteClass(String id) async {
    await _firestore.collection('classes').doc(id).delete();
  }

  // Payments
  Future<void> addPayment(PaymentModel payment) async {
    final doc = await _firestore.collection('payments').add(payment.toJson());
    await doc.update({'id': doc.id});
  }

  Future<List<PaymentModel>> getPayments() async {
    final snapshot = await _firestore.collection('payments').get();
    return snapshot.docs.map((doc) => PaymentModel.fromJson(doc.data())).toList();
  }

  Future<void> updatePayment(PaymentModel payment) async {
    await _firestore.collection('payments').doc(payment.id).update(payment.toJson());
  }

  Future<void> deletePayment(String id) async {
    await _firestore.collection('payments').doc(id).delete();
  }

  // Attendance
  Future<void> addAttendance(AttendanceModel attendance) async {
    final doc = await _firestore.collection('attendance').add(attendance.toJson());
    await doc.update({'id': doc.id});
  }

  Future<List<AttendanceModel>> getAttendance() async {
    final snapshot = await _firestore.collection('attendance').get();
    return snapshot.docs.map((doc) => AttendanceModel.fromJson(doc.data())).toList();
  }

  Future<void> updateAttendance(AttendanceModel attendance) async {
    await _firestore.collection('attendance').doc(attendance.id).update(attendance.toJson());
  }

  Future<void> deleteAttendance(String id) async {
    await _firestore.collection('attendance').doc(id).delete();
  }

  // Announcements
  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    final doc = await _firestore.collection('announcements').add(announcement.toJson());
    await doc.update({'id': doc.id});
  }

  Future<List<AnnouncementModel>> getAnnouncements() async {
    final snapshot = await _firestore.collection('announcements').get();
    return snapshot.docs.map((doc) => AnnouncementModel.fromJson(doc.data())).toList();
  }

  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    await _firestore.collection('announcements').doc(announcement.id).update(announcement.toJson());
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('announcements').doc(id).delete();
  }
} 