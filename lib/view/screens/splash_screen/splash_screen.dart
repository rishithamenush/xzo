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
          Image.asset('assets/images/img_png/splash.jpg', fit: BoxFit.cover),
          Container(color: const Color.fromARGB(139, 0, 0, 0)),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                Image.asset('assets/images/img_png/logo.png', width: 70, height: 70),
                const SizedBox(height: 20),
                const Text(
                  'SriWay',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Welcome to Sri Lanka',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Sri Lankan Travel Partner',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                  ),
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
