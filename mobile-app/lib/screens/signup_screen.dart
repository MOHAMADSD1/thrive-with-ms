import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thrivewithms/widgets/customtextfileds.dart';
import 'package:thrivewithms/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = FlutterSecureStorage();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textNavy),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 0),
                  Image.asset(
                    'assets/images/ms_logo.jpg',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    "Create an account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Create an account, so you can explore all the tools you need to thrive with MS.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: textNavy,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  customtextfield(
                    hint: "First Name",
                    controller: _firstnameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your first name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  customtextfield(
                    hint: "Last Name",
                    controller: _lastnameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your last name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  customtextfield(
                    hint: "Email",
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your email";
                      }
                      final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  customtextfield(
                    hint: "Password",
                    controller: _passwordController,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters!';
                      }
                      if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                        return 'Password must contain at least one uppercase letter';
                      }
                      if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                        return 'Password must contain at least one number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  if (_isLoading)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    )
                  else
                    SizedBox(
                      width: 200,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final firstname = _firstnameController.text.trim();
      final lastname = _lastnameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final http.Response response = await ApiService.registerUser(
          firstname: firstname,
          lastname: lastname,
          email: email,
          password: password,
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 201) {
          final http.Response loginResponse = await ApiService.loginUser(
            email: email,
            password: password,
          );

          final loginData = jsonDecode(loginResponse.body);

          if (loginResponse.statusCode == 200) {
            final accessToken = loginData['tokens']['access']['token'];
            final refreshToken = loginData['tokens']['refresh']['token'];
            final userId = loginData['user']['_id'];
            await _storage.write(key: 'access_token', value: accessToken);
            await _storage.write(key: "refresh_token", value: refreshToken);
            await _storage.write(key: "user_id", value: userId);
          }

          Navigator.pushReplacementNamed(context, '/homescreen');
        } else {
          setState(() {
            _errorMessage = responseData['message'] ?? 'Registration failed';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Registration failed. Please try again.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
