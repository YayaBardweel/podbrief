import 'package:echomind/pages/auth/auth_gate.dart';
import 'package:echomind/pages/auth/register_page.dart';
import 'package:echomind/pages/onboarding_page.dart';
import 'package:echomind/pages/root_page.dart'; // <-- Import RootPage
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

const Color kPrimaryColor = Color(0xFF5E35B1);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
      routes: {
        '/root': (ctx) => const RootPage(),
        // Add more named routes here if needed, e.g. register, onboarding, etc.
      },
      home: seenOnboarding
          ? const auth_gate()
          : const OnboardingPage(),
    );
  }
}
