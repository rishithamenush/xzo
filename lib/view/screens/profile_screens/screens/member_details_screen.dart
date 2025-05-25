import 'package:flutter/material.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/core/services/gym_service.dart';
import 'package:turathi/view/view_layer.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

import '../../../../core/models/member_model.dart';
import '../../../../core/models/workout_schedule_model.dart';
import '../../../../core/models/trainer_model.dart';

class MemberDetailsScreen extends StatefulWidget {
  final MemberModel member;
  final bool isAdmin;

  const MemberDetailsScreen({
    Key? key,
    required this.member,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _membershipTypeController;
  late TextEditingController _joinDateController;
  late TextEditingController _expiryDateController;
  late TextEditingController _registrationNumberController;
  bool _isEditing = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _selectedJoinDate;
  DateTime? _selectedExpiryDate;
  final GymService _gymService = GymService();
  List<WorkoutScheduleModel> _workoutSchedules = [];
  List<TrainerModel> _trainers = [];
  bool _isLoadingSchedules = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.isAdmin) {
      _loadWorkoutSchedules();
      _loadTrainers();
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.member.name);
    _phoneController = TextEditingController(text: widget.member.phone);
    _membershipTypeController = TextEditingController(text: widget.member.membershipType);
    _registrationNumberController = TextEditingController(text: widget.member.registrationNumber);
    _joinDateController = TextEditingController(
      text: widget.member.joinDate != null ? _dateFormat.format(widget.member.joinDate!) : '',
    );
    _expiryDateController = TextEditingController(
      text: widget.member.expiryDate != null ? _dateFormat.format(widget.member.expiryDate!) : '',
    );
    _selectedJoinDate = widget.member.joinDate;
    _selectedExpiryDate = widget.member.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _membershipTypeController.dispose();
    _joinDateController.dispose();
    _expiryDateController.dispose();
    _registrationNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isJoinDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isJoinDate ? _selectedJoinDate ?? DateTime.now() : _selectedExpiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C0000),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isJoinDate) {
          _selectedJoinDate = picked;
          _joinDateController.text = _dateFormat.format(picked);
        } else {
          _selectedExpiryDate = picked;
          _expiryDateController.text = _dateFormat.format(picked);
        }
      });
    }
  }

  Future<void> _updateMember() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        log("Starting member update process...");
        
        // Convert UserModel to MemberModel
        final updatedMember = MemberModel(
          id: widget.member.id,
          name: _nameController.text,
          email: widget.member.email,
          phone: _phoneController.text,
          registrationNumber: _registrationNumberController.text,
          membershipType: _membershipTypeController.text,
          joinDate: _selectedJoinDate,
          expiryDate: _selectedExpiryDate,
          status: 'active', // You might want to preserve the existing status
        );

        log("Updating member with ID: ${updatedMember.id}");
        
        // Update member in database using GymService
        await _gymService.updateMember(updatedMember);
        
        log("Member updated successfully");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Member details updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {
            _isEditing = false;
            _isLoading = false;
          });
        }
      } catch (e) {
        log("Error updating member: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating member: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _loadWorkoutSchedules() async {
    if (!widget.isAdmin) return;
    setState(() => _isLoadingSchedules = true);
    try {
      _workoutSchedules = await _gymService.getMemberWorkoutSchedules(widget.member.id!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading workout schedules: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoadingSchedules = false);
  }

  Future<void> _loadTrainers() async {
    if (!widget.isAdmin) return;
    try {
      _trainers = await _gymService.getTrainers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trainers: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddEditScheduleDialog({WorkoutScheduleModel? schedule}) async {
    final isEdit = schedule != null;
    final workoutTypeController = TextEditingController(text: schedule?.workoutType ?? '');
    final notesController = TextEditingController(text: schedule?.notes ?? '');
    TrainerModel? selectedTrainer = isEdit ? _trainers.firstWhere((t) => t.id == schedule!.trainerId) : null;
    TimeOfDay? startTime = isEdit ? TimeOfDay.fromDateTime(schedule!.startTime) : null;
    TimeOfDay? endTime = isEdit ? TimeOfDay.fromDateTime(schedule!.endTime) : null;
    List<String> selectedDays = isEdit ? List.from(schedule!.daysOfWeek) : [];
    final workoutTypes = ['Strength', 'Cardio', 'HIIT', 'Yoga', 'CrossFit', 'Flexibility'];

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
                        startTime != null ? DateFormat('h:mm a').format(DateTime(2024, 1, 1, startTime!.hour, startTime !.minute)) : 'Start Time',
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
                memberId: widget.member.id!,
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
                await _loadWorkoutSchedules();
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

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget content,
    Color? iconColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor ?? const Color(0xFF2C0000)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C0000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF2C0000)),
        prefixIcon: Icon(icon, color: const Color(0xFF2C0000)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C0000)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C0000), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Member Details' : 'Member Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2C0000),
        actions: [
          if (widget.isAdmin && !_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    _initializeControllers(); // Reset to original values
                  }
                  _isEditing = !_isEditing;
                });
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header with Status
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFF2C0000),
                              child: Text(
                                widget.member.name?.substring(0, 1).toUpperCase() ?? 'M',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.member.name ?? 'Member',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C0000),
                          ),
                        ),
                        Text(
                          widget.member.membershipType ?? 'Member',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Member Information
                  if (!_isEditing) ...[
                    _buildInfoCard(
                      title: 'Registration Details',
                      icon: Icons.badge,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.confirmation_number, 'Registration Number', widget.member.registrationNumber ?? 'N/A'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.card_membership, 'Membership Type', widget.member.membershipType ?? 'N/A'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      title: 'Contact Information',
                      icon: Icons.contact_phone,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.phone, 'Phone', widget.member.phone ?? 'N/A'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.email, 'Email', widget.member.email ?? 'N/A'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard(
                      title: 'Membership Period',
                      icon: Icons.calendar_today,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            Icons.event_available,
                            'Join Date',
                            widget.member.joinDate != null ? _dateFormat.format(widget.member.joinDate!) : 'N/A',
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.event_busy,
                            'Expiry Date',
                            widget.member.expiryDate != null ? _dateFormat.format(widget.member.expiryDate!) : 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Edit Form
                    _buildEditableField(
                      controller: _registrationNumberController,
                      label: 'Registration Number',
                      icon: Icons.confirmation_number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Registration number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildEditableField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildEditableField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Phone number is required';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value!)) {
                          return 'Enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildEditableField(
                      controller: _membershipTypeController,
                      label: 'Membership Type',
                      icon: Icons.card_membership,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Membership type is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildEditableField(
                      controller: _joinDateController,
                      label: 'Join Date',
                      icon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () => _selectDate(context, true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Join date is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildEditableField(
                      controller: _expiryDateController,
                      label: 'Expiry Date',
                      icon: Icons.event_busy,
                      readOnly: true,
                      onTap: () => _selectDate(context, false),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Expiry date is required';
                        }
                        if (_selectedJoinDate != null && _selectedExpiryDate != null) {
                          if (_selectedExpiryDate!.isBefore(_selectedJoinDate!)) {
                            return 'Expiry date must be after join date';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateMember,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C0000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Update Member',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C0000)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
} 