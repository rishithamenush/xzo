import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:turathi/core/services/gym_service.dart';
import 'package:turathi/core/models/workout_progress_model.dart';
import 'package:turathi/core/models/workout_schedule_model.dart';
import 'package:turathi/core/models/trainer_model.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final GymService _gymService = GymService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<WorkoutScheduleModel> _schedules = [];
  List<WorkoutProgressModel> _progressRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No user logged in');
      // Fetch all schedules for this user
      _schedules = await _gymService.getMemberWorkoutSchedules(userId);
      // Fetch all progress records for all schedules
      List<WorkoutProgressModel> allProgress = [];
      for (final schedule in _schedules) {
        final progressList = await _gymService.getWorkoutProgressList(userId, schedule.id!);
        allProgress.addAll(progressList);
      }
      setState(() {
        _progressRecords = allProgress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading progress: $e'), backgroundColor: Colors.red),
      );
    }
  }

  int get totalCompleted => _progressRecords.where((p) => p.status == 'completed').length;

  List<WorkoutProgressModel> get _thisWeekProgress {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    return _progressRecords.where((p) =>
      p.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
      p.date.isBefore(endOfWeek.add(const Duration(days: 1))) &&
      p.status == 'completed'
    ).toList();
  }

  int get currentStreak {
    final completedDates = _progressRecords
      .where((p) => p.status == 'completed')
      .map((p) => DateUtils.dateOnly(p.date))
      .toSet();
    int streak = 0;
    DateTime day = DateUtils.dateOnly(DateTime.now());
    while (completedDates.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get bestStreak {
    final completedDates = _progressRecords
      .where((p) => p.status == 'completed')
      .map((p) => DateUtils.dateOnly(p.date))
      .toSet();
    int best = 0;
    for (final date in completedDates) {
      int streak = 1;
      DateTime prev = date.subtract(const Duration(days: 1));
      while (completedDates.contains(prev)) {
        streak++;
        prev = prev.subtract(const Duration(days: 1));
      }
      if (streak > best) best = streak;
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Progress',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF240006),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _topStat(totalCompleted.toString(), 'Workouts'),
                        _topStat(_thisWeekProgress.length.toString(), 'This Week'),
                        _topStat(currentStreak.toString(), 'Streak'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Weekly Activity
                  const Text('Weekly Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _weeklyBarChart(),
                  const SizedBox(height: 28),
                  // Streaks
                  Row(
                    children: [
                      Expanded(child: _streakCard('Current Streak', '${currentStreak} Days', Icons.local_fire_department)),
                      const SizedBox(width: 16),
                      Expanded(child: _streakCard('Best Streak', '${bestStreak} Days', Icons.emoji_events)),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Progress List
                  const Text('Recent Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...(_progressRecords.toList()
                      ..sort((a, b) => b.date.compareTo(a.date)))
                      .take(10)
                      .map((p) => _progressTile(p))
                      .toList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _topStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _weeklyBarChart() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final List<double> values = List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      final count = _progressRecords.where((p) =>
        p.status == 'completed' &&
        DateUtils.isSameDay(p.date, day)
      ).length;
      return count / 3.0; // Assume max 3 workouts per day for bar height
    });
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
                  duration: const Duration(milliseconds: 500),
                  height: (80 * values[i]).clamp(0, 80),
                  width: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B4FFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(days[i], style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _streakCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF240006),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFB71C1C), size: 22),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        ],
      ),
    );
  }

  Widget _progressTile(WorkoutProgressModel p) {
    return ListTile(
      leading: Icon(
        p.status == 'completed' ? Icons.check_circle : Icons.cancel,
        color: p.status == 'completed' ? Colors.green : Colors.red,
      ),
      title: Text(DateFormat('EEE, MMM d, yyyy').format(p.date), style: const TextStyle(color: Colors.white)),
      subtitle: Text(p.status, style: const TextStyle(color: Colors.white70)),
      trailing: p.notes != null && p.notes!.isNotEmpty
          ? Icon(Icons.sticky_note_2, color: Colors.yellow[800])
          : null,
    );
  }
} 