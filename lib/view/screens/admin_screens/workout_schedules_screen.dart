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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _members = await _gymService.getMembers();
      _trainers = await _gymService.getTrainers();
      
      // Load schedules for all members
      for (var member in _members) {
        if (member.id != null) {
          _memberSchedules[member.id!] = await _gymService.getMemberWorkoutSchedules(member.id!);
        }
      }
    } catch (e) {
      log('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  void _showAddEditScheduleDialog({WorkoutScheduleModel? schedule, String? memberId}) async {
    final isEdit = schedule != null;
    final workoutTypeController = TextEditingController(text: schedule?.workoutType ?? '');
    final notesController = TextEditingController(text: schedule?.notes ?? '');
    TrainerModel? selectedTrainer = isEdit ? _trainers.firstWhere((t) => t.id == schedule!.trainerId) : null;
    TimeOfDay? startTime = isEdit ? TimeOfDay.fromDateTime(schedule!.startTime) : null;
    TimeOfDay? endTime = isEdit ? TimeOfDay.fromDateTime(schedule!.endTime) : null;
    List<String> selectedDays = isEdit ? List.from(schedule!.daysOfWeek) : [];
    final workoutTypes = ['Strength', 'Cardio', 'HIIT', 'Yoga', 'CrossFit', 'Flexibility'];
    final targetMemberId = memberId ?? schedule?.memberId;

    if (targetMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member ID is required'), backgroundColor: Colors.red),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          isEdit ? 'Edit Workout Schedule' : 'Add Workout Schedule',
          style: TextStyle(color: Colors.white),
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
                  final isSelected = selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day.substring(0, 3)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
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
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[800]),
            child: Text(isEdit ? 'Update' : 'Add', style: TextStyle(color: Colors.black)),
            onPressed: () async {
              if (workoutTypeController.text.isEmpty || selectedTrainer == null || startTime == null || endTime == null || selectedDays.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.red),
                );
                return;
              }

              final now = DateTime.now();
              final start = DateTime(now.year, now.month, now.day, startTime!.hour, startTime!.minute);
              final end = DateTime(now.year, now.month, now.day, endTime!.hour, endTime!.minute);

              final newSchedule = WorkoutScheduleModel(
                id: schedule?.id,
                memberId: targetMemberId,
                workoutType: workoutTypeController.text.trim(),
                trainerId: selectedTrainer!.id!,
                startTime: start,
                endTime: end,
                daysOfWeek: List.from(selectedDays),
                notes: notesController.text.trim(),
              );

              try {
                if (isEdit) {
                  await _gymService.updateWorkoutSchedule(newSchedule);
                } else {
                  await _gymService.addWorkoutSchedule(newSchedule);
                }
                Navigator.pop(context);
                await _loadData(); // Reload all data
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving schedule: $e'), backgroundColor: Colors.red),
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
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black87,
          title: Text('Delete Schedule', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to delete this workout schedule?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.pop(context);
                await _gymService.deleteWorkoutSchedule(schedule.id!);
                await _loadData(); // Reload all data
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting schedule: $e'), backgroundColor: Colors.red),
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF181818),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMemberId,
                        isExpanded: true,
                        dropdownColor: Color(0xFF181818),
                        hint: Text('Select Member', style: TextStyle(color: Colors.white70)),
                        style: TextStyle(color: Colors.white),
                        items: _members.map((member) {
                          return DropdownMenuItem(
                            value: member.id,
                            child: Text(member.name ?? 'Unknown Member'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedMemberId = value);
                        },
                      ),
                    ),
                  ),
                ),
                // Schedule List
                Expanded(
                  child: _selectedMemberId == null
                      ? Center(
                          child: Text(
                            'Select a member to view their schedules',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: (_memberSchedules[_selectedMemberId] ?? []).length,
                          itemBuilder: (context, index) {
                            final schedule = _memberSchedules[_selectedMemberId]![index];
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
      floatingActionButton: _selectedMemberId != null
          ? FloatingActionButton(
              backgroundColor: Colors.yellow[800],
              child: Icon(Icons.add, color: Colors.black),
              onPressed: () => _showAddEditScheduleDialog(memberId: _selectedMemberId),
            )
          : null,
    );
  }
} 