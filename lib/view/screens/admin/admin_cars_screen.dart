import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/car.dart';


class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({super.key});

  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  final _descriptionController = TextEditingController();
  Car? _editingCar;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final carData = {
        'name': _nameController.text,
        'brand': _brandController.text,
        'imageUrl': _imageUrlController.text,
        'pricePerDay': double.tryParse(_priceController.text) ?? 0.0,
        'seats': int.tryParse(_seatsController.text) ?? 0,
        'description': _descriptionController.text,
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (_editingCar != null) {
        await FirebaseFirestore.instance
            .collection('cars')
            .doc(_editingCar!.id)
            .update(carData);
      } else {
        await FirebaseFirestore.instance.collection('cars').add(carData);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_editingCar != null ? 'Car updated' : 'Car added'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _editCar(Car car) {
    setState(() {
      _editingCar = car;
      _nameController.text = car.name;
      _brandController.text = car.brand;
      _imageUrlController.text = car.imageUrl;
      _priceController.text = car.pricePerDay.toString();
      _seatsController.text = car.seats.toString();
      _descriptionController.text = car.description ?? '';
    });
    _showCarForm();
  }

  Future<void> _deleteCar(Car car) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Car'),
        content: Text('Are you sure you want to delete ${car.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('cars').doc(car.id).update({'isActive': false});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Car deleted'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showCarForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4))],
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_editingCar != null ? 'Edit Car' : 'Add New Car', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(Icons.directions_car, color: Color(0xFF2196F3))),
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _brandController,
                    decoration: InputDecoration(labelText: 'Brand', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(Icons.branding_watermark, color: Color(0xFF2196F3))),
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter a brand' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(labelText: 'Image URL', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(Icons.image, color: Color(0xFF2196F3))),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Price per day', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(Icons.attach_money, color: Color(0xFF2196F3))),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty || double.tryParse(value) == null ? 'Enter a valid price' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _seatsController,
                    decoration: InputDecoration(labelText: 'Seats', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(Icons.event_seat, color: Color(0xFF2196F3))),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty || int.tryParse(value) == null ? 'Enter a valid seat count' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(Icons.info_outline, color: Color(0xFF2196F3))),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveCar,
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2196F3), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isLoading ? const CircularProgressIndicator() : Text(_editingCar != null ? 'Update Car' : 'Add Car', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Cars')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').where('isActive', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cars = snapshot.data?.docs.map((doc) => Car.fromFirestore(doc)).toList() ?? [];
          if (cars.isEmpty) {
            return const Center(child: Text('No cars found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: car.imageUrl.isNotEmpty
                      ? CircleAvatar(backgroundImage: NetworkImage(car.imageUrl))
                      : const CircleAvatar(child: Icon(Icons.directions_car)),
                  title: Text(car.name),
                  subtitle: Text('${car.brand} • ${car.seats} seats'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _editCar(car)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCar(car), color: Colors.red),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _editingCar = null;
            _nameController.clear();
            _brandController.clear();
            _imageUrlController.clear();
            _priceController.clear();
            _seatsController.clear();
            _descriptionController.clear();
          });
          _showCarForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 