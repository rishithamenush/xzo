import 'package:flutter/material.dart';
import 'package:turathi/core/data_layer.dart';
import 'package:turathi/view/view_layer.dart';
import 'package:turathi/core/services/gym_service.dart';
import 'package:turathi/core/models/member_model.dart';
import 'package:intl/intl.dart';

//page to change user info
class ChangeInfo extends StatefulWidget {
  const ChangeInfo({Key? key});

  @override
  State<ChangeInfo> createState() => _ChangeInfoState();
}

class _ChangeInfoState extends State<ChangeInfo> {
  String name = "", emailAddress = "", phoneNu = "";
  final GymService _gymService = GymService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    name = sharedUser.name ?? '';
    emailAddress = sharedUser.email ?? '';
    phoneNu = sharedUser.phone ?? '';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final updatedMember = MemberModel(
        id: sharedUser.id,
        name: name,
        email: emailAddress,
        phone: phoneNu,
      );
      await _gymService.updateMember(updatedMember);
      // Optionally update sharedUser here if needed
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Return to profile screen
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ThemeManager.background,
        title: Text(
          'Change Info',
          style: ThemeManager.textStyle.copyWith(
            fontSize: LayoutManager.widthNHeight0(context, 1) * 0.05,
            fontWeight: FontWeight.bold,
            fontFamily: ThemeManager.fontFamily,
            color: ThemeManager.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize:
              Size.fromHeight(LayoutManager.widthNHeight0(context, 1) * 0.01),
          child: Divider(
            height: LayoutManager.widthNHeight0(context, 1) * 0.01,
            color: Colors.grey[300],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Center(
              child: SizedBox(
                width: LayoutManager.widthNHeight0(context, 1) * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 1, color: Colors.grey[300]),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: ThemeManager.fontFamily,
                        ),
                      ),
                    ),
                    TextFormField(
                      onChanged: (value) => setState(() => name = value),
                      initialValue: name,
                      validator: (value) => value!.isEmpty ? 'Name must not be empty' : null,
                      decoration: InputDecoration(
                        counterText: "",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ThemeManager.primary,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ThemeManager.primary,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        isDense: true,
                        hintText: 'Enter your name',
                      ),
                    ),
                    SizedBox(
                      height: LayoutManager.widthNHeight0(context, 1) * 0.05,
                    ),
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: ThemeManager.fontFamily,
                      ),
                    ),
                    TextFormField(
                      onChanged: (value) => setState(() => emailAddress = value),
                      initialValue: emailAddress,
                      validator: (value) => value!.isEmpty ? 'Email must not be empty' : null,
                      decoration: InputDecoration(
                        counterText: "",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ThemeManager.primary,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ThemeManager.primary,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        isDense: true,
                        hintText: 'Enter your email',
                      ),
                    ),
                    SizedBox(
                      height: LayoutManager.widthNHeight0(context, 1) * 0.05,
                    ),
                    Text(
                      'Phone',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: ThemeManager.fontFamily,
                      ),
                    ),
                    TextFormField(
                      onChanged: (value) => setState(() => phoneNu = value),
                      initialValue: phoneNu,
                      validator: (value) => value!.isEmpty ? 'Phone must not be empty' : null,
                      decoration: InputDecoration(
                        counterText: "",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ThemeManager.primary,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ThemeManager.primary,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                        ),
                        isDense: true,
                        hintText: 'Enter your phone number',
                      ),
                    ),
                    SizedBox(
                      height: LayoutManager.widthNHeight0(context, 1) * 0.085,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeManager.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
