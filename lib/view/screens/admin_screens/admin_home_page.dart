import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/services/user_service.dart';
import '../../view_layer.dart';
import 'members_screen.dart';

//Admin homepage provides actions,data view.
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final List<_AdminAction> actions = [
    _AdminAction(
      label: 'Members',
      icon: FontAwesomeIcons.users,
      color: Color(0xFFB71C1C),
      route: '/admin/members',
    ),
    _AdminAction(
      label: 'Trainers',
      icon: FontAwesomeIcons.dumbbell,
      color: Color(0xFF388E3C),
      route: '/admin/trainers',
    ),
    _AdminAction(
      label: 'Classes',
      icon: FontAwesomeIcons.calendarAlt,
      color: Color(0xFF1976D2),
      route: '/admin/classes',
    ),
    _AdminAction(
      label: 'Attendance',
      icon: FontAwesomeIcons.clipboardCheck,
      color: Color(0xFFF9A825),
      route: '/admin/attendance',
    ),
    _AdminAction(
      label: 'Payments',
      icon: FontAwesomeIcons.moneyCheckDollar,
      color: Color(0xFF8E24AA),
      route: '/admin/payments',
    ),
    _AdminAction(
      label: 'Announcements',
      icon: FontAwesomeIcons.bullhorn,
      color: Color(0xFF43A047),
      route: '/admin/announcements',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Gym Admin Dashboard',
          style: ThemeManager.textStyle.copyWith(
            fontSize: LayoutManager.widthNHeight0(context, 1) * 0.05,
            fontWeight: FontWeight.bold,
            fontFamily: ThemeManager.fontFamily,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 8, color: Colors.black45, offset: Offset(0,2))],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(LayoutManager.widthNHeight0(context, 1) * 0.01),
          child: Container(),
        ),
      ),
      body: Stack(
        children: [
          // Background image with gradient overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/img_png/admin_.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2C0000).withOpacity(0.85),
                    Color(0xFF000000).withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(LayoutManager.widthNHeight0(context, 1) * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Welcome, Gym Admin!',
                    style: ThemeManager.textStyle.copyWith(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black45, offset: Offset(0,2))],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your gym members, trainers, classes, and more.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: ThemeManager.fontFamily,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black26, offset: Offset(0,1))],
                    ),
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 1.1,
                      children: [
                        ...actions.map((action) => _AdminActionCard(action: action, onTap: () {
                          if (action.label == 'Members') {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => MembersScreen()),
                            );
                          } else {
                            Navigator.of(context).pushNamed(action.route);
                          }
                        })),
                        _SignOutCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  _AdminAction({required this.label, required this.icon, required this.color, required this.route});
}

class _AdminActionCard extends StatelessWidget {
  final _AdminAction action;
  final VoidCallback? onTap;
  const _AdminActionCard({required this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pushNamed(action.route),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white.withOpacity(0.18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
            gradient: LinearGradient(
              colors: [action.color.withOpacity(0.25), Colors.white.withOpacity(0.10)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: action.color.withOpacity(0.10),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: action.color.withOpacity(0.25),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(18),
                child: FaIcon(action.icon, color: Colors.white, size: 36),
              ),
              SizedBox(height: 18),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: ThemeManager.fontFamily,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black26, offset: Offset(0,1))],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await UserService().signOut();
        Navigator.of(context).pushReplacementNamed(signIn);
      },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white.withOpacity(0.18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
            gradient: LinearGradient(
              colors: [Color(0xFFD32F2F).withOpacity(0.25), Colors.white.withOpacity(0.10)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFD32F2F).withOpacity(0.10),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFD32F2F).withOpacity(0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD32F2F).withOpacity(0.25),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(18),
                child: Icon(Icons.logout, color: Colors.white, size: 36),
              ),
              SizedBox(height: 18),
              Text(
                'Sign Out',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: ThemeManager.fontFamily,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black26, offset: Offset(0,1))],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


