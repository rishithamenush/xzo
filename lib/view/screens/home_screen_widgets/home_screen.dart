import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/core/models/notification_model.dart';
import 'package:turathi/view/view_layer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:turathi/core/services/gym_service.dart';
import 'package:turathi/core/models/workout_progress_model.dart';
import 'package:intl/intl.dart';

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

  final GymService _gymService = GymService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _todayCompleted = 0;
  int _todayPoints = 0;
  int _todayGoal = 3; // You can set this as needed
  double _todayPercent = 0.0;
  List<Map<String, dynamic>> _leaderboard = [];
  bool _loadingProgress = true;
  int _todaySteps = 0;
  int _todayCalories = 0;
  int _todayActiveMinutes = 0;
  double _gymCapacityPercent = 0.0;
  int _gymCapacityCount = 0;
  int _maxCapacity = 30; // Set your gym's max capacity here

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _loadProgressData();
    _loadLeaderboard();
    _loadGymCapacity();
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

  Future<void> _loadProgressData() async {
    setState(() => _loadingProgress = true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;
      // Fetch all schedules
      final schedules = await _gymService.getMemberWorkoutSchedules(userId);
      // Fetch all progress for today
      int completed = 0;
      int totalSteps = 0;
      int totalCalories = 0;
      int totalActiveMinutes = 0;
      for (final schedule in schedules) {
        final progressList = await _gymService.getWorkoutProgressList(userId, schedule.id!);
        final completedToday = progressList.where((p) =>
          p.status == 'completed' && DateUtils.isSameDay(p.date, DateTime.now())).toList();
        completed += completedToday.length;
        for (final p in completedToday) {
          final duration = schedule.endTime.difference(schedule.startTime).inMinutes;
          totalActiveMinutes += duration;
          // Estimate steps and calories (customize as needed)
          totalSteps += (duration * 70); // e.g., 70 steps per minute
          totalCalories += (duration * 6); // e.g., 6 kcal per minute
        }
      }
      final points = await _gymService.getUserPoints(userId);
      setState(() {
        _todayCompleted = completed;
        _todayPoints = completed * 10;
        _todayPercent = _todayGoal > 0 ? (completed / _todayGoal).clamp(0, 1) : 0.0;
        _todaySteps = totalSteps;
        _todayCalories = totalCalories;
        _todayActiveMinutes = totalActiveMinutes;
        _loadingProgress = false;
      });
    } catch (e) {
      setState(() => _loadingProgress = false);
    }
  }

  Future<void> _loadLeaderboard() async {
    final leaderboard = await _gymService.getWeeklyLeaderboard();
    setState(() {
      _leaderboard = leaderboard.take(3).toList();
    });
  }

  Future<void> _loadGymCapacity() async {
    try {
      final members = await _gymService.getMembers();
      int count = 0;
      final now = DateTime.now();
      final todayName = DateFormat('EEEE').format(now);
      for (final member in members) {
        final schedules = await _gymService.getMemberWorkoutSchedules(member.id!);
        for (final schedule in schedules) {
          if (schedule.isActive && schedule.daysOfWeek.contains(todayName)) {
            final start = DateTime(now.year, now.month, now.day, schedule.startTime.hour, schedule.startTime.minute);
            final end = DateTime(now.year, now.month, now.day, schedule.endTime.hour, schedule.endTime.minute);
            if (now.isAfter(start) && now.isBefore(end)) {
              count++;
              break; // Only count each member once
            }
          }
        }
      }
      setState(() {
        _gymCapacityCount = count;
        _gymCapacityPercent = (_maxCapacity > 0) ? (count / _maxCapacity).clamp(0, 1) : 0.0;
      });
    } catch (e) {
      setState(() {
        _gymCapacityCount = 0;
        _gymCapacityPercent = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    EventProvider eventProvider = Provider.of<EventProvider>(context);
    PlaceProvider placeProvider = Provider.of<PlaceProvider>(context);
    NotificationProvider notificationProvider = Provider.of<NotificationProvider>(context);

    // Mock user data
    final String userName = (sharedUser.name != null && sharedUser.name!.trim().isNotEmpty) ? sharedUser.name! : 'User';
    final String userAvatar = "assets/images/img_png/userprof.png"; // Replace with your avatar asset

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
                      SizedBox(height: 44),
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
              child: _loadingProgress
                  ? Center(child: CircularProgressIndicator(color: Colors.yellow))
                  : Column(
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
                                  Text("$_todayCompleted of $_todayGoal daily goals completed", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  SizedBox(height: 4),
                                  Text("Points earned today: $_todayPoints", style: TextStyle(color: Colors.yellow[700], fontSize: 14, fontWeight: FontWeight.bold)),
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
                                    value: _todayPercent,
                                    strokeWidth: 6,
                                    backgroundColor: Colors.white12,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
                                  ),
                                ),
                                Text("${(_todayPercent * 100).round()}%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 18),
                        // Stats row (optional, can be replaced with real stats if available)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _progressStat(Icons.directions_walk, "Steps", "${_todaySteps.toString()}"),
                            _progressStat(Icons.local_fire_department, "Calories", "${_todayCalories.toString()} kcal"),
                            _progressStat(Icons.access_time, "Active", "${_todayActiveMinutes.toString()} mins"),
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
                      Text("${(_gymCapacityPercent * 100).round()}%", style: TextStyle(color: _gymCapacityPercent < 0.8 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _gymCapacityPercent,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(_gymCapacityPercent < 0.8 ? Colors.green : Colors.red),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(_gymCapacityPercent < 0.8 ? "Best time to visit now" : "Gym is busy now", style: TextStyle(color: _gymCapacityPercent < 0.8 ? Colors.green : Colors.red, fontSize: 13)),
                  SizedBox(height: 4),
                  Text("$_gymCapacityCount / $_maxCapacity members scheduled now", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            SizedBox(height: 18),

            // Top Performers
            Text("This Week's Top Performers", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            ..._leaderboard.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final user = entry.value;
              return _topPerformer(rank, user['name'] ?? 'User', "assets/images/img_png/user$rank.png", user['points'] ?? 0);
            }).toList(),
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
