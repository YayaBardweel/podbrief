import 'package:echomind/pages/auth/auth_gate.dart';
import 'package:echomind/pages/auth/register_page.dart';
import 'package:echomind/pages/onboarding_page.dart';
import 'package:echomind/pages/home_page.dart';        // 👈 import your HomePage
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

// Primary Color
const Color kPrimaryColor = Color(0xFF5E35B1);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check onboarding flag
  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(MainApp(seenOnboarding: seenOnboarding));
}

class MainApp extends StatelessWidget {
  final bool seenOnboarding;
  const MainApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PodBrief',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          primary: kPrimaryColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),

      // 🔗 Named routes
      routes: {
        '/home': (context) => const HomePage(),
        '/register': (context) => const RegisterPage()// 👈 now you can pushReplacementNamed('/home')
      },

      // Starting screen
      home: seenOnboarding ? const auth_gate() : const OnboardingPage(),
    );
  }
}
