import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:thrivewithms/screens/signup_screen.dart';
import 'package:thrivewithms/screens/forgot_password_screen.dart';
import 'package:thrivewithms/services/api_service.dart';
import 'package:thrivewithms/widgets/customtextfileds.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/ms_logo.jpg',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                Text(
                  "Login here",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Welcome back you've been missed",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: textNavy,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                customtextfield(
                  hint: "Email",
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
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
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  )
                else
                  SizedBox(
                    width: 200,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Sign in",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                  ),
                  child: Text(
                    "Create new account",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: textNavy,
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
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    try {
      final http.Response response = await ApiService.loginUser(
        email: email,
        password: password,
      );

      debugPrint('Login Response Status: ${response.statusCode}');
      debugPrint('Login Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final accessToken = responseData['tokens']["access"]['token'];
        final refreshToken = responseData['tokens']['refresh']['token'];
        final userId = responseData['user']['_id'];
        await _storage.write(key: 'access_token', value: accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);
        await _storage.write(key: "user_id", value: userId);

        Navigator.pushReplacementNamed(context, '/homescreen');
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Login failed. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
