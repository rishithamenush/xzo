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

  @override
  void initState() {
    super.initState();
    _refreshTrainers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshTrainers() {
    setState(() {
      _isLoading = true;
      _trainersFuture = _gymService.getTrainers().then((trainers) {
        log('Successfully fetched ${trainers.length} trainers');
        _isLoading = false;
        return trainers;
      }).catchError((error) {
        _isLoading = false;
        log('Error fetching trainers: $error', error: error, stackTrace: StackTrace.current);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trainers: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        throw error;
      });
    });
  }

  Future<void> _navigateToAddTrainer() async {
    // TODO: Implement add trainer screen
    // await Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => const AddTrainerScreen()),
    // );
    // _refreshTrainers();
  }

  void _navigateToTrainerDetails(TrainerModel trainer) {
    // TODO: Implement trainer details screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => TrainerDetailsScreen(
    //       trainer: trainer,
    //     ),
    //   ),
    // ).then((_) => _refreshTrainers());
  }

  List<TrainerModel> _filterTrainers(List<TrainerModel> trainers) {
    return trainers.where((trainer) {
      // Search query matching
      final searchLower = _searchQuery.toLowerCase();
      final matchesSearch = 
          trainer.name.toLowerCase().contains(searchLower) ||
          trainer.email.toLowerCase().contains(searchLower) ||
          trainer.phone.contains(_searchQuery) ||
          trainer.specialty.toLowerCase().contains(searchLower);

      if (!matchesSearch) return false;

      // Specialty filtering
      if (_selectedFilter != 'All') {
        return trainer.specialty.toLowerCase() == _selectedFilter.toLowerCase();
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.background,
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
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: _navigateToAddTrainer,
            tooltip: 'Add New Trainer',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C0000).withOpacity(0.85),
              Color(0xFF000000).withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          children: [
            // Search and Filter Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
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
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filter Chips
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
            // Trainers List
            Expanded(
              child: FutureBuilder<List<TrainerModel>>(
                future: _trainersFuture,
                builder: (context, snapshot) {
                  if (_isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading trainers',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.dumbbell,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No trainers found',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final trainers = _filterTrainers(snapshot.data!);
                  
                  if (trainers.isEmpty) {
                    return Center(
                      child: Text(
                        'No trainers match your search',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: trainers.length,
                    itemBuilder: (context, index) {
                      return _buildTrainerCard(trainers[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerCard(TrainerModel trainer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToTrainerDetails(trainer),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Profile Image/Avatar
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
                      child: Text(
                        trainer.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            trainer.specialty,
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
                ],
              ),
              const SizedBox(height: 16),
              // Contact Information
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildInfoChip(Icons.email, trainer.email),
                  _buildInfoChip(Icons.phone, trainer.phone),
                ],
              ),
            ],
          ),
        ),
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