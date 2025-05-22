import 'package:flutter/material.dart';
import '../../../core/services/user_service.dart';
import '../../../core/models/user_model.dart';
import '../register/sign_up.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final UserService _userService = UserService();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _userService.getUsers().then((ul) => ul.users);
    });
  }

  Future<void> _navigateToSignUp() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SingUp(isAdminAdd: true)),
    );
    _refreshUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        backgroundColor: const Color(0xFF2C0000),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToSignUp,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C0000),
              Color(0xFF000000),
            ],
          ),
        ),
        child: FutureBuilder<List<UserModel>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}', style: TextStyle(color: Colors.white)));
            }
            final users = snapshot.data ?? [];
            debugPrint('Fetched users: \\${users.length}');
            if (users.isEmpty) {
              return const Center(child: Text('No members found.', style: TextStyle(color: Colors.white70)));
            }
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  color: Colors.white.withOpacity(0.08),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    title: Text(
                      user.name ?? '-',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reg#: \\${user.registrationNumber ?? '-'}', style: const TextStyle(color: Colors.white70)),
                        Text('Email: \\${user.email ?? '-'}', style: const TextStyle(color: Colors.white70)),
                        Text('Phone: \\${user.phone ?? '-'}', style: const TextStyle(color: Colors.white70)),
                        if (user.membershipType != null) Text('Membership: \\${user.membershipType}', style: const TextStyle(color: Colors.white70)),
                        if (user.joinDate != null) Text('Join: \\${user.joinDate?.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Colors.white70)),
                        if (user.expiryDate != null) Text('Expiry: \\${user.expiryDate?.toLocal().toString().split(' ')[0]}', style: const TextStyle(color: Colors.white70)),
                        if (user.role != null) Text('Role: \\${user.role}', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
} 