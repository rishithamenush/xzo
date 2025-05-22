import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Todays Workout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              // Today's date
              Text(
                today,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 12),
              // Streak/Last Workout/Calories Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF181818),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statColumn('assets/images/img_png/blood.png', 'Week Streak', '5 days'),
                    _statColumn('assets/images/img_png/blood.png', 'Last Workout', '2d ago'),
                    _statColumn('assets/images/img_png/blood.png', 'Calories', '1,200'),
                  ],
                ),
              ),
              SizedBox(height: 18),
              // 2x2 Grid of Workout Types
              Row(
                children: [
                  Expanded(child: _workoutTypeCard('assets/images/img_png/workout.png', 'Strength')),
                  SizedBox(width: 12),
                  Expanded(child: _workoutTypeCard('assets/images/img_png/run.png', 'Cardio')),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _workoutTypeCard('assets/images/img_png/blood.png', 'HIIT')),
                  SizedBox(width: 12),
                  Expanded(child: _workoutTypeCard('assets/images/img_png/blood.png', 'Flexibility')),
                ],
              ),
              SizedBox(height: 18),
              // Recent Workouts
              Text('Recent Workouts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _recentWorkoutCard('Upper Body', '45 min', '320 cal')),
                  SizedBox(width: 12),
                  Expanded(child: _recentWorkoutCard('Cardio', '30 min', '280 cal')),
                ],
              ),
              Spacer(),
              // Start New Workout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF240006),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Start New Workout', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statColumn(String asset, String label, String value) {
    return Column(
      children: [
        Image.asset(asset, width: 28, height: 28, color: Color(0xFFFF2D2D)),
        SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 13)),
        SizedBox(height: 2),
        Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
      ],
    );
  }

  Widget _workoutTypeCard(String asset, String label) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(asset, width: 28, height: 28, color: Color(0xFFFF2D2D)),
            SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _recentWorkoutCard(String title, String duration, String cal) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 4),
          Text('$duration   $cal', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
} 