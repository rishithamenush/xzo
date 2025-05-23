// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/view/view_layer.dart';

//welcome page ,first page in the app
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4)); // Splash duration
    if (mounted) {
      try {
        if (FirebaseAuth.instance.currentUser == null) {
          log("&&&");
          Navigator.of(context).pushReplacementNamed(signIn);
        } else {
          sharedUser = (await userService.getUserByEmail(FirebaseAuth.instance.currentUser!.email!))!;
          print(FirebaseAuth.instance.currentUser);
          Navigator.of(context).pushReplacementNamed(bottomNavRoute);
        }
      } catch (e) {
        print("Error $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Splash image as background
          Image.asset(
            'assets/images/img_png/splash.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Maroon-black gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC2C0000), // Maroon with opacity
                  Color(0xCC000000), // Black with opacity
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, child) {
                     return Opacity(
                        opacity: value,
                        child: Image.asset('assets/images/img_png/logo_.png', width: 350, height: 350),
                     );
                  },
                ),
                const SizedBox(height: 20),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, child) {
                     return Opacity(
                        opacity: value,
                     );
                  },
                ),
                const SizedBox(height: 15),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, child) {
                     return Opacity(
                        opacity: value,
                        child: Column(
                          children: [
                          ],
                        ),
                     );
                  },
                ),
                const SizedBox(height: 40),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, child) {
                     return Opacity(
                        opacity: value,
                        child: CircularProgressIndicator(
                           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB71C1C)),
                           strokeWidth: 4.0,
                        ),
                     );
                  },
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
