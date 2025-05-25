import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turathi/core/services/gym_service.dart';
import 'package:turathi/core/models/workout_schedule_model.dart';
import 'package:turathi/core/models/trainer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class ScheduleScreen extends StatefulWidget {
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final GymService _gymService = GymService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<WorkoutScheduleModel> _workoutSchedules = [];
  List<TrainerModel> _trainers = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  bool _isWeeklyView = false;

  @override
  void initState() {
    super.initState();
    print("Current user UID: \\${_auth.currentUser?.uid}");
    _updateScheduleMemberId();
    _loadData();
  }

  Future<void> _updateScheduleMemberId() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Get all schedules
      final snapshot = await FirebaseFirestore.instance.collection('workout_schedules').get();
      final schedules = snapshot.docs.map((doc) => WorkoutScheduleModel.fromJson(doc.data())).toList();

      // Find schedules with non-Firebase Auth UIDs (they are typically 28 characters long)
      for (var schedule in schedules) {
        if (schedule.memberId.length != 28) {  // Firebase Auth UIDs are 28 characters
          print("Updating schedule ${schedule.id} from memberId ${schedule.memberId} to $userId");
          await _gymService.updateWorkoutScheduleMemberId(schedule.id!, userId);
          print("Successfully updated schedule memberId");
        }
      }

      // Reload schedules after updating
      await _loadData();
    } catch (e) {
      print("Error updating schedule memberId: $e");
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _auth.currentUser?.uid;
      print("=== User Authentication Info ===");
      print("Current logged in user ID: $userId");
      print("Current user email: ${_auth.currentUser?.email}");
      print("Current user display name: ${_auth.currentUser?.displayName}");
      print("==============================");

      // Fetch ALL workout schedules
      final snapshot = await FirebaseFirestore.instance.collection('workout_schedules').get();
      final allSchedules = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Make sure to include the document ID
            return WorkoutScheduleModel.fromJson(data);
          })
          .toList();

      print("=== Schedule Information ===");
      print("Total schedules in database: ${allSchedules.length}");
      for (var schedule in allSchedules) {
        print("Schedule ID: ${schedule.id}");
        print("Member ID: ${schedule.memberId}");
        print("Workout Type: ${schedule.workoutType}");
        print("Is Active: ${schedule.isActive}");
        print("------------------------");
      }

      // Filter schedules for the current user
      _workoutSchedules = allSchedules.where((s) => s.memberId == userId).toList();
      print("=== Filtered Schedules ===");
      print("Number of schedules for current user: ${_workoutSchedules.length}");
      print("=========================");

      _trainers = await _gymService.getTrainers();
    } catch (e) {
      log('Error loading workout schedules: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading schedule: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  List<WorkoutScheduleModel> _getSchedulesForDay(DateTime date) {
    final dayName = DateFormat('EEEE').format(date);
    return _workoutSchedules.where((schedule) => schedule.daysOfWeek.contains(dayName)).toList();
  }

  Map<String, List<WorkoutScheduleModel>> _getWeeklySchedules() {
    final Map<String, List<WorkoutScheduleModel>> weeklySchedules = {};
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (var day in days) {
      weeklySchedules[day] = _workoutSchedules.where((schedule) => schedule.daysOfWeek.contains(day)).toList();
    }
    
    return weeklySchedules;
  }

  String _getTrainerName(String trainerId) {
    try {
      final trainer = _trainers.firstWhere((t) => t.id == trainerId);
      return '${trainer.name} (${trainer.specialty})';
    } catch (e) {
      return 'Unknown Trainer';
    }
  }

  Widget _buildWorkoutCard(WorkoutScheduleModel schedule) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: Color(0xFF181818),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.yellow.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    schedule.workoutType,
                    style: TextStyle(
                      color: Colors.yellow[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Spacer(),
                Icon(Icons.fitness_center, color: Colors.yellow[800]),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, color: Colors.white70, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getTrainerName(schedule.trainerId),
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.white70, size: 20),
                SizedBox(width: 8),
                Text(
                  '${DateFormat('h:mm a').format(schedule.startTime)} - ${DateFormat('h:mm a').format(schedule.endTime)}',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (schedule.notes?.isNotEmpty ?? false) ...[
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      schedule.notes!,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyView() {
    final weeklySchedules = _getWeeklySchedules();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final schedules = weeklySchedules[day] ?? [];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${schedules.length} workouts',
                      style: TextStyle(
                        color: Colors.yellow[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (schedules.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF181818),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No workouts scheduled',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...schedules.map((schedule) => _buildWorkoutCard(schedule)).toList(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM d, yyyy').format(_selectedDate);
    final todaysSchedules = _getSchedulesForDay(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Workout Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isWeeklyView ? Icons.calendar_today : Icons.view_week,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() => _isWeeklyView = !_isWeeklyView);
            },
          ),
          if (!_isWeeklyView)
            IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.white70),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: Color(0xFFF9A825),
                          onPrimary: Colors.black,
                          surface: Colors.black,
                          onSurface: Colors.white,
                        ),
                        dialogBackgroundColor: Colors.black87,
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isWeeklyView) ...[
                SizedBox(height: 12),
                Text(
                  today,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFF181818),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statColumn('Total Workouts', '${_workoutSchedules.length}'),
                      _statColumn('Today\'s Workouts', '${todaysSchedules.length}'),
                      _statColumn('Active Days', '${_workoutSchedules.expand((s) => s.daysOfWeek).toSet().length}'),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Today\'s Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 12),
              ],
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else if (_isWeeklyView)
                Expanded(child: _buildWeeklyView())
              else if (todaysSchedules.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF181818),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'No workouts scheduled for today',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: todaysSchedules.length,
                    itemBuilder: (context, index) => _buildWorkoutCard(todaysSchedules[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.yellow[800],
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 