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
    log('Initializing ScheduleScreen');
    log('Current user UID: ${_auth.currentUser?.uid}');
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user is currently logged in');
      }

      log('=== Loading Schedule Data ===');
      log('User ID: $userId');
      log('User Email: ${_auth.currentUser?.email}');
      
      // Get schedules using GymService
      log('Fetching schedules from GymService...');
      _workoutSchedules = await _gymService.getMemberWorkoutSchedules(userId);
      log('Raw schedules from GymService: ${_workoutSchedules.length}');
      
      // Log each schedule's raw data
      for (var schedule in _workoutSchedules) {
        log('Raw Schedule Data:');
        log('  Document ID: ${schedule.id}');
        log('  Member ID: ${schedule.memberId}');
        log('  Workout Type: ${schedule.workoutType}');
        log('  Trainer ID: ${schedule.trainerId}');
        log('  Start Time: ${schedule.startTime}');
        log('  End Time: ${schedule.endTime}');
        log('  Days: ${schedule.daysOfWeek}');
        log('  Is Active: ${schedule.isActive}');
        log('  Notes: ${schedule.notes}');
        log('------------------------');
      }
      
      // Get trainers
      log('Fetching trainers...');
      _trainers = await _gymService.getTrainers();
      log('Loaded trainers: ${_trainers.length}');
      
      // Log trainer details
      for (var trainer in _trainers) {
        log('Trainer: ${trainer.name} (ID: ${trainer.id}, Specialty: ${trainer.specialty})');
      }

      // Verify schedule filtering
      final todaysSchedules = _getSchedulesForDay(DateTime.now());
      log('=== Schedule Filtering ===');
      log('Total schedules: ${_workoutSchedules.length}');
      log('Active schedules: ${_workoutSchedules.where((s) => s.isActive).length}');
      log('Today\'s schedules: ${todaysSchedules.length}');
      log('Current day: ${DateFormat('EEEE').format(DateTime.now())}');
      
      // Log today's schedules
      for (var schedule in todaysSchedules) {
        log('Today\'s Schedule:');
        log('  Workout Type: ${schedule.workoutType}');
        log('  Trainer: ${_getTrainerName(schedule.trainerId)}');
        log('  Time: ${DateFormat('h:mm a').format(schedule.startTime)} - ${DateFormat('h:mm a').format(schedule.endTime)}');
      }

    } catch (e, stackTrace) {
      log('Error loading workout schedules: $e', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading schedule: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<WorkoutScheduleModel> _getSchedulesForDay(DateTime date) {
    final dayName = DateFormat('EEEE').format(date);
    log('Getting schedules for day: $dayName');
    
    final schedules = _workoutSchedules
        .where((schedule) => 
            schedule.isActive && 
            schedule.daysOfWeek.contains(dayName))
        .toList();
    
    log('Found ${schedules.length} schedules for $dayName');
    for (var schedule in schedules) {
      log('Schedule for $dayName:');
      log('  Workout Type: ${schedule.workoutType}');
      log('  Days: ${schedule.daysOfWeek.join(", ")}');
      log('  Is Active: ${schedule.isActive}');
    }
    
    return schedules;
  }

  Map<String, List<WorkoutScheduleModel>> _getWeeklySchedules() {
    final Map<String, List<WorkoutScheduleModel>> weeklySchedules = {};
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (var day in days) {
      weeklySchedules[day] = _workoutSchedules
          .where((schedule) => 
              schedule.isActive && 
              schedule.daysOfWeek.contains(day))
          .toList();
    }
    
    return weeklySchedules;
  }

  String _getTrainerName(String trainerId) {
    try {
      final trainer = _trainers.firstWhere((t) => t.id == trainerId);
      return '${trainer.name} (${trainer.specialty})';
    } catch (e) {
      log('Error finding trainer: $e');
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