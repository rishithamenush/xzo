import 'package:flutter/material.dart';
import '../../core/models/car.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback? onTap;
  final bool showBookButton;

  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.showBookButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 200;
        return Card(
          elevation: 10,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          shadowColor: Colors.blue.withOpacity(0.18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Car Image with overlay and favorite icon
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                      child: car.imageUrl.isNotEmpty
                          ? Image.network(
                              car.imageUrl,
                              height: isWide ? 120 : 90,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: isWide ? 120 : 90,
                                color: Colors.grey[300],
                                child: const Icon(Icons.directions_car, size: 40, color: Colors.grey),
                              ),
                            )
                          : Container(
                              height: isWide ? 120 : 90,
                              color: Colors.grey[200],
                              child: const Icon(Icons.directions_car, size: 40, color: Colors.grey),
                            ),
                    ),
                    // Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Favorite icon (placeholder)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: Colors.white.withOpacity(0.85),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(Icons.favorite_border, color: Colors.red[400], size: isWide ? 22 : 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Car Info
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 16 : 10, vertical: isWide ? 14 : 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              car.name,
                              style: TextStyle(
                                fontSize: isWide ? 18 : 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2196F3),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Price badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF43A047),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_money, size: 15, color: Colors.white),
                                Text(
                                  car.pricePerDay.toStringAsFixed(0),
                                  style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const Text('/day', style: TextStyle(fontSize: 11, color: Colors.white70)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.directions_car, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            car.brand,
                            style: TextStyle(fontSize: isWide ? 13 : 11, color: Colors.black54, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          const Icon(Icons.event_seat, size: 14, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text('${car.seats}', style: TextStyle(fontSize: isWide ? 13 : 11, color: Colors.grey)),
                        ],
                      ),
                      if (showBookButton) ...[
                        SizedBox(height: isWide ? 16 : 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: isWide ? 12 : 8),
                            ),
                            child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 