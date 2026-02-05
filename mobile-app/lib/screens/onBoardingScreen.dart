import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:thrivewithms/screens/login_screen.dart';
import 'package:thrivewithms/screens/signup_screen.dart';

class onBoardingScreen extends StatelessWidget {
  const onBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          Container(
            height: 520,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Image.asset(
                "assets/illustration.jpg",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    children: [
                      Text(
                        "Live Stronger with MS",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Thrive with MS guides, supports, and uplifts you every step of the way",
                        style: TextStyle(
                          fontSize: 16,
                          color: textNavy,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            children: const [
                              TextSpan(
                                text: "Sign up",
                                style: TextStyle(
                                  color: textNavy,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
