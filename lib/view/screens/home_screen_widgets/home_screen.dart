import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/core/models/notification_model.dart';
import 'package:turathi/view/view_layer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:turathi/core/services/gym_service.dart';
import 'package:intl/intl.dart';
import 'package:turathi/view/screens/schedule_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:turathi/core/models/workout_progress_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turathi/core/models/member_model.dart';

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

    // Motivational quotes (30 for each day of the month)
    final List<String> motivationQuotes = [
      "Push yourself, because no one else is going to do it for you.",
      "Success starts with self-discipline.",
      "The pain you feel today will be the strength you feel tomorrow.",
      "Don't limit your challenges. Challenge your limits.",
      "It never gets easier, you just get stronger.",
      "You don't have to be extreme, just consistent.",
      "Sweat is fat crying.",
      "The only bad workout is the one that didn't happen.",
      "Doubt kills more dreams than failure ever will.",
      "You are your only limit.",
      "Don't wish for a good body, work for it.",
      "No pain, no gain. Shut up and train.",
      "The body achieves what the mind believes.",
      "Wake up. Work out. Look hot. Kick ass.",
      "If it doesn't challenge you, it won't change you.",
      "Excuses don't burn calories.",
      "You don't get what you wish for. You get what you work for.",
      "Discipline is the bridge between goals and accomplishment.",
      "Don't stop when you're tired. Stop when you're done.",
      "The difference between try and triumph is a little umph.",
      "Strive for progress, not perfection.",
      "A little progress each day adds up to big results.",
      "It's going to be a journey. It's not a sprint to get in shape.",
      "You are much stronger than you think.",
      "Fall in love with taking care of yourself.",
      "The hardest lift of all is lifting your butt off the couch.",
      "Don't count the days, make the days count.",
      "Energy and persistence conquer all things.",
      "Suffer the pain of discipline or suffer the pain of regret.",
      "Your only limit is you."
    ];
    // Generate a unique quote index for each user each day
    String userKey = sharedUser.id ?? sharedUser.email ?? sharedUser.name ?? "user";
    int userHash = userKey.codeUnits.fold(0, (prev, c) => prev + c);
    final int quoteIndex = (userHash + DateTime.now().day) % motivationQuotes.length;
    final String todayQuote = motivationQuotes[quoteIndex];

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
            // Motivation Quote
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              decoration: BoxDecoration(
                color: Color(0xFF3A0D1F),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote, color: Colors.yellow[700], size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      todayQuote,
                      style: TextStyle(
                        color: Colors.yellow[100],
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
      onPressed: () async {
        if (label == "Start Workout") {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ScheduleScreen()),
          );
        } else if (label == "Attendance") {
          // Fetch attended dates
          final _auth = FirebaseAuth.instance;
          final _gymService = GymService();
          final userId = _auth.currentUser?.uid;
          Set<DateTime> attendedDates = {};
          if (userId != null) {
            final schedules = await _gymService.getMemberWorkoutSchedules(userId);
            for (final schedule in schedules) {
              final progressList = await _gymService.getWorkoutProgressList(userId, schedule.id!);
              for (final p in progressList) {
                if (p.status == 'completed') {
                  attendedDates.add(DateUtils.dateOnly(p.date));
                }
              }
            }
          }
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: const Color(0xFF240006),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Attendance Calendar',
                      style: TextStyle(
                        color: Colors.yellow[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 16),
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: DateTime.now(),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final isAttended = attendedDates.contains(DateUtils.dateOnly(day));
                          if (isAttended) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow[700],
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return null;
                        },
                        todayBuilder: (context, day, focusedDay) {
                          final isAttended = attendedDates.contains(DateUtils.dateOnly(day));
                          if (isAttended) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow[700],
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.yellow[700],
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        weekendTextStyle: TextStyle(color: Colors.red[200]),
                        defaultTextStyle: TextStyle(color: Colors.white),
                        outsideTextStyle: TextStyle(color: Colors.white24),
                      ),
                      headerStyle: HeaderStyle(
                        titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.yellow[700]),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.yellow[700]),
                        decoration: BoxDecoration(
                          color: Color(0xFF3A0D1F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekendStyle: TextStyle(color: Colors.red[200]),
                        weekdayStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Close', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (label == "DietPlans") {
          final _auth = FirebaseAuth.instance;
          final _gymService = GymService();
          final userId = _auth.currentUser?.uid;
          MemberModel? member;
          String? selectedPlan;
          if (userId != null) {
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
            if (userDoc.exists) {
              member = MemberModel.fromJson(userDoc.data()!);
              selectedPlan = member.dietPlan;
            }
          }
          final List<String> dietPlans = [
            'Balanced Diet',
            'Keto Diet',
            'Vegan Diet',
            'Vegetarian Diet',
            'Paleo Diet',
            'Mediterranean Diet',
            'Low-Carb Diet',
            'High-Protein Diet',
            'DASH Diet',
            'Intermittent Fasting',
            'Gluten-Free Diet',
            'Pescatarian Diet',
            'Raw Food Diet',
            'Zone Diet',
            'Flexitarian Diet',
            'Whole30 Diet',
            'Low-Fat Diet',
            'Diabetic Diet',
            'Anti-Inflammatory Diet',
            'Custom Plan',
          ];
          final Map<String, String> dietDescriptions = {
            'Balanced Diet': 'A diet that includes all food groups in the right proportions for optimal health.',
            'Keto Diet': 'A low-carb, high-fat diet that helps burn fat more effectively.',
            'Vegan Diet': 'A plant-based diet that excludes all animal products.',
            'Vegetarian Diet': 'A diet that excludes meat and fish but may include dairy and eggs.',
            'Paleo Diet': 'Focuses on foods presumed to be eaten by early humans: lean meats, fish, fruits, vegetables, nuts.',
            'Mediterranean Diet': 'Inspired by the eating habits of countries bordering the Mediterranean Sea. Rich in olive oil, fruits, vegetables, and fish.',
            'Low-Carb Diet': 'Limits carbohydrates, focusing on protein and fat-rich foods.',
            'High-Protein Diet': 'Emphasizes protein-rich foods to build muscle and aid weight loss.',
            'DASH Diet': 'Dietary Approaches to Stop Hypertension. Focuses on reducing sodium and eating nutrient-rich foods.',
            'Intermittent Fasting': 'Cycles between periods of fasting and eating. Popular for weight loss.',
            'Gluten-Free Diet': 'Excludes gluten, found in wheat, barley, and rye. Essential for people with celiac disease.',
            'Pescatarian Diet': 'A vegetarian diet that includes fish and seafood.',
            'Raw Food Diet': 'Consists mainly of raw and unprocessed foods.',
            'Zone Diet': 'Balances protein, carbs, and fat in a 30-40-30 ratio.',
            'Flexitarian Diet': 'Primarily vegetarian but occasionally includes meat or fish.',
            'Whole30 Diet': 'A 30-day diet that eliminates sugar, alcohol, grains, legumes, soy, and dairy.',
            'Low-Fat Diet': 'Limits fat intake, especially saturated fat.',
            'Diabetic Diet': 'Designed to help control blood sugar. Focuses on healthy carbs, fiber, and portion control.',
            'Anti-Inflammatory Diet': 'Focuses on foods that reduce inflammation, such as leafy greens, nuts, and berries.',
            'Custom Plan': 'A personalized plan tailored to your unique needs and preferences.',
          };
          final Map<String, List<String>> sampleMeals = {
            'Balanced Diet': ['Oatmeal with fruit', 'Grilled chicken salad', 'Brown rice with veggies'],
            'Keto Diet': ['Eggs and avocado', 'Grilled salmon with asparagus', 'Chicken with cheese'],
            'Vegan Diet': ['Tofu stir-fry', 'Lentil soup', 'Quinoa salad'],
            'Vegetarian Diet': ['Greek yogurt parfait', 'Vegetable curry', 'Egg salad sandwich'],
            'Paleo Diet': ['Baked sweet potato', 'Grilled steak with veggies', 'Fruit salad'],
            'Mediterranean Diet': ['Hummus and pita', 'Grilled fish with veggies', 'Greek salad'],
            'Low-Carb Diet': ['Omelette', 'Chicken Caesar salad', 'Zucchini noodles'],
            'High-Protein Diet': ['Protein shake', 'Turkey breast', 'Cottage cheese with fruit'],
            'DASH Diet': ['Oatmeal', 'Grilled chicken', 'Steamed broccoli'],
            'Intermittent Fasting': ['(Eat during window)', 'Salmon bowl', 'Veggie omelette'],
            'Gluten-Free Diet': ['Rice noodles', 'Grilled shrimp', 'Fruit smoothie'],
            'Pescatarian Diet': ['Tuna salad', 'Grilled tilapia', 'Vegetable soup'],
            'Raw Food Diet': ['Raw veggie wrap', 'Fruit bowl', 'Nuts and seeds'],
            'Zone Diet': ['Chicken breast', 'Brown rice', 'Steamed veggies'],
            'Flexitarian Diet': ['Veggie burger', 'Chicken stir-fry', 'Fruit parfait'],
            'Whole30 Diet': ['Egg muffins', 'Zucchini noodles', 'Grilled chicken'],
            'Low-Fat Diet': ['Steamed fish', 'Vegetable soup', 'Fruit salad'],
            'Diabetic Diet': ['Whole grain toast', 'Grilled chicken', 'Mixed greens'],
            'Anti-Inflammatory Diet': ['Berry smoothie', 'Salmon with spinach', 'Walnut salad'],
            'Custom Plan': ['Custom meal 1', 'Custom meal 2', 'Custom meal 3'],
          };
          await showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: const Color(0xFF240006),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Your Diet Plan',
                      style: TextStyle(
                        color: Colors.yellow[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 350,
                      child: ListView.separated(
                        itemCount: dietPlans.length,
                        separatorBuilder: (_, __) => Divider(color: Colors.white12, height: 1),
                        itemBuilder: (context, index) {
                          final plan = dietPlans[index];
                          final isSelected = plan == selectedPlan;
                          return ListTile(
                            title: Text(plan, style: TextStyle(color: isSelected ? Colors.yellow[700] : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            trailing: isSelected ? Icon(Icons.check_circle, color: Colors.yellow[700]) : null,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            tileColor: isSelected ? Colors.yellow[700]!.withOpacity(0.08) : Colors.transparent,
                            onTap: () async {
                              // Show details dialog
                              await showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: const Color(0xFF240006),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(plan, style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold, fontSize: 22)),
                                            ),
                                            if (isSelected)
                                              Icon(Icons.check_circle, color: Colors.yellow[700]),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Text(dietDescriptions[plan] ?? '', style: TextStyle(color: Colors.white70, fontSize: 15)),
                                        SizedBox(height: 16),
                                        Text('Sample Meals:', style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold, fontSize: 16)),
                                        ...?sampleMeals[plan]?.map((meal) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                                          child: Text('• $meal', style: TextStyle(color: Colors.white, fontSize: 14)),
                                        )),
                                        SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text('Back', style: TextStyle(color: Colors.white70)),
                                            ),
                                            SizedBox(width: 12),
                                            ElevatedButton(
                                              onPressed: isSelected || userId == null ? null : () async {
                                                await FirebaseFirestore.instance.collection('users').doc(userId).update({'dietPlan': plan});
                                                Navigator.pop(context); // Close details
                                                Navigator.pop(context); // Close list
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Diet plan updated to "$plan"'), backgroundColor: Colors.green),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.yellow[700],
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              child: Text(isSelected ? 'Selected' : 'Select this plan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
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
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Close', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (label == "Leaderboard") {
          // Show leaderboard popup
          await showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: const Color(0xFF240006),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leaderboard',
                      style: TextStyle(
                        color: Colors.yellow[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 350,
                      width: 320,
                      child: _leaderboard.isEmpty
                        ? Center(child: Text('No leaderboard data', style: TextStyle(color: Colors.white70)))
                        : ListView.separated(
                            itemCount: _leaderboard.length,
                            separatorBuilder: (_, __) => Divider(color: Colors.white12, height: 1),
                            itemBuilder: (context, index) {
                              final user = _leaderboard[index];
                              final rank = index + 1;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: rank == 1 ? Colors.amber : rank == 2 ? Colors.grey : rank == 3 ? Colors.brown : Colors.white24,
                                  child: Text('$rank', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(user['name'] ?? 'User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                trailing: Text('${user['points'] ?? 0} pts', style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold)),
                              );
                            },
                          ),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Close', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
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
