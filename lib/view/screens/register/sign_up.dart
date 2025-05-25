import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/view/view_layer.dart';
import 'dart:developer';
import 'package:intl/intl.dart';

//page to create a new account in the app
class SingUp extends StatefulWidget {
  final bool isAdminAdd;
  const SingUp({super.key, this.isAdminAdd = false});

  @override
  State<SingUp> createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  late SignUpController signUpController;
  UserService _service = UserService();
  bool _obscurePassword = true;
  GetCurrentLocation currentLocation = GetCurrentLocation();
  DateTime? _selectedJoinDate;
  DateTime? _selectedExpiryDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    signUpController = SignUpController();
    // Set default dates
    _selectedJoinDate = DateTime.now();
    _selectedExpiryDate = DateTime.now().add(const Duration(days: 365)); // Default 1 year membership
    signUpController.joinDate.text = _dateFormat.format(_selectedJoinDate!);
    signUpController.expiryDate.text = _dateFormat.format(_selectedExpiryDate!);
  }

  @override
  void dispose() {
    signUpController.firstName.dispose();
    signUpController.email.dispose();
    signUpController.phone.dispose();
    signUpController.password.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isJoinDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isJoinDate ? _selectedJoinDate ?? DateTime.now() : _selectedExpiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2C0000), // Maroon color for header
              onPrimary: Colors.white, // Text color on header
              onSurface: Colors.black, // Text color on calendar
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isJoinDate) {
          _selectedJoinDate = picked;
          signUpController.joinDate.text = _dateFormat.format(picked);
        } else {
          _selectedExpiryDate = picked;
          signUpController.expiryDate.text = _dateFormat.format(picked);
        }
      });
    }
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
              'assets/images/img_png/_login.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.5,
            ),
          ),

          // Foreground Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                      Image.asset('assets/images/img_png/logo.png', height: 220),
                      const SizedBox(height: 20),
                      Text(
                        widget.isAdminAdd ? 'ADD NEW MEMBER' : 'CREATE ACCOUNT',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C0000),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Registration Number Field
                      _buildTextField(
                        controller: signUpController.registrationNumber,
                        label: 'Registration Number',
                        icon: Icons.confirmation_number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Registration Number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      _buildTextField(
                        controller: signUpController.email,
                        label: 'Email Address',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      _buildTextField(
                        controller: signUpController.firstName,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      _buildTextField(
                        controller: signUpController.phone,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Phone number is required';
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Membership Type Field
                      _buildTextField(
                        controller: signUpController.membershipType,
                        label: 'Membership Type',
                        icon: Icons.card_membership,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Membership type is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Join Date Field
                      _buildDateField(
                        controller: signUpController.joinDate,
                        label: 'Join Date',
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context, true),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Join date is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Expiry Date Field
                      _buildDateField(
                        controller: signUpController.expiryDate,
                        label: 'Expiry Date',
                        icon: Icons.event_busy,
                        onTap: () => _selectDate(context, false),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Expiry date is required';
                          }
                          if (_selectedJoinDate != null && _selectedExpiryDate != null) {
                            if (_selectedExpiryDate!.isBefore(_selectedJoinDate!)) {
                              return 'Expiry date must be after join date';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      _buildTextField(
                        controller: signUpController.password,
                        label: 'Password',
                        icon: Icons.lock,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (signUpController.formKey.currentState!.validate()) {
                              try {
                                log("Starting member addition process...");
                                Position? p = await currentLocation.getCurrentLocation();
                                
                                final user = UserModel(
                                  name: signUpController.firstName.text,
                                  email: signUpController.email.text,
                                  phone: signUpController.phone.text,
                                  longitude: p?.longitude,
                                  latitude: p?.latitude,
                                  registrationNumber: signUpController.registrationNumber.text,
                                  membershipType: signUpController.membershipType.text,
                                  joinDate: _selectedJoinDate,
                                  expiryDate: _selectedExpiryDate,
                                );
                                
                                log("User model created with email: ${user.email}");
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Adding member...'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                                
                                String result = await _service.addUser(user, signUpController.password.text);
                                // After registration, set the user.id to the Firebase Auth UID
                                if (result.length == 28) { // Firebase UID length
                                  user.id = result;
                                }
                                log("Add user result: $result");
                                
                                if (result == "Done") {
                                  log("User created successfully");
                                  if (mounted) {
                                    if (widget.isAdminAdd) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Member added successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    } else {
                                      Navigator.of(context).pushReplacementNamed(signIn);
                                    }
                                  }
                                } else {
                                  log("Error creating user: $result");
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                log("Unexpected error during sign up: $e");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "An unexpected error occurred: $e",
                                        textAlign: TextAlign.center,
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C0000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            widget.isAdminAdd ? 'Add Member' : 'SIGN UP',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (!widget.isAdminAdd) ...[
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
                                  color: Color(0xFF2C0000),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF2C0000)),
        prefixIcon: Icon(icon, color: const Color(0xFF2C0000)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C0000)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C0000), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF2C0000)),
        prefixIcon: Icon(icon, color: const Color(0xFF2C0000)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C0000)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C0000), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  void _signUp(BuildContext context, UserModel user, String password) async {
    String str = await _service.addUser(user, password);

    if (str == "Done") {
      print("User is successfully created");
      if (mounted) {
        if (widget.isAdminAdd) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Member added successfully!')),
          );
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacementNamed(signIn);
        }
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
  TextEditingController _registrationNumber = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _membershipType = TextEditingController();
  TextEditingController _joinDate = TextEditingController();
  TextEditingController _expiryDate = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController get registrationNumber => _registrationNumber;
  TextEditingController get email => _email;
  TextEditingController get firstName => _firstName;
  TextEditingController get password => _password;
  TextEditingController get phone => _phone;
  TextEditingController get membershipType => _membershipType;
  TextEditingController get joinDate => _joinDate;
  TextEditingController get expiryDate => _expiryDate;
  GlobalKey<FormState> get formKey => _formKey;

  set formKey(value) => _formKey = value;
  set registrationNumber(TextEditingController value) => _registrationNumber = value;
  set email(TextEditingController value) => _email = value;
  set firstName(TextEditingController value) => _firstName = value;
  set password(TextEditingController value) => _password = value;
  set phone(TextEditingController value) => _phone = value;
  set membershipType(TextEditingController value) => _membershipType = value;
  set joinDate(TextEditingController value) => _joinDate = value;
  set expiryDate(TextEditingController value) => _expiryDate = value;
}