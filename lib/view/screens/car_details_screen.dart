import 'package:flutter/material.dart';
import '../../core/models/car.dart';

class CarDetailsScreen extends StatelessWidget {
  final Car car;
  const CarDetailsScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(car.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Car Image
            car.imageUrl.isNotEmpty
                ? Image.network(
                    car.imageUrl,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Icon(Icons.directions_car, size: 80, color: Colors.grey),
                    ),
                  )
                : Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: const Icon(Icons.directions_car, size: 80, color: Colors.grey),
                  ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(car.brand, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.event_seat, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text('${car.seats} seats', style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 24),
                      const Icon(Icons.attach_money, size: 18, color: Colors.green),
                      Text(
                        car.pricePerDay.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const Text('/day', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (car.description != null && car.description!.isNotEmpty) ...[
                    const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(car.description!, style: const TextStyle(fontSize: 16, height: 1.5)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 