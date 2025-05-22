import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Progress',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
              decoration: BoxDecoration(
                color: Color(0xFF240006),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _topStat('18', 'Workouts'),
                  _topStat('24.5', 'Hours'),
                  _topStat('12.4k', 'Calories'),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Recent Achievements
            Text('Recent Achievements', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _achievement('assets/images/img_png/workout.png', '10 Workouts'),
                _achievement('assets/images/img_png/run.png', '5K Run'),
                _achievement('assets/images/img_png/achivement.png', 'Gold Medal'),
                _achievement('assets/images/img_png/blood.png', 'Streak Master'),
              ],
            ),
            SizedBox(height: 28),
            // Weekly Activity
            Text('Weekly Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            _weeklyBarChart(),
            SizedBox(height: 28),
            // Streaks
            Row(
              children: [
                Expanded(child: _streakCard('Current Streak', '12 Days', Icons.local_fire_department)),
                SizedBox(width: 16),
                Expanded(child: _streakCard('Best Streak', '21 Days', Icons.emoji_events)),
              ],
            ),
            SizedBox(height: 28),
            // Monthly Goals
            Text('Monthly Goals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _goalCircle('assets/images/img_png/iconheart.png', 0.75, '75%', 'Workouts'),
                _goalCircle('assets/images/img_png/iconworkout.png', 0.6, '60%', 'Weight Training'),
                _goalCircle('assets/images/img_png/iconrun.png', 0.45, '45%', 'Cardio'),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _topStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
        SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _achievement(String asset, String label) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Color(0xFF181818),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(asset, width: 28, height: 28, fit: BoxFit.contain),
          ),
        ),
        SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _weeklyBarChart() {
    // Mock data for 7 days
    final List<double> values = [0.4, 0.6, 0.3, 0.8, 0.5, 0.15, 0.55];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  height: 80 * values[i],
                  width: 18,
                  decoration: BoxDecoration(
                    color: Color(0xFF5B4FFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(height: 8),
                Text(days[i], style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _streakCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFF240006),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFFB71C1C), size: 22),
              SizedBox(width: 8),
              Text(label, style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          SizedBox(height: 10),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        ],
      ),
    );
  }

  Widget _goalCircle(String asset, double percent, String percentLabel, String label) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 4,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
              ),
            ),
            Image.asset(asset, width: 34, height: 24, fit: BoxFit.contain),
          ],
        ),
        SizedBox(height: 6),
        Text(percentLabel, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
} 