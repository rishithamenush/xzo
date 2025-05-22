import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/view/view_layer.dart';

//page to create a new account in the app
class SingUp extends StatefulWidget {
  const SingUp({super.key});

  @override
  State<SingUp> createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  late SignUpController signUpController;
  UserService _service = UserService();
  bool _obscurePassword = true;
  GetCurrentLocation currentLocation = GetCurrentLocation();

  @override
  void initState() {
    super.initState();
    signUpController = SignUpController();
  }

  @override
  void dispose() {
    signUpController.firstName.dispose();
    signUpController.email.dispose();
    signUpController.phone.dispose();
    signUpController.password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key("Turathi title"),
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
              height: MediaQuery.of(context).size.height * 0.65,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: signUpController.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/img_png/img.png', height: 120),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      TextFormField(
                        controller: signUpController.firstName,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintText: 'Enter Name',
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Your Name must not be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: signUpController.email,
                        keyboardType: TextInputType.emailAddress,
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
                            return 'Email must not be empty';
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

                      // Phone Field
                      TextFormField(
                        controller: signUpController.phone,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter Phone',
                          prefixIcon: const Icon(Icons.phone),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Phone must not be empty';
                          }
                          bool phoneExp = RegExp(r'^\d{10}$').hasMatch(value);
                          if (!phoneExp) {
                            return 'Phone number is not valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Password Field
                      TextFormField(
                        controller: signUpController.password,
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
                            return 'Password must not be empty';
                          }
                          if (value.length < 7) {
                            return "Password length should be more than 7 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (signUpController.formKey.currentState!.validate()) {
                              Position? p = await currentLocation.getCurrentLocation();
                              final user = UserModel(
                                name: signUpController.firstName.text,
                                email: signUpController.email.text,
                                phone: signUpController.phone.text,
                                longitude: p?.longitude,
                                latitude: p?.latitude,
                              );
                              _signUp(context, user, signUpController.password.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.black87),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(signIn);
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
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

  void _signUp(BuildContext context, UserModel user, String password) async {
    String str = await _service.addUser(user, password);

    if (str == "Done") {
      print("User is successfully created");
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(signIn);
      }
    } else {
      print("Error occurred during sign up");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              str,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}

class SignUpController {
  TextEditingController _email = TextEditingController();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _secondName = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _phone = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController get email => _email;
  TextEditingController get firstName => _firstName;
  TextEditingController get secondName => _secondName;
  TextEditingController get password => _password;
  TextEditingController get phone => _phone;
  GlobalKey<FormState> get formKey => _formKey;

  set formKey(value) => _formKey = value;
  set phone(TextEditingController value) => _phone = value;
  set password(TextEditingController value) => _password = value;
  set secondName(TextEditingController value) => _secondName = value;
  set firstName(TextEditingController value) => _firstName = value;
  set email(TextEditingController value) => _email = value;
}