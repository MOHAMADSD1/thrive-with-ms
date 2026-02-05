import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thrivewithms/featuresScreens/Supplemetns_Scrreen.dart';
import 'package:thrivewithms/featuresScreens/exercises_screen.dart';
import 'package:thrivewithms/featuresScreens/Meals_screen.dart';
import 'package:thrivewithms/featuresScreens/AssessmentScreen.dart';
import 'package:thrivewithms/services/api_service.dart';
import 'package:thrivewithms/screens/calendar_screen.dart';
import 'package:thrivewithms/screens/profile_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String? firstname;
  final _storage = const FlutterSecureStorage();
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _featureCards = [
    {
      'title': 'Assessment',
      'icon': FontAwesomeIcons.notesMedical,
      'color': Colors.orange.shade600,
      'description':
          'Track your MS journey with comprehensive health assessments and monitoring.',
      'route': 'AssessmentScreen',
    },
    {
      'title': 'Meals',
      'icon': FontAwesomeIcons.utensils,
      'color': Colors.orange.shade600,
      'description':
          'Take control with every bite—explore foods to boost your MS health.',
      'route': 'MealsScreen',
    },
    {
      'title': 'Supplements',
      'icon': FontAwesomeIcons.pills,
      'color': Colors.orange.shade600,
      'description':
          'Stay informed about supplements that can support your MS journey.',
      'route': 'SupplementsScreen',
    },
    {
      'title': 'Exercise Videos',
      'icon': FontAwesomeIcons.dumbbell,
      'color': Colors.orange.shade600,
      'description':
          'Stay active and inspired—discover tailored exercises for your wellness!',
      'route': 'ExercisesScreen',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsername();
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

  Future<void> _fetchUsername() async {
    try {
      String? accessToken = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');
      String? userId = await _storage.read(key: "user_id");

      if (accessToken == null || refreshToken == null) {
        setState(() {
          firstname = 'Guest';
        });
        return;
      }
      try {
        final userData = await ApiService.fetchUserData(userId!);
        setState(() {
          firstname = userData['firstname'] ?? 'Guest';
        });
      } catch (e) {
        if (e.toString().contains('401')) {
          accessToken = await ApiService.refreshAccessToken(refreshToken);
          await _storage.write(key: 'access_token', value: accessToken);

          final userData = await ApiService.fetchUserData(userId!);
          setState(() {
            firstname = userData['firstname'] ?? 'Guest';
          });
        } else {
          rethrow;
        }
      }
    } catch (e) {
      print("Error reading from storage : $e");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange.shade100, width: 2),
                borderRadius: BorderRadius.circular(21),
              ),
              child: const CircleAvatar(
                backgroundImage: AssetImage("assets/men.png"),
                radius: 21,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $firstname",
                  style: const TextStyle(
                    color: textNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Welcome back",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
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
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 32),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    ...List.generate(_featureCards.length, (index) {
                      final card = _featureCards[index];

                      final slideAnimation = Tween<Offset>(
                        begin: const Offset(0.5, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            index * 0.15,
                            0.45 + index * 0.15,
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
                            0.15 + index * 0.15,
                            0.55 + index * 0.15,
                            curve: Curves.easeOut,
                          ),
                        ),
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SlideTransition(
                          position: slideAnimation,
                          child: FadeTransition(
                            opacity: fadeAnimation,
                            child: _buildFeatureCard(context, card),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange.shade600,
        unselectedItemColor: Colors.grey[500],
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home_rounded),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalendarScreen()),
                );
              },
              icon: const Icon(Icons.calendar_month_rounded),
            ),
            label: "Calendar",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen()),
                );
                // If we got back a new firstname, update it
                if (result != null) {
                  setState(() {
                    firstname = result;
                  });
                }
              },
              icon: const Icon(Icons.person_2_rounded),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                        Icons.favorite_rounded,
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
                            "Let's thrive today!",
                            style: TextStyle(
                              color: Colors.orange.shade500,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Your daily wellness journey",
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
                const SizedBox(height: 17),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_rounded,
                        color: Colors.orange.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Small steps make a big difference",
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  Icons.apps_rounded,
                  color: textNavy,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Features",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textNavy,
                      ),
                    ),
                    Text(
                      "Tools to support your journey",
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

  Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> card) {
    return Container(
      height: 130,
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
            switch (card['route']) {
              case 'AssessmentScreen':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AssessmentScreen()),
                );
                break;
              case 'MealsScreen':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MealsScreen()),
                );
                break;
              case 'SupplementsScreen':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SupplementsScreen()),
                );
                break;
              case 'ExercisesScreen':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExercisesScreen()),
                );
                break;
            }
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: textNavy.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: FaIcon(
                      card['icon'],
                      color: Colors.orange.shade600,
                      size: 32,
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textNavy,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          card['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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
