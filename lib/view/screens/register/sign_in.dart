import 'package:flutter/material.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/view/view_layer.dart';


//page to sign in the user with his email and password
class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  
  TextController textController = TextController();
  UserService userService = UserService();
  bool _obscurePassword = true;

  @override
  void dispose() {
    textController.controllerEmail.dispose();
    textController.controllerPass.dispose();
    super.dispose();
  }

  bool? isChecked = false;
  bool passToggle = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key("log in"),
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: -40,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/img_png/splash.jpg',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.5,
            ),
          ),

          // Foreground Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.62,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: textController.formField,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Image.asset('assets/images/img_png/img.png', height: 120),
                      const SizedBox(height: 2),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'LOGIN PAGE',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Email Field
                      TextFormField(
                        controller: textController.controllerEmail,
                        decoration: InputDecoration(
                          hintText: 'Enter Email',
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Email";
                          }
                          bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.1#$&'*+-/=?^_ {|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value);
                          if (!emailValid) {
                            return "Enter valid Email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Password Field
                      TextFormField(
                        controller: textController.controllerPass,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
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

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (textController.formField.currentState!.validate()) {
                              bool signInSuccess = await userService.signIn(
                                textController.controllerEmail.text,
                                textController.controllerPass.text,
                              );

                              if (signInSuccess) {
                                sharedUser = (await userService.getUserByEmail(
                                    textController.controllerEmail.text))!;
                                Navigator.of(context)
                                    .pushReplacementNamed(bottomNavRoute);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: const Text(
                                          "An error has occurred. Don't have an account?"),
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
                                textController.controllerEmail.clear();
                                textController.controllerPass.clear();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Forgot Password
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Create Account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.black87),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(signUp);
                            },
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Admin Login Option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Are you admin?",
                            style: TextStyle(color: Colors.black87),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(signInAdminRoute);
                            },
                            child: const Text(
                              "Start",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Image.asset(
                                'assets/images/img_png/google.png',
                                height: 15,
                              ),
                              label: const Text(
                                'Google',
                                style: TextStyle(color: Colors.black87),
                              ),
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Image.asset(
                                'assets/images/img_png/fb.png',
                                height: 15,
                              ),
                              label: const Text(
                                'Facebook',
                                style: TextStyle(color: Colors.black87),
                              ),
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
class TextController{

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPass = TextEditingController();
  GlobalKey<FormState>_formField = GlobalKey<FormState>();


  // ignore: unnecessary_getters_setters
  TextEditingController get controllerEmail => _controllerEmail;

  // ignore: unnecessary_getters_setters
  TextEditingController get controllerPass => _controllerPass;

  GlobalKey<FormState> get formField => _formField;

  set formField(value) {
    _formField = value;
  }

  set controllerPass(TextEditingController value) {
    _controllerPass = value;
  }

  set controllerEmail(TextEditingController value) {
    _controllerEmail = value;
  }
}