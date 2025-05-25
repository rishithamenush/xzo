import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/member_model.dart';
import '../models/trainer_model.dart';
import '../models/class_model.dart';
import '../models/attendance_model.dart';
import '../models/workout_schedule_model.dart';
import '../models/workout_progress_model.dart';
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

      // Set the member's id to the Firebase Auth UID
      final String firebaseUid = userCredential.user!.uid;
      member.id = firebaseUid;

      // Convert MemberModel to user data
      final userData = {
        'id': firebaseUid, // Use the Firebase Auth UID
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
      
      // Add user data to Firestore with UID as document ID
      await _firestore.collection('users').doc(firebaseUid).set(userData);
      log('Created new user document with ID: $firebaseUid');
      
      log('Successfully added member: ${member.name} (ID: $firebaseUid)');
      return firebaseUid;
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

      List<MemberModel> members = [];
      
      // Process each document
      for (var doc in snapshot.docs) {
        try {
          log('Processing document ID: ${doc.id}');
          final data = doc.data();
          
          // Ensure the document has an ID field
          if (!data.containsKey('id')) {
            log('WARNING: Document ${doc.id} missing id field, using document ID instead');
            data['id'] = doc.id;
          }
          
          // Log the data before conversion
          log('Document data before conversion: $data');
          
          final member = MemberModel.fromJson(data);
          
          // Verify the member ID is set
          if (member.id == null || member.id!.isEmpty) {
            log('WARNING: Member ${member.name} has no ID, using document ID: ${doc.id}');
            member.id = doc.id;
          }
          
          log('Successfully created member model: ${member.name} with ID: ${member.id}');
          members.add(member);
        } catch (e, stackTrace) {
          log('Error processing document ${doc.id}: $e', error: e, stackTrace: stackTrace);
          // Continue processing other documents
        }
      }
      
      log('Successfully processed ${members.length} members');
      return members;
    } catch (e, stackTrace) {
      log('Error in getMembers(): $e', error: e, stackTrace: stackTrace);
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

  /// Fetch daily attendance for all members
  Future<Map<String, bool>> fetchDailyAttendance(String date) async {
    try {
      final doc = await _firestore.collection('attendance').doc(date).get();
      if (!doc.exists) return {};
      final data = doc.data();
      if (data == null || data['records'] == null) return {};
      final Map<String, dynamic> records = Map<String, dynamic>.from(data['records']);
      return records.map((key, value) => MapEntry(key, value as bool));
    } catch (e, stackTrace) {
      log('Error fetching daily attendance: $e', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  // Workout Schedules
  Future<void> addWorkoutSchedule(WorkoutScheduleModel schedule) async {
    try {
      log('Adding workout schedule for member: ${schedule.memberId}');
      // Find member document by querying the id field
      final memberQuery = await _firestore
          .collection('users')
          .where('id', isEqualTo: schedule.memberId)
          .get();
      if (memberQuery.docs.isEmpty) {
        throw Exception('Member with ID ${schedule.memberId} does not exist');
      }
      final memberDoc = memberQuery.docs.first;
      // Add schedule to the member's workout_schedules subcollection
      final doc = await _firestore
          .collection('users')
          .doc(memberDoc.id)
          .collection('workout_schedules')
          .add(schedule.toJson());
      // Update the document with its ID
      await doc.update({'id': doc.id});
      log('Successfully added workout schedule:');
      log('  ID: ${doc.id}');
      log('  Member ID: ${schedule.memberId}');
      log('  Workout Type: ${schedule.workoutType}');
    } catch (e, stackTrace) {
      log('Error adding workout schedule: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<WorkoutScheduleModel>> getMemberWorkoutSchedules(String memberId) async {
    try {
      log('=== Getting Workout Schedules ===');
      log('Member ID to query: $memberId');
      
      // Find member document by querying the id field
      final memberQuery = await _firestore
          .collection('users')
          .where('id', isEqualTo: memberId)
          .get();
      
      if (memberQuery.docs.isEmpty) {
        log('WARNING: Member with ID $memberId not found');
        return [];
      }
      
      final memberDoc = memberQuery.docs.first;
      log('Found member document:');
      log('  Document ID: ${memberDoc.id}');
      log('  Member Data: ${memberDoc.data()}');
      
      // Get all schedules from the member's workout_schedules subcollection
      log('Querying workout_schedules subcollection...');
      final snapshot = await _firestore
          .collection('users')
          .doc(memberDoc.id)  // Use the document ID here
          .collection('workout_schedules')
          .get();
      
      log('Query returned ${snapshot.docs.length} documents');
      
      // Process and return the schedules
      return _processScheduleDocuments(snapshot.docs);
    } catch (e, stackTrace) {
      log('Error getting member workout schedules: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateWorkoutSchedule(WorkoutScheduleModel schedule) async {
    try {
      log('Updating workout schedule: ${schedule.id}');
      // Find member document by querying the id field
      final memberQuery = await _firestore
          .collection('users')
          .where('id', isEqualTo: schedule.memberId)
          .get();
      if (memberQuery.docs.isEmpty) {
        throw Exception('Member with ID ${schedule.memberId} does not exist');
      }
      final memberDoc = memberQuery.docs.first;
      // Verify schedule exists
      final scheduleDoc = await _firestore
          .collection('users')
          .doc(memberDoc.id)
          .collection('workout_schedules')
          .doc(schedule.id)
          .get();
      if (!scheduleDoc.exists) {
        throw Exception('Schedule with ID ${schedule.id} does not exist');
      }
      // Update schedule
      await _firestore
          .collection('users')
          .doc(memberDoc.id)
          .collection('workout_schedules')
          .doc(schedule.id)
          .update(schedule.toJson());
      log('Successfully updated workout schedule:');
      log('  ID: ${schedule.id}');
      log('  Member ID: ${schedule.memberId}');
      log('  Workout Type: ${schedule.workoutType}');
    } catch (e, stackTrace) {
      log('Error updating workout schedule: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteWorkoutSchedule(String memberId, String scheduleId) async {
    try {
      log('Deleting workout schedule: $scheduleId for member: $memberId');
      // Find member document by querying the id field
      final memberQuery = await _firestore
          .collection('users')
          .where('id', isEqualTo: memberId)
          .get();
      if (memberQuery.docs.isEmpty) {
        throw Exception('Member with ID $memberId does not exist');
      }
      final memberDoc = memberQuery.docs.first;
      // Verify schedule exists
      final scheduleDoc = await _firestore
          .collection('users')
          .doc(memberDoc.id)
          .collection('workout_schedules')
          .doc(scheduleId)
          .get();
      if (!scheduleDoc.exists) {
        throw Exception('Schedule with ID $scheduleId does not exist');
      }
      // Delete schedule
      await _firestore
          .collection('users')
          .doc(memberDoc.id)
          .collection('workout_schedules')
          .doc(scheduleId)
          .delete();
      log('Successfully deleted workout schedule: $scheduleId');
    } catch (e, stackTrace) {
      log('Error deleting workout schedule: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deactivateWorkoutSchedule(String memberId, String scheduleId) async {
    try {
      log('Deactivating workout schedule: $scheduleId for member: $memberId');
      // Find member document by querying the id field
      final memberQuery = await _firestore
          .collection('users')
          .where('id', isEqualTo: memberId)
          .get();
      if (memberQuery.docs.isEmpty) {
        throw Exception('Member with ID $memberId does not exist');
      }
      final memberDoc = memberQuery.docs.first;
      // Verify schedule exists
      final scheduleDoc = await _firestore
          .collection('users')
          .doc(memberDoc.id)
          .collection('workout_schedules')
          .doc(scheduleId)
          .get();
      if (!scheduleDoc.exists) {
        throw Exception('Schedule with ID $scheduleId does not exist');
      }
      // Deactivate schedule
      await _firestore
          .collection('users')
          .doc(memberDoc.id)
          .collection('workout_schedules')
          .doc(scheduleId)
          .update({'isActive': false});
      log('Successfully deactivated workout schedule: $scheduleId');
    } catch (e, stackTrace) {
      log('Error deactivating workout schedule: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Helper method to process schedule documents
  List<WorkoutScheduleModel> _processScheduleDocuments(List<QueryDocumentSnapshot> docs) {
    // Log raw document data
    for (var doc in docs) {
      log('Raw Schedule Document:');
      log('  Document ID: ${doc.id}');
      log('  Data: ${doc.data()}');
    }
    
    // Convert to models and log details
    final schedules = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Ensure ID is set
      log('Converting document to model:');
      log('  Document ID: ${doc.id}');
      log('  Raw Data: $data');
      
      try {
        final schedule = WorkoutScheduleModel.fromJson(data);
        log('Successfully converted to model:');
        log('  ID: ${schedule.id}');
        log('  Member ID: ${schedule.memberId}');
        log('  Workout Type: ${schedule.workoutType}');
        log('  Trainer ID: ${schedule.trainerId}');
        log('  Start Time: ${schedule.startTime}');
        log('  End Time: ${schedule.endTime}');
        log('  Days: ${schedule.daysOfWeek}');
        log('  Is Active: ${schedule.isActive}');
        return schedule;
      } catch (e, stackTrace) {
        log('Error converting document to model: $e', error: e, stackTrace: stackTrace);
        rethrow;
      }
    }).toList();
    
    log('Successfully converted ${schedules.length} schedules to models');
    return schedules;
  }

  Future<void> updateWorkoutScheduleMemberId(String scheduleId, String newMemberId) async {
    try {
      log('Updating workout schedule memberId: $scheduleId to $newMemberId');
      
      // Verify schedule exists
      final scheduleDoc = await _firestore.collection('workout_schedules').doc(scheduleId).get();
      if (!scheduleDoc.exists) {
        throw Exception('Schedule with ID $scheduleId does not exist');
      }
      
      // Verify new member exists by querying for their ID field
      final memberQuery = await _firestore
          .collection('users')
          .where('id', isEqualTo: newMemberId)
          .get();
      
      if (memberQuery.docs.isEmpty) {
        throw Exception('Member with ID $newMemberId does not exist');
      }
      
      // Update memberId
      await _firestore.collection('workout_schedules').doc(scheduleId).update({
        'memberId': newMemberId
      });
      
      log('Successfully updated workout schedule memberId: $scheduleId to $newMemberId');
    } catch (e, stackTrace) {
      log('Error updating workout schedule memberId: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Workout Progress
  Future<void> addWorkoutProgress(String memberId, String scheduleId, WorkoutProgressModel progress) async {
    // Find member document by id field
    final memberQuery = await _firestore.collection('users').where('id', isEqualTo: memberId).get();
    if (memberQuery.docs.isEmpty) throw Exception('Member with ID $memberId does not exist');
    final memberDoc = memberQuery.docs.first;
    // Add progress to subcollection
    final doc = await _firestore
      .collection('users')
      .doc(memberDoc.id)
      .collection('workout_schedules')
      .doc(scheduleId)
      .collection('progress')
      .add(progress.toJson());
    await doc.update({'id': doc.id});
  }

  Future<List<WorkoutProgressModel>> getWorkoutProgressList(String memberId, String scheduleId) async {
    final memberQuery = await _firestore.collection('users').where('id', isEqualTo: memberId).get();
    if (memberQuery.docs.isEmpty) throw Exception('Member with ID $memberId does not exist');
    final memberDoc = memberQuery.docs.first;
    final snapshot = await _firestore
      .collection('users')
      .doc(memberDoc.id)
      .collection('workout_schedules')
      .doc(scheduleId)
      .collection('progress')
      .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return WorkoutProgressModel.fromJson(data);
    }).toList();
  }

  Future<void> updateWorkoutProgress(String memberId, String scheduleId, WorkoutProgressModel progress) async {
    final memberQuery = await _firestore.collection('users').where('id', isEqualTo: memberId).get();
    if (memberQuery.docs.isEmpty) throw Exception('Member with ID $memberId does not exist');
    final memberDoc = memberQuery.docs.first;
    await _firestore
      .collection('users')
      .doc(memberDoc.id)
      .collection('workout_schedules')
      .doc(scheduleId)
      .collection('progress')
      .doc(progress.id)
      .update(progress.toJson());
  }

  Future<void> deleteWorkoutProgress(String memberId, String scheduleId, String progressId) async {
    final memberQuery = await _firestore.collection('users').where('id', isEqualTo: memberId).get();
    if (memberQuery.docs.isEmpty) throw Exception('Member with ID $memberId does not exist');
    final memberDoc = memberQuery.docs.first;
    await _firestore
      .collection('users')
      .doc(memberDoc.id)
      .collection('workout_schedules')
      .doc(scheduleId)
      .collection('progress')
      .doc(progressId)
      .delete();
  }

  // Points logic
  Future<void> incrementUserPoints(String userId, int points) async {
    final userQuery = await _firestore.collection('users').where('id', isEqualTo: userId).get();
    if (userQuery.docs.isEmpty) throw Exception('User with ID $userId not found');
    final userDoc = userQuery.docs.first;
    final docRef = _firestore.collection('users').doc(userDoc.id);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final currentPoints = (snapshot.data()?['points'] ?? 0) as int;
      transaction.update(docRef, {'points': currentPoints + points});
    });
  }

  Future<int> getUserPoints(String userId) async {
    final userQuery = await _firestore.collection('users').where('id', isEqualTo: userId).get();
    if (userQuery.docs.isEmpty) return 0;
    final userDoc = userQuery.docs.first;
    final data = userDoc.data();
    return (data['points'] ?? 0) as int;
  }

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final usersSnapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> leaderboard = [];
    for (final userDoc in usersSnapshot.docs) {
      final userId = userDoc['id'];
      final name = userDoc['name'] ?? '';
      int weeklyPoints = 0;
      final schedulesSnapshot = await _firestore.collection('users').doc(userDoc.id).collection('workout_schedules').get();
      for (final scheduleDoc in schedulesSnapshot.docs) {
        final progressSnapshot = await _firestore.collection('users').doc(userDoc.id).collection('workout_schedules').doc(scheduleDoc.id).collection('progress').get();
        for (final progressDoc in progressSnapshot.docs) {
          final data = progressDoc.data();
          if (data['status'] == 'completed') {
            final date = (data['date'] as Timestamp).toDate();
            if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && date.isBefore(now.add(const Duration(days: 1)))) {
              weeklyPoints += 10; // 10 points per completion
            }
          }
        }
      }
      leaderboard.add({'userId': userId, 'name': name, 'points': weeklyPoints});
    }
    leaderboard.sort((a, b) => b['points'].compareTo(a['points']));
    return leaderboard;
  }
} 