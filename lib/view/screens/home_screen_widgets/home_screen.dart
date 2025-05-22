import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/core/models/notification_model.dart';
import 'package:turathi/view/view_layer.dart';
import 'package:url_launcher/url_launcher.dart';

//user home page includes popular places,events,notifications and, actions such as:adding place,navigate through the app
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  EventList? eventsList;
  NotificationList? notificationList;
  UserService userService = UserService();
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _setGreeting();
  }

  void _setGreeting() {
    DateTime now = DateTime.now();
    if (now.hour < 12) {
      setState(() {
        _greeting = 'Good Morning';
      });
    } else if (now.hour < 18) {
      setState(() {
        _greeting = 'Good Afternoon';
      });
    } else {
      setState(() {
        _greeting = 'Good Evening';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    EventProvider eventProvider = Provider.of<EventProvider>(context);
    PlaceProvider placeProvider = Provider.of<PlaceProvider>(context);
    NotificationProvider notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: TourismColors.background,
          title: Row(
            children: [
              const Text(
                'Turathi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: TourismColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: TourismColors.surface,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 1,
                        horizontal: 20,
                      ),
                      hintText: 'Where to?',
                      hintStyle: TextStyle(color: TourismColors.textSecondary),
                      border: InputBorder.none,
                      suffixIcon: const Icon(Icons.search, color: TourismColors.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            FutureBuilder(
              future: notificationProvider.notificationList,
              builder: (context, snapshot) {
                var data = snapshot.data;
                if (data == null) {
                  return IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, color: TourismColors.textSecondary),
                    onPressed: () {
                      Navigator.of(context).pushNamed(notificationPage);
                    },
                  );
                }
                notificationList = data;
                bool hasUnread = notificationList!.notifications.any((element) => element.isRead == false);
                return IconButton(
                  icon: Icon(
                    hasUnread ? Icons.notifications_active : Icons.notifications_none_outlined,
                    color: hasUnread ? TourismColors.secondary : TourismColors.textSecondary,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(notificationPage);
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Curved image header with overlay
            Stack(
              children: [
                ClipPath(
                  clipper: CurvedHeaderClipper(),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/img_png/img_1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient overlay at the bottom for text readability
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 190,
                  child: ClipPath(
                    clipper: CurvedHeaderClipper(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Overlay greeting and search bar
                Positioned(
                  left: 24,
                  right: 24,
                  top: 40,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 8,
                              color: Colors.black54, // stronger shadow
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ready for your next adventure?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 8,
                              color: Colors.black54, // stronger shadow
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Featured Destinations',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
            // Places from Firebase
            SizedBox(
              height: 230,
              child: FutureBuilder<PlaceList>(
                future: placeProvider.placeList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.places.isEmpty) {
                    return const Center(child: Text('No Places Yet'));
                  }
                  final places = snapshot.data!.places;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      double cardWidth = constraints.maxWidth * 0.7;
                      double imageHeight = 130;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: places.length,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final place = places[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(placeDetailsRoute, arguments: place);
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              color: Colors.white,
                              child: SizedBox(
                                width: cardWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: place.images != null && place.images!.isNotEmpty
                                          ? Image.network(
                                              place.images![0],
                                              fit: BoxFit.cover,
                                              height: imageHeight,
                                              width: cardWidth,
                                            )
                                          : Container(
                                              height: imageHeight,
                                              width: cardWidth,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image, size: 60, color: Colors.white),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                      child: Text(
                                        place.title ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        place.address ?? '',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            place.like != null ? place.like.toString() : '0',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
            _buildServiceIcons(context),
            const SizedBox(height: 25),
            // Promotional banners (static images, you can update as needed)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/img_png/s2.png',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 65,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '30% OFF',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Luxury Hotels',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final url = Uri.parse('https://booking.kayak.com/');
                                  try {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Could not open browser.')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Book Now'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/img_png/s1.jpg',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 65,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '25% OFF',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Adventure Tours',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final url = Uri.parse('https://booking.kayak.com/');
                                  try {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Could not open browser.')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Book Now'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recommended Experiences',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
            // Events from Firebase
            SizedBox(
              height: 230,
              child: FutureBuilder<EventList>(
                future: eventProvider.eventList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.events.isEmpty) {
                    return const Center(child: Text('No Events Yet'));
                  }
                  final events = snapshot.data!.events;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(eventDetailsRoute, arguments: event);
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.white,
                          child: SizedBox(
                            width: 280,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: event.images != null && event.images!.isNotEmpty
                                      ? Image.network(
                                          event.images![0],
                                          fit: BoxFit.cover,
                                          height: 130,
                                          width: 280,
                                        )
                                      : Container(
                                          height: 130,
                                          width: 280,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image, size: 60, color: Colors.white),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: Text(
                                    event.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    event.address ?? '',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: Text(
                                    event.description ?? '',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIcons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _serviceIcon(context, Icons.location_on, 'Places', Colors.blue, () => Navigator.of(context).pushNamed(placesAdminRoute)),
            _serviceIcon(context, Icons.hotel, 'Hotels', Colors.blue, () async {
              final url = Uri.parse('https://booking.kayak.com/');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open browser.')),
                );
              }
            }),
            _serviceIcon(context, Icons.flight_takeoff, 'Flights', Colors.blue, () async {
              final url = Uri.parse('https://www.srilankan.com/en_uk/go?redirect=1#ibe');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open browser.')),
                );
              }
            }),
            _serviceIcon(context, Icons.car_rental, 'Rentals', Colors.blue, () {
              Navigator.of(context).pushNamed(carsRoute);
            }),
            _serviceIcon(context, Icons.person, 'Guides', Colors.blue, () {
              Navigator.of(context).pushNamed(guidesRoute);
            }),
            _serviceIcon(context, Icons.map, 'Map', Colors.blue, () async {
              final url = Uri.parse('https://www.google.com/maps');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open browser.')),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _serviceIcon(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, color: color, size: 35),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TourismColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width * 0.25, size.height,
      size.width * 0.5, size.height - 40,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 80,
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TourismColors {
  static const Color primary = Color(0xFF2196F3); // Vibrant Blue
  static const Color secondary = Color(0xFFFF9800); // Lively Orange
  static const Color accent = Color(0xFF43A047); // Fresh Green
  static const Color background = Color(0xFFF7FAFC); // Soft White
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color textPrimary = Color(0xFF0D223A); // Dark Blue
  static const Color textSecondary = Color(0xFF757575); // Grey
}
