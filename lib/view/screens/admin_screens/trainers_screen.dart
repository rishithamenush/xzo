import 'package:flutter/material.dart';
import 'package:turathi/core/services/gym_service.dart';
import 'package:turathi/core/models/trainer_model.dart';
import 'package:turathi/view/view_layer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:developer';

class TrainersScreen extends StatefulWidget {
  const TrainersScreen({Key? key}) : super(key: key);

  @override
  State<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends State<TrainersScreen> {
  final GymService _gymService = GymService();
  late Future<List<TrainerModel>> _trainersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Strength', 'Cardio', 'Yoga', 'CrossFit'];
  bool _isLoading = false;
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trainers: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() { _isLoading = false; });
  }

  List<TrainerModel> _filterTrainers() {
    return _trainers.where((trainer) {
      final searchLower = _searchQuery.toLowerCase();
      final matchesSearch =
        trainer.name.toLowerCase().contains(searchLower) ||
        trainer.email.toLowerCase().contains(searchLower) ||
        trainer.phone.toLowerCase().contains(searchLower) ||
        trainer.specialty.toLowerCase().contains(searchLower);
      if (!matchesSearch) return false;
      if (_selectedFilter != 'All') {
        return trainer.specialty.toLowerCase() == _selectedFilter.toLowerCase();
      }
      return true;
    }).toList();
  }

  void _showAddEditTrainerDialog({TrainerModel? trainer}) async {
    final isEdit = trainer != null;
    final nameController = TextEditingController(text: trainer?.name ?? '');
    final emailController = TextEditingController(text: trainer?.email ?? '');
    final phoneController = TextEditingController(text: trainer?.phone ?? '');
    String? selectedSpecialty = trainer?.specialty;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isEdit ? 'Edit Trainer' : 'Add Trainer', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedSpecialty,
                      items: ['Strength', 'Cardio', 'Yoga', 'CrossFit'].map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: TextStyle(color: Colors.black)),
                      )).toList(),
                      onChanged: (s) => setState(() => selectedSpecialty = s),
                      decoration: InputDecoration(
                        labelText: 'Specialty',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                      ),
                      dropdownColor: Colors.white,
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(isEdit ? 'Update' : 'Add', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty || phoneController.text.trim().isEmpty || selectedSpecialty == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    final newTrainer = TrainerModel(
                      id: trainer?.id,
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                      specialty: selectedSpecialty!,
                    );
                    try {
                      if (isEdit) {
                        await _gymService.updateTrainer(newTrainer);
                      } else {
                        await _gymService.addTrainer(newTrainer);
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

  Future<void> _deleteTrainer(TrainerModel trainer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Trainer', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this trainer?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(child: Text('Cancel', style: TextStyle(color: Colors.white70)), onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(child: Text('Delete', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _gymService.deleteTrainer(trainer.id!);
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
          'Trainers Management',
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
            tooltip: 'Add New Trainer',
            onPressed: () => _showAddEditTrainerDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddEditTrainerDialog(),
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
                    Color(0xFF388E3C).withOpacity(0.85),
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
                            hintText: 'Search trainers...',
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
                                selectedColor: Color(0xFF388E3C).withOpacity(0.3),
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
                      : _trainers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.user, size: 64, color: Colors.white.withOpacity(0.3)),
                                  const SizedBox(height: 16),
                                  Text('No trainers found', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filterTrainers().length,
                              itemBuilder: (context, index) {
                                final trainer = _filterTrainers()[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: InkWell(
                                    onTap: () => _showAddEditTrainerDialog(trainer: trainer),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF388E3C).withOpacity(0.95),
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
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundColor: Colors.white.withOpacity(0.18),
                                            child: Text(
                                              trainer.name.isNotEmpty ? trainer.name[0].toUpperCase() : '?',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  trainer.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  trainer.specialty,
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  trainer.email,
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  trainer.phone,
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red[300]),
                                            tooltip: 'Delete Trainer',
                                            onPressed: () => _deleteTrainer(trainer),
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
} 