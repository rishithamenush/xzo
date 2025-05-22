import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../core/data_layer.dart';
import '../../view_layer.dart';
import 'admin_sign_up_screen.dart';

//Admin Sigin Page by ID and Password
class AdminSignIn extends StatefulWidget {
  const AdminSignIn({super.key});

  @override
  State<AdminSignIn> createState() => _AdminSignInState();
}

class _AdminSignInState extends State<AdminSignIn> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscurePassword = true;
  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    AdminService service = AdminService();
    return Scaffold(
      key: const Key("admin_sign_in"),
      body: Stack(
        children: [
          // Full background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/img_png/_login.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2C0000), // Deep maroon
                    Color(0xFF000000), // Black
                  ],
                ),
              ),
            ),
          ),
          // Foreground Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC2C0000),
                    Color(0xCC000000),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/img_png/logo.png', height: 120),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ADMIN LOGIN',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Admin Email Field (visible)
                      TextFormField(
                        controller: _idController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter Admin Email',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.email, color: Colors.white),
                          filled: true,
                          fillColor: Colors.transparent,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Admin Email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      TextFormField(
                        controller: _passController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Password";
                          } else if (value.length < 7) {
                            return "Password length should be more than 7 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (key.currentState!.validate()) {
                              bool t = await service.signIn(
                                  _idController.text, _passController.text);
                              log(t.toString());
                              if (t) {
                                AdminCheck = true;
                                Navigator.of(context)
                                    .pushReplacementNamed(homeAdminRoute);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: const Text(
                                          "Invalid admin credentials"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB71C1C), // Bold maroon
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'SIGN IN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Create Admin Account Button
                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 45,
                      //   child: OutlinedButton(
                      //     onPressed: () {
                      //       Navigator.of(context).push(
                      //         MaterialPageRoute(
                      //           builder: (context) => AdminSignUpScreen(),
                      //         ),
                      //       );
                      //     },
                      //     style: OutlinedButton.styleFrom(
                      //       side: const BorderSide(color: Colors.white),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //     ),
                      //     child: const Text(
                      //       'Create Admin Account',
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 20),

                      // Back to User Mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Back to User Mode?",
                            style: TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(signIn);
                            },
                            child: const Text(
                              'Yes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
