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

    // Mock user data
    final String userName = "Mad";
    final String userAvatar = "assets/images/img_png/user_avatar.png"; // Replace with your avatar asset

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting and avatar
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, $userName",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Let's check your activity",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(userAvatar),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Today's Progress Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color(0xFF240006),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Today's Progress", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            SizedBox(height: 4),
                            Text("5 of 7 daily goals completed", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 54,
                            height: 54,
                            child: CircularProgressIndicator(
                              value: 0.7,
                              strokeWidth: 6,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
                            ),
                          ),
                          Text("70%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _progressStat(Icons.directions_walk, "Steps", "8,245 / 10,000"),
                      _progressStat(Icons.local_fire_department, "Calories", "450 kcal"),
                      _progressStat(Icons.access_time, "Active", "45 mins"),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),

            // Gym Capacity Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color(0xFF240006),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Gym Capacity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Spacer(),
                      Text("65%", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 0.65,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text("Best time to visit now", style: TextStyle(color: Colors.green, fontSize: 13)),
                ],
              ),
            ),
            SizedBox(height: 18),

            // Top Performers
            Text("This Week's Top Performers", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            _topPerformer(1, "Sarah Kim", "assets/images/img_png/sarah.png", 3240),
            _topPerformer(2, "Mike Chen", "assets/images/img_png/mike.png", 2980),
            _topPerformer(3, "Lisa Wang", "assets/images/img_png/lisa.png", 2540),
            SizedBox(height: 18),

            // 2x2 Grid of Action Buttons
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color(0xFF240006),
                borderRadius: BorderRadius.circular(18),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 1.7,
                children: [
                  _actionButton(Icons.fitness_center, "Start Workout"),
                  _actionButton(Icons.event_available, "Attendance"),
                  _actionButton(Icons.restaurant_menu, "DietPlans"),
                  _actionButton(Icons.emoji_events, "Leaderboard"),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _progressStat(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 6),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 13)),
          SizedBox(height: 2),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _topPerformer(int rank, String name, String avatar, int points) {
    Color medalColor;
    switch (rank) {
      case 1:
        medalColor = Colors.amber;
        break;
      case 2:
        medalColor = Colors.grey;
        break;
      case 3:
        medalColor = Colors.brown;
        break;
      default:
        medalColor = Colors.white;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage(avatar),
          ),
          SizedBox(width: 10),
          Text(
            "$rank.",
            style: TextStyle(
              color: medalColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Text(
            "$points pts",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    String asset;
    Color cardColor;
    switch (label) {
      case "Start Workout":
        asset = "assets/images/img_png/workout.png";
        cardColor = Color(0xFF3A0D1F); // deep maroon
        break;
      case "Attendance":
        asset = "assets/images/img_png/iconattendance.png";
        cardColor = Color(0xFF3A0D1F); // dark brown
        break;
      case "DietPlan":
        asset = "assets/images/img_png/diet.png";
        cardColor = Color(0xFF3A0D1F); // dark red
        break;
      case "Leaderboard":
        asset = "assets/images/img_png/achivement.png";
        cardColor = Color(0xFF3A0D1F); // dark purple
        break;
      default:
        asset = "assets/images/img_png/icondiet.png";
        cardColor = Color(0xFF3A0D1F);
    }
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            asset,
            width: 32,
            height: 32,
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
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
