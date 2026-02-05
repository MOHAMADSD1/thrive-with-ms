import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:thrivewithms/featuresScreens/SymptomLoggingScreen.dart';
import 'package:thrivewithms/featuresScreens/TreatmentScreen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _assessmentCards = [
    {
      'title': 'Symptoms',
      'icon': Icons.healing,
      'color': Colors.orange.shade600,
      'description': 'Track and monitor your symptoms over time',
      'screen': const SymptomLoggingScreen(),
    },
    {
      'title': 'MS Treatments',
      'icon': Icons.medication,
      'color': Colors.orange.shade600,
      'description': 'Log your treatments and medications',
      'screen': const TreatmentScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Assessments",
          style: TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: textNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.white.withOpacity(0.9),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 32),
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: _assessmentCards.length,
                    itemBuilder: (context, index) {
                      final card = _assessmentCards[index];

                      final slideAnimation = Tween<Offset>(
                        begin: const Offset(0.5, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            index * 0.2,
                            0.6 + index * 0.2,
                            curve: Curves.easeOutQuint,
                          ),
                        ),
                      );

                      final fadeAnimation = Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0.2 + index * 0.2,
                            0.7 + index * 0.1,
                            curve: Curves.easeOut,
                          ),
                        ),
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: SlideTransition(
                          position: slideAnimation,
                          child: FadeTransition(
                            opacity: fadeAnimation,
                            child: _buildAssessmentCard(context, card),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            textNavy,
            const Color(0xFF1B2B65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: textNavy.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assessment_rounded,
                  color: Colors.orange.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Track Your Progress",
                      style: TextStyle(
                        color: Colors.orange.shade500,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Monitor your MS journey",
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: textNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  color: Colors.orange.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Assessments",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textNavy,
                      ),
                    ),
                    Text(
                      "Keep track of your health",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
      ],
    );
  }

  Widget _buildAssessmentCard(BuildContext context, Map<String, dynamic> card) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, animation, __) {
                  return FadeTransition(
                    opacity: animation,
                    child: card['screen'],
                  );
                },
                transitionDuration: const Duration(milliseconds: 800),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.orange.shade50,
          highlightColor: Colors.orange.shade50.withOpacity(0.5),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: textNavy.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: textNavy.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      card['icon'],
                      color: Colors.orange.shade600,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          card['title'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card['description'],
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.orange.shade600,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
