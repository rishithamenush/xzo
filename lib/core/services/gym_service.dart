import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';
import '../models/trainer_model.dart';
import '../models/class_model.dart';
import '../models/payment_model.dart';
import '../models/attendance_model.dart';
import '../models/announcement_model.dart';

class GymService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Members
  Future<void> addMember(MemberModel member) async {
    final doc = await _firestore.collection('members').add(member.toJson());
    await doc.update({'id': doc.id});
  }

  Future<List<MemberModel>> getMembers() async {
    final snapshot = await _firestore.collection('members').get();
    return snapshot.docs.map((doc) => MemberModel.fromJson(doc.data())).toList();
  }

  Future<void> updateMember(MemberModel member) async {
    await _firestore.collection('members').doc(member.id).update(member.toJson());
  }

  Future<void> deleteMember(String id) async {
    await _firestore.collection('members').doc(id).delete();
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