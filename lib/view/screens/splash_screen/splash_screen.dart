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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                 colors: [ Color(0xff1a1a1a), Color(0xff000000) ],
              ),
            ),
          ),
          Opacity(
            opacity: 0.2,
            child: Image.asset('assets/images/img_png/splash.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
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
                        child: Image.asset('assets/images/img_png/logo.png', width: 170, height: 170),
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
                        child: const Text(
                          'XZO',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
                            const Text(
                              'Welcome to XZO Fitness',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Your Personal Fitness Companion',
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
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
                           valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
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
