import 'package:flutter/material.dart';
import 'package:turathi/core/services/gym_service.dart';
import 'package:turathi/core/models/member_model.dart';
import 'package:turathi/core/models/workout_schedule_model.dart';
import 'package:turathi/core/models/trainer_model.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class WorkoutSchedulesScreen extends StatefulWidget {
  @override
  State<WorkoutSchedulesScreen> createState() => _WorkoutSchedulesScreenState();
}

class _WorkoutSchedulesScreenState extends State<WorkoutSchedulesScreen> {
  final GymService _gymService = GymService();
  List<MemberModel> _members = [];
  List<TrainerModel> _trainers = [];
  Map<String, List<WorkoutScheduleModel>> _memberSchedules = {};
  bool _isLoading = true;
  String? _selectedMemberId;
  DateTime _selectedDate = DateTime.now();
  MemberModel? _selectedMember;
  List<WorkoutScheduleModel> _workoutSchedules = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      log('=== Loading Admin Workout Schedules Data ===');
      
      // Load members
      log('Loading members...');
      _members = await _gymService.getMembers();
      log('Loaded ${_members.length} members');
      
      // Load trainers
      log('Loading trainers...');
      _trainers = await _gymService.getTrainers();
      log('Loaded ${_trainers.length} trainers');
      
