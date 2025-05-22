import 'package:flutter/material.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/view/view_layer.dart';


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
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image with Gradient
                  ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.darken,
                    child: Image.asset(
                      'assets/images/img_png/splash.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Profile Content
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: ThemeManager.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Welcome Text
                        Text(
                          "Hi ${sharedUser.name}".toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: ThemeManager.fontFamily,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Welcome to SriWay",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontFamily: ThemeManager.fontFamily,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile Options
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[50]!,
                    Colors.grey[100]!,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Personal Details Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1A237E), // Deep Blue
                              Color(0xFF283593), // Indigo
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildProfileOption(
                              icon: Icons.person_outline,
                              title: 'Personal Details',
                              onTap: () => Navigator.of(context).pushNamed(personalDetilsScreen),
                            ),
                            Divider(height: 1, color: Colors.white.withOpacity(0.2)),
                            _buildProfileOption(
                              icon: Icons.edit_note,
                              title: 'Change Info',
                              onTap: () => Navigator.of(context).pushNamed(changeInfo),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Places and Expert Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Color(0xFFE8EAF6), // Light Indigo
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildProfileOption(
                              icon: Icons.place_outlined,
                              title: 'View Added Places',
                              iconColor: Color(0xFF1A237E), // Deep Blue
                              textColor: Color(0xFF1A237E), // Deep Blue
                              onTap: () => Navigator.of(context).pushNamed(addedPlacesRoute),
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                            _buildProfileOption(
                              icon: Icons.star_outline,
                              title: 'Become an Expert',
                              iconColor: Color(0xFF1A237E), // Deep Blue
                              textColor: Color(0xFF1A237E), // Deep Blue
                              onTap: () => Navigator.of(context).pushNamed(requestToBeExpertRoute),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // About and Sign Out Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Color(0xFFE8EAF6), // Light Indigo
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildProfileOption(
                              icon: Icons.info_outline,
                              title: 'About Us',
                              iconColor: Color(0xFF1A237E), // Deep Blue
                              textColor: Color(0xFF1A237E), // Deep Blue
                              onTap: () => Navigator.of(context).pushNamed(aboutUsScreen),
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                            _buildProfileOption(
                              icon: Icons.logout,
                              title: 'Sign Out',
                              iconColor: Color(0xFFD32F2F), // Red
                              textColor: Color(0xFFD32F2F), // Red
                              onTap: () async {
                                await userService.signOut();
                                Navigator.of(context).pushReplacementNamed(signIn);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor ?? Colors.white,
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.white,
                fontFamily: ThemeManager.fontFamily,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: textColor?.withOpacity(0.5) ?? Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
