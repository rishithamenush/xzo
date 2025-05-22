import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/car.dart';
import '../widgets/car_card.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  String _search = '';
  String _selectedBrand = 'All';
  List<String> _brands = ['All'];

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    final snapshot = await FirebaseFirestore.instance.collection('cars').where('isActive', isEqualTo: true).get();
    final brands = snapshot.docs.map((doc) => (doc['brand'] ?? '').toString()).toSet().toList();
    setState(() {
      _brands = ['All', ...brands.where((b) => b.isNotEmpty).toSet().toList()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern header with gradient and icon
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2196F3), Color(0xFF43A047)],
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                    ),
                  ),
                  Positioned(
                    right: 32,
                    top: 32,
                    child: Icon(Icons.directions_car, size: 64, color: Colors.white.withOpacity(0.15)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Car Rentals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Find the perfect ride for your journey',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search cars, brands... ',
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search, color: Color(0xFF2196F3)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            ),
                            onChanged: (value) => setState(() => _search = value.trim()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Brand filter chips
              if (_brands.length > 1)
                Container(
                  height: 48,
                  margin: const EdgeInsets.only(top: 12, left: 8, right: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _brands.length,
                    itemBuilder: (context, index) {
                      final brand = _brands[index];
                      final isSelected = brand == _selectedBrand;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(brand),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedBrand = brand;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF2196F3),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Car grid or empty state
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cars')
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var cars = snapshot.data?.docs
                          .map((doc) => Car.fromFirestore(doc))
                          .toList() ?? [];
                  if (_search.isNotEmpty) {
                    cars = cars.where((car) =>
                      car.name.toLowerCase().contains(_search.toLowerCase()) ||
                      car.brand.toLowerCase().contains(_search.toLowerCase())
                    ).toList();
                  }
                  if (_selectedBrand != 'All') {
                    cars = cars.where((car) => car.brand == _selectedBrand).toList();
                  }
                  if (cars.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/empty_cars.png', height: 120),
                          const SizedBox(height: 24),
                          const Text(
                            'No cars available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return CarCard(
                        car: car,
                        onTap: () {
                          Navigator.of(context).pushNamed('/bottomScreen/cars/details', arguments: car);
                        },
                        showBookButton: true,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 