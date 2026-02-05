import 'package:flutter/material.dart';
import 'package:thrivewithms/featuresScreens/Meals_screen.dart';
import 'package:thrivewithms/featuresScreens/Supplemetns_Scrreen.dart';
import 'package:thrivewithms/featuresScreens/SymptomLoggingScreen.dart';
import 'package:thrivewithms/featuresScreens/AssessmentScreen.dart';
import 'package:thrivewithms/featuresScreens/TreatmentScreen.dart';
import 'package:thrivewithms/screens/home_screen.dart';
import 'package:thrivewithms/screens/onBoardingScreen.dart';
import 'package:thrivewithms/screens/signup_screen.dart';
import 'package:thrivewithms/screens/login_screen.dart';
import 'package:thrivewithms/featuresScreens/exercises_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/onboarding',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      routes: {
        '/onboarding': (context) => const onBoardingScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/homescreen': (context) => const HomeScreen(),
        '/Assessmentscreen': (context) => const AssessmentScreen(),
        '/mealsscreen': (context) => const MealsScreen(),
        '/supplemetnsScrreen': (context) => const SupplementsScreen(),
        '/exercisescreen': (context) => const ExercisesScreen(),
        '/SymptomLoggingScreen': (context) => const SymptomLoggingScreen(),
        '/TreatmentScreen': (context) => const TreatmentScreen(),
      },
    );
  }
}
