import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/guide.dart';

import '../widgets/guide_card.dart';
import 'home_screen_widgets/home_screen.dart';

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  String _selectedCity = 'All';
  final List<String> _cities = ['All', 'Colombo', 'Kandy', 'Galle', 'Jaffna', 'Anuradhapura'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Tour Guides'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      TourismColors.primary.withOpacity(0.8),
                      TourismColors.primary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/img_png/guide.jpg',
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.3),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // City Filter
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _cities.length,
                itemBuilder: (context, index) {
                  final city = _cities[index];
                  final isSelected = city == _selectedCity;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(city),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCity = selected ? city : 'All';
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: TourismColors.primary.withOpacity(0.2),
                      checkmarkColor: TourismColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? TourismColors.primary : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Guides List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('guides')
                .where('isActive', isEqualTo: true)
                .where('city', isEqualTo: _selectedCity == 'All' ? null : _selectedCity)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Something went wrong')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final guides = snapshot.data?.docs
                  .map((doc) => Guide.fromFirestore(doc))
                  .toList() ?? [];

              if (guides.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No guides found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final guide = guides[index];
                      return GuideCard(guide: guide);
                    },
                    childCount: guides.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 