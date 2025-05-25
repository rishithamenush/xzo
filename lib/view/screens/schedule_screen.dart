import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turathi/core/services/gym_service.dart';
import 'package:turathi/core/models/workout_schedule_model.dart';
import 'package:turathi/core/models/trainer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

import '../../core/models/workout_progress_model.dart';

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

  void _showScheduleDetailsDialog(WorkoutScheduleModel schedule, TrainerModel trainer) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    TextEditingController notesController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF181818),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          schedule.workoutType,
          style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Trainer: ${trainer.name}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Time: ${DateFormat('h:mm a').format(schedule.startTime)} - ${DateFormat('h:mm a').format(schedule.endTime)}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Days: ${schedule.daysOfWeek.join(", ")}', style: const TextStyle(color: Colors.white70)),
              if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notes: ${schedule.notes}', style: const TextStyle(color: Colors.white70)),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Add a note (optional)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[800]),
            child: const Text('Start', style: TextStyle(color: Colors.black)),
            onPressed: () async {
              final progress = WorkoutProgressModel(
                date: DateTime.now(),
                status: 'started',
                notes: notesController.text.trim(),
              );
              await _gymService.addWorkoutProgress(userId, schedule.id!, progress);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Workout started!'), backgroundColor: Colors.green),
                );
                _loadData();
              }
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: const Text('Finish', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final progress = WorkoutProgressModel(
                date: DateTime.now(),
                status: 'completed',
                notes: notesController.text.trim(),
              );
              await _gymService.addWorkoutProgress(userId, schedule.id!, progress);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Workout marked as completed!'), backgroundColor: Colors.green),
                );
                _loadData();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'My Workout Schedule',
          style: TextStyle(
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow[800]!),
                      strokeWidth: 6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Loading your schedule...',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            )
          : _workoutSchedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 80, color: Colors.yellow[800]),
                      const SizedBox(height: 24),
                      const Text(
                        'No workout schedules found',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Your workout plans will appear here.\nContact your trainer or admin to get started!',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _workoutSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _workoutSchedules[index];
                    final trainer = _trainers.firstWhere(
                      (t) => t.id == schedule.trainerId,
                      orElse: () => TrainerModel(
                        id: '',
                        name: 'Unknown Trainer',
                        email: '',
                        phone: '',
                        specialty: '',
                      ),
                    );
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.yellow[700]!.withOpacity(0.12),
                            Colors.yellow[900]!.withOpacity(0.08),
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _showScheduleDetailsDialog(schedule, trainer),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.sports_gymnastics, color: Colors.yellow[800], size: 32),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        schedule.workoutType,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    if (!schedule.isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red[700],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Inactive',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.yellow[700], size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Trainer: ${trainer.name}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.yellow[700], size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${DateFormat('h:mm a').format(schedule.startTime)} - ${DateFormat('h:mm a').format(schedule.endTime)}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.calendar_today, color: Colors.yellow[700], size: 20),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: schedule.daysOfWeek.map((day) {
                                          final isToday = day == DateFormat('EEEE').format(DateTime.now());
                                          return Chip(
                                            label: Text(
                                              day.substring(0, 3),
                                              style: TextStyle(
                                                color: isToday ? Colors.black : Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            backgroundColor: isToday
                                                ? Colors.yellow[700]
                                                : Colors.grey[850],
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.sticky_note_2, color: Colors.yellow[700], size: 20),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          schedule.notes!,
                                          style: const TextStyle(color: Colors.white70, fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 