import 'package:flutter/material.dart';
import 'package:turathi/core/services/gym_service.dart';
import 'package:turathi/core/models/class_model.dart';
import 'package:turathi/core/models/trainer_model.dart';
import 'package:turathi/view/view_layer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({Key? key}) : super(key: key);

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final GymService _gymService = GymService();
  late Future<List<GymClassModel>> _classesFuture;
  late Future<List<TrainerModel>> _trainersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Strength', 'Cardio', 'Yoga', 'CrossFit'];
  bool _isLoading = false;
  Map<String, TrainerModel> _trainerMap = {};
  List<GymClassModel> _classes = [];
  List<TrainerModel> _trainers = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() { _isLoading = true; });
    try {
      _trainers = await _gymService.getTrainers();
      _trainerMap = {for (var t in _trainers) t.id!: t};
      _classes = await _gymService.getClasses();
    } catch (e) {
      log('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() { _isLoading = false; });
  }

  List<GymClassModel> _filterClasses() {
    return _classes.where((gymClass) {
      final searchLower = _searchQuery.toLowerCase();
      final trainer = _trainerMap[gymClass.trainerId];
      final matchesSearch =
        gymClass.name.toLowerCase().contains(searchLower) ||
        (trainer?.name.toLowerCase().contains(searchLower) ?? false) ||
        (trainer?.specialty.toLowerCase().contains(searchLower) ?? false);
      if (!matchesSearch) return false;
      if (_selectedFilter != 'All') {
        return trainer?.specialty.toLowerCase() == _selectedFilter.toLowerCase();
      }
      return true;
    }).toList();
  }

  String _formatTime(DateTime time) => DateFormat('h:mm a').format(time);
  String _formatDays(List<String> days) => days.map((d) => d.substring(0, 3)).join(', ');

  void _showAddEditClassDialog({GymClassModel? gymClass}) async {
    final isEdit = gymClass != null;
    final nameController = TextEditingController(text: gymClass?.name ?? '');
    TrainerModel? selectedTrainer = isEdit ? _trainerMap[gymClass!.trainerId] : null;
    TimeOfDay? startTime = isEdit ? TimeOfDay.fromDateTime(gymClass!.startTime) : null;
    TimeOfDay? endTime = isEdit ? TimeOfDay.fromDateTime(gymClass!.endTime) : null;
    List<String> selectedDays = isEdit ? List.from(gymClass!.daysOfWeek) : [];
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isEdit ? 'Edit Class' : 'Add Class', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Class Name',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TrainerModel>(
                      value: selectedTrainer,
                      items: _trainers.map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name, style: TextStyle(color: Colors.black)),
                      )).toList(),
                      onChanged: (t) => setState(() => selectedTrainer = t),
                      decoration: InputDecoration(
                        labelText: 'Trainer',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                      ),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(context: context, initialTime: startTime ?? TimeOfDay(hour: 8, minute: 0));
                              if (picked != null) setState(() => startTime = picked);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  startTime == null ? 'Start Time' : startTime!.format(context),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(context: context, initialTime: endTime ?? TimeOfDay(hour: 9, minute: 0));
                              if (picked != null) setState(() => endTime = picked);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  endTime == null ? 'End Time' : endTime!.format(context),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'].map((d) {
                        final full = {'Mon':'Monday','Tue':'Tuesday','Wed':'Wednesday','Thu':'Thursday','Fri':'Friday','Sat':'Saturday','Sun':'Sunday'}[d]!;
                        final selected = selectedDays.contains(full);
                        return FilterChip(
                          label: Text(d, style: TextStyle(color: selected ? Colors.white : Colors.white70)),
                          selected: selected,
                          onSelected: (val) {
                            setState(() {
                              if (val) selectedDays.add(full);
                              else selectedDays.remove(full);
                            });
                          },
                          backgroundColor: Colors.white12,
                          selectedColor: Colors.yellow[800],
                        );
                      }).toList(),
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
                    if (nameController.text.trim().isEmpty || selectedTrainer == null || startTime == null || endTime == null || selectedDays.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    final now = DateTime.now();
                    final start = DateTime(now.year, now.month, now.day, startTime!.hour, startTime!.minute);
                    final end = DateTime(now.year, now.month, now.day, endTime!.hour, endTime!.minute);
                    final newClass = GymClassModel(
                      id: gymClass?.id,
                      name: nameController.text.trim(),
                      trainerId: selectedTrainer!.id!,
                      startTime: start,
                      endTime: end,
                      daysOfWeek: List.from(selectedDays),
                    );
                    try {
                      if (isEdit) {
                        await _gymService.updateClass(newClass);
                      } else {
                        await _gymService.addClass(newClass);
                      }
                      Navigator.pop(context);
                      await _refreshData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteClass(GymClassModel gymClass) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Class', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this class?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(child: Text('Cancel', style: TextStyle(color: Colors.white70)), onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(child: Text('Delete', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _gymService.deleteClass(gymClass.id!);
        await _refreshData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Classes Management',
          style: ThemeManager.textStyle.copyWith(
            fontSize: LayoutManager.widthNHeight0(context, 1) * 0.05,
            fontWeight: FontWeight.bold,
            fontFamily: ThemeManager.fontFamily,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 8, color: Colors.black45, offset: Offset(0,2))],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'Add New Class',
            onPressed: () => _showAddEditClassDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[800],
        child: Icon(Icons.add, color: Colors.black),
        onPressed: () => _showAddEditClassDialog(),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/img_png/admin_.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1976D2).withOpacity(0.85),
                    Color(0xFF000000).withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search classes...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: (value) {
                            setState(() { _searchQuery = value; });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = selected ? filter : 'All';
                                  });
                                },
                                backgroundColor: Colors.white.withOpacity(0.1),
                                selectedColor: Color(0xFF1976D2).withOpacity(0.3),
                                checkmarkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: isSelected ? 2 : 0,
                                shadowColor: Colors.black.withOpacity(0.2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : _classes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.calendarAlt, size: 64, color: Colors.white.withOpacity(0.3)),
                                  const SizedBox(height: 16),
                                  Text('No classes found', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filterClasses().length,
                              itemBuilder: (context, index) {
                                final gymClass = _filterClasses()[index];
                                final trainer = _trainerMap[gymClass.trainerId];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: InkWell(
                                    onTap: () => _showAddEditClassDialog(gymClass: gymClass),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF1976D2).withOpacity(0.95),
                                            Colors.black.withOpacity(0.9),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 56,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.white.withOpacity(0.2),
                                                      Colors.white.withOpacity(0.1),
                                                    ],
                                                  ),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.2),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Icon(FontAwesomeIcons.dumbbell, color: Colors.white, size: 24),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      gymClass.name,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    if (trainer != null)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Text(
                                                          '${trainer.name} • ${trainer.specialty}',
                                                          style: TextStyle(
                                                            color: Colors.white.withOpacity(0.9),
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete, color: Colors.red[300]),
                                                tooltip: 'Delete Class',
                                                onPressed: () => _deleteClass(gymClass),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 12,
                                            children: [
                                              _buildInfoChip(Icons.access_time, '${_formatTime(gymClass.startTime)} - ${_formatTime(gymClass.endTime)}'),
                                              _buildInfoChip(Icons.calendar_today, _formatDays(gymClass.daysOfWeek)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 