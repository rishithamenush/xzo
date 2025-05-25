import 'package:flutter/material.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/view/view_layer.dart';
import 'package:intl/intl.dart';


//page that provide actions on his profile and actions in the app
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar, Name, Badge, Edit
              SizedBox(height: 16),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage('assets/images/img_png/userProfile.png'),
                ),
              ),
              SizedBox(height: 16),
              Text(
                (sharedUser.name != null && sharedUser.name!.trim().isNotEmpty) ? sharedUser.name! : 'User',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF7A0019),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Premium Member',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangeInfo()),
                  );
                  if (result == true) setState(() {}); // Refresh after edit
                },
                child: Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.blue[300], fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 24),
              // Info Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard('Membership Type', sharedUser.membershipType ?? 'N/A'),
                  _infoCard('Reg. Number', sharedUser.registrationNumber ?? 'N/A'),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard('Phone', sharedUser.phone ?? 'N/A'),
                  _infoCard('Email', sharedUser.email ?? 'N/A'),
                ],
              ),
              SizedBox(height: 24),
              // Membership Period
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Membership Period', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard('Join Date', sharedUser.joinDate != null ? DateFormat('yyyy-MM-dd').format(sharedUser.joinDate!) : 'N/A'),
                  _infoCard('Expiry Date', sharedUser.expiryDate != null ? DateFormat('yyyy-MM-dd').format(sharedUser.expiryDate!) : 'N/A'),
                ],
              ),
              SizedBox(height: 24),
              // Recent Activity
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              SizedBox(height: 12),
              _activityTile(Icons.fitness_center, 'Upper Body Workout', 'Today', '45 min', '320 cal'),
              SizedBox(height: 10),
              _activityTile(Icons.directions_run, 'Cardio Session', 'Yesterday', '30 min', '280 cal'),
              SizedBox(height: 10),
              _activityTile(Icons.favorite, 'HIIT Training', '2 days ago', '25 min', '240 cal'),
              SizedBox(height: 24),
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await userService.signOut();
                    Navigator.of(context).pushReplacementNamed(signIn);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB71C1C),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Logout', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Color(0xFF181818),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            SizedBox(height: 6),
            Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _statBar(String label, double value, String valueLabel) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              Text(valueLabel, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7A0019)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityTile(IconData icon, String title, String day, String duration, String cal) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF7A0019),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(day, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                    SizedBox(width: 12),
                    Text(duration, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                    SizedBox(width: 12),
                    Text(cal, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