      // If a member is selected, load their schedules
      if (_selectedMember != null) {
        log('Loading schedules for selected member: ${_selectedMember!.name} (${_selectedMember!.id})');
        _workoutSchedules = await _gymService.getMemberWorkoutSchedules(_selectedMember!.id!);
        log('Loaded ${_workoutSchedules.length} schedules for member ${_selectedMember!.name}');
      } else {
        _workoutSchedules = [];
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      log('Error loading data: $e', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _onMemberSelected(MemberModel? member) {
    setState(() {
      _selectedMember = member;
      _workoutSchedules = []; // Clear existing schedules
    });
    if (member != null) {
      _loadData(); // Load schedules for the selected member
    }
  }

  Widget _buildMemberSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedMember?.id,
        decoration: InputDecoration(
          labelText: 'Select Member',
          labelStyle: TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.yellow),
          ),
        ),
        dropdownColor: Color(0xFF181818),
        style: TextStyle(color: Colors.white),
        items: _members.map((member) {
          return DropdownMenuItem<String>(
            value: member.id,
            child: Text(
              '${member.name} (${member.email})',
              style: TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (String? memberId) {
          if (memberId != null) {
            final member = _members.firstWhere((m) => m.id == memberId);
            _onMemberSelected(member);
          } else {
            _onMemberSelected(null);
          }
        },
      ),
    );
  }

  void _showAddEditScheduleDialog({WorkoutScheduleModel? schedule}) async {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a member first'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final isEdit = schedule != null;
    final workoutTypeController = TextEditingController(text: schedule?.workoutType ?? '');
    final notesController = TextEditingController(text: schedule?.notes ?? '');
    TrainerModel? selectedTrainer = isEdit ? _trainers.firstWhere((t) => t.id == schedule!.trainerId) : null;
    TimeOfDay? startTime = isEdit ? TimeOfDay.fromDateTime(schedule!.startTime) : null;
    TimeOfDay? endTime = isEdit ? TimeOfDay.fromDateTime(schedule!.endTime) : null;
    List<String> selectedDaysList = isEdit ? List.from(schedule!.daysOfWeek) : [];
    final workoutTypes = ['Strength', 'Cardio', 'HIIT', 'Yoga', 'CrossFit', 'Flexibility'];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          isEdit ? 'Edit Workout Schedule' : 'Add Workout Schedule for ${_selectedMember!.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Workout Type Dropdown
              DropdownButtonFormField<String>(
                value: workoutTypeController.text.isEmpty ? null : workoutTypeController.text,
                decoration: InputDecoration(
                  labelText: 'Workout Type',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                dropdownColor: Colors.black87,
                style: TextStyle(color: Colors.white),
                items: workoutTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) {
                  if (value != null) workoutTypeController.text = value;
                },
              ),
              SizedBox(height: 16),
              // Trainer Dropdown
              DropdownButtonFormField<TrainerModel>(
                value: selectedTrainer,
                decoration: InputDecoration(
                  labelText: 'Trainer',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                dropdownColor: Colors.black87,
                style: TextStyle(color: Colors.white),
                items: _trainers.map((trainer) => DropdownMenuItem(
                  value: trainer,
                  child: Text('${trainer.name} (${trainer.specialty})'),
                )).toList(),
                onChanged: (value) => selectedTrainer = value,
              ),
              SizedBox(height: 16),
              // Time Pickers
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: Icon(Icons.access_time, color: Colors.white70),
                      label: Text(
                        startTime != null ? DateFormat('h:mm a').format(DateTime(2024, 1, 1, startTime!.hour, startTime!.minute)) : 'Start Time',
                        style: TextStyle(color: Colors.white70),
                      ),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: startTime ?? TimeOfDay.now(),
                        );
                        if (time != null) startTime = time;
                      },
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      icon: Icon(Icons.access_time, color: Colors.white70),
                      label: Text(
                        endTime != null ? DateFormat('h:mm a').format(DateTime(2024, 1, 1, endTime!.hour, endTime!.minute)) : 'End Time',
                        style: TextStyle(color: Colors.white70),
                      ),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: endTime ?? TimeOfDay.now(),
                        );
                        if (time != null) endTime = time;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Days Selection
              Wrap(
                spacing: 8,
                children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((day) {
                  final isSelected = selectedDaysList.contains(day);
                  return FilterChip(
                    label: Text(day.substring(0, 3)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedDaysList.add(day);
                        } else {
                          selectedDaysList.remove(day);
                        }
                      });
                    },
                    backgroundColor: Colors.black54,
                    selectedColor: Colors.yellow[800],
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              // Notes
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[800]),
            child: Text(isEdit ? 'Update' : 'Add', style: const TextStyle(color: Colors.black)),
            onPressed: () async {
              if (workoutTypeController.text.isEmpty || selectedTrainer == null || startTime == null || endTime == null || selectedDaysList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              try {
                if (startTime == null || endTime == null || selectedTrainer == null) {
                  throw Exception('Required fields are missing');
                }

                // After null checks, we can safely assert these are non-null
                final nonNullStartTime = startTime!;
                final nonNullEndTime = endTime!;
                final nonNullTrainer = selectedTrainer!;

                final now = DateTime.now();
                final start = DateTime(now.year, now.month, now.day, nonNullStartTime.hour, nonNullStartTime.minute);
                final end = DateTime(now.year, now.month, now.day, nonNullEndTime.hour, nonNullEndTime.minute);

                if (nonNullTrainer.id == null) {
                  throw Exception('Trainer ID is missing');
                }

                final workoutType = workoutTypeController.text.trim();
                final notes = notesController.text.trim();
                final daysOfWeek = List<String>.from(selectedDaysList);

                if (schedule != null) {
                  // Update existing schedule
                  log('Updating schedule for member ${_selectedMember!.name}:');
                  log('  Schedule ID: ${schedule.id}');
                  log('  Workout Type: ${schedule.workoutType}');
                  
                  final updatedSchedule = WorkoutScheduleModel(
                    id: schedule.id,
                    memberId: _selectedMember!.id!,
                    workoutType: workoutType,
                    trainerId: nonNullTrainer.id!,
                    startTime: start,
                    endTime: end,
                    daysOfWeek: daysOfWeek,
                    notes: notes,
                    isActive: schedule.isActive,
                  );
                  
                  await _gymService.updateWorkoutSchedule(updatedSchedule);
                  log('Updated schedule for member ${_selectedMember!.name}:');
                  log('  ID: ${updatedSchedule.id}');
                  log('  Workout Type: ${updatedSchedule.workoutType}');
                } else {
                  // Create new schedule
                  final newSchedule = WorkoutScheduleModel(
                    memberId: _selectedMember!.id!,
                    workoutType: workoutType,
                    trainerId: nonNullTrainer.id!,
                    startTime: start,
                    endTime: end,
                    daysOfWeek: daysOfWeek,
                    notes: notes,
                    isActive: true,
                  );
                  
                  await _gymService.addWorkoutSchedule(newSchedule);
                  log('Added new schedule for member ${_selectedMember!.name}:');
                  log('  Workout Type: $workoutType');
                  log('  Trainer: ${nonNullTrainer.name}');
                  log('  Days: ${daysOfWeek.join(", ")}');
                }

                Navigator.pop(context);
                await _loadData(); // Reload all data
              } catch (e) {
                log('Error saving schedule: $e', error: e, stackTrace: StackTrace.current);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving schedule: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSchedule(WorkoutScheduleModel schedule) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Schedule'),
          content: Text('Are you sure you want to delete this workout schedule for ${_selectedMember?.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true && _selectedMember != null) {
        log('Deleting schedule: ${schedule.id} for member: ${_selectedMember!.id}');
        await _gymService.deleteWorkoutSchedule(_selectedMember!.id!, schedule.id!);
        log('Schedule deleted successfully');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Schedule deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          _loadData(); // Reload the schedules
        }
      }
    } catch (e, stackTrace) {
      log('Error deleting schedule: $e', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting schedule: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deactivateSchedule(WorkoutScheduleModel schedule) async {
    try {
      if (_selectedMember == null) {
        throw Exception('No member selected');
      }

      log('Deactivating schedule: ${schedule.id} for member: ${_selectedMember!.id}');
      await _gymService.deactivateWorkoutSchedule(_selectedMember!.id!, schedule.id!);
      log('Schedule deactivated successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Schedule deactivated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _loadData(); // Reload the schedules
      }
    } catch (e, stackTrace) {
      log('Error deactivating schedule: $e', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deactivating schedule: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Manage Workout Schedules',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Member Selection Dropdown
                _buildMemberSelector(),
                // Schedule List
                Expanded(
                  child: _selectedMember == null
                      ? Center(
                          child: Text(
                            'Select a member to view their schedules',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : _workoutSchedules.isEmpty
                          ? Center(
                              child: Text(
                                'No schedules found for this member',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _workoutSchedules.length,
                              itemBuilder: (context, index) {
                                final schedule = _workoutSchedules[index];
                                final trainer = _trainers.firstWhere(
                                  (t) => t.id == schedule.trainerId,
                                  orElse: () => TrainerModel(
                                    id: '',
                                    name: 'Unknown Trainer',
                                    email: 'unknown@trainer.com',
                                    phone: '0000000000',
                                    specialty: 'Unknown'
                                  ),
                                );
                                
                                return Card(
                                  margin: EdgeInsets.only(bottom: 12),
                                  color: Color(0xFF181818),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(16),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            schedule.workoutType,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.yellow[800]),
                                          onPressed: () => _showAddEditScheduleDialog(schedule: schedule),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteSchedule(schedule),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        Text(
                                          'Trainer: ${trainer.name} (${trainer.specialty})',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Time: ${DateFormat('h:mm a').format(schedule.startTime)} - ${DateFormat('h:mm a').format(schedule.endTime)}',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Days: ${schedule.daysOfWeek.join(", ")}',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        if (schedule.notes?.isNotEmpty ?? false) ...[
                                          SizedBox(height: 4),
                                          Text(
                                            'Notes: ${schedule.notes}',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
      floatingActionButton: _selectedMember != null
          ? FloatingActionButton(
              backgroundColor: Colors.yellow[800],
              child: Icon(Icons.add, color: Colors.black),
              onPressed: () => _showAddEditScheduleDialog(),
            )
          : null,
    );
  }
} 