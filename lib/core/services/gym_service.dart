import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/member_model.dart';
import '../models/trainer_model.dart';
import '../models/class_model.dart';
import '../models/payment_model.dart';
import '../models/attendance_model.dart';
import '../models/announcement_model.dart';
import 'dart:developer';

class GymService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Members
  Future<String> addMember(MemberModel member, String password) async {
    try {
      log('Starting addMember()...');
      
      // First create the Firebase Auth user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: member.email!,
        password: password
      );
      log('Created Firebase Auth user: ${userCredential.user?.uid}');

      // Convert MemberModel to user data
      final userData = {
        'id': userCredential.user!.uid, // Use the Firebase Auth UID
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
      
      // Add user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);
      log('Created new user document with ID: ${userCredential.user!.uid}');
      
      log('Successfully added member: ${member.name} (ID: ${userCredential.user!.uid})');
      return 'Success';
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code} - ${e.message}');
      String errorMessage = "An error occurred during member registration.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered.";
      } else if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid.";
      }
      return errorMessage;
    } catch (e, stackTrace) {
      log('Error adding member: $e', error: e, stackTrace: stackTrace);
      if (e is FirebaseException) {
        log('Firebase error code: ${e.code}, message: ${e.message}');
      }
      return 'Failed to add member: ${e.toString()}';
    }
  }

  // Add a method to handle member login
  Future<String> loginMember(String email, String password) async {
    try {
      log('Attempting to login member with email: $email');
      
      // Sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      
      // Get user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      
      if (!userDoc.exists) {
        return 'User data not found';
      }
      
      log('Successfully logged in member: ${userDoc.get('name')}');
      return 'Success';
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code} - ${e.message}');
      String errorMessage = "Login failed.";
      if (e.code == 'user-not-found') {
        errorMessage = "No member found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid.";
      }
      return errorMessage;
    } catch (e) {
      log('Error during login: $e');
      return 'Login failed: ${e.toString()}';
    }
  }

  // Add a method to reset password
  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'Password reset email sent';
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code} - ${e.message}');
      String errorMessage = "Failed to send password reset email.";
      if (e.code == 'user-not-found') {
        errorMessage = "No member found with this email.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid.";
      }
      return errorMessage;
    } catch (e) {
      log('Error sending password reset: $e');
      return 'Failed to send password reset email: ${e.toString()}';
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

  /// Save daily attendance for all members
  Future<void> saveDailyAttendance(String date, Map<String, bool> attendanceMap) async {
    try {
      await _firestore.collection('attendance').doc(date).set({
        'date': date,
        'records': attendanceMap,
      });
    } catch (e, stackTrace) {
      log('Error saving daily attendance: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save monthly payments for all members
  Future<void> saveMonthlyPayments(String month, Map<String, bool> paymentMap) async {
    try {
      await _firestore.collection('payments').doc(month).set({
        'month': month,
        'records': paymentMap,
      });
    } catch (e, stackTrace) {
      log('Error saving monthly payments: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Fetch monthly payments for all members
  Future<Map<String, bool>> fetchMonthlyPayments(String month) async {
    try {
      final doc = await _firestore.collection('payments').doc(month).get();
      if (!doc.exists) return {};
      final data = doc.data();
      if (data == null || data['records'] == null) return {};
      final Map<String, dynamic> records = Map<String, dynamic>.from(data['records']);
      return records.map((key, value) => MapEntry(key, value as bool));
    } catch (e, stackTrace) {
      log('Error fetching monthly payments: $e', error: e, stackTrace: stackTrace);
      return {};
    }
  }
} 