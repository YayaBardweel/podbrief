// lib/main.dart (Revised - IMPORTANT!)
import 'package:echomind/pages/auth/auth_gate.dart';
import 'package:echomind/pages/onboarding_page.dart';
import 'package:echomind/pages/root_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:echomind/providers/user_provider.dart';
import 'package:echomind/providers/root_page_controller.dart';

const Color kPrimaryColor = Color(0xFF5E35B1);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    MultiProvider( // MultiProvider wraps the entire app, making providers available to MainApp and its children
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => RootPageController()),
      ],
      child: MyAppWrapper(seenOnboarding: seenOnboarding), // <-- New wrapper widget
    ),
  );
}

// Create a new stateless widget to act as a wrapper for your MaterialApp
// This ensures that the MaterialApp itself, and thus its home/routes,
// are built with a context that *already* has the providers available.
class MyAppWrapper extends StatelessWidget {
  final bool seenOnboarding;
  const MyAppWrapper({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    // Now, the StreamBuilder is inside a widget that is a child of MultiProvider.
    // So, any widget returned by this StreamBuilder's builder (like AuthGate or RootPage)
    // will have access to the providers in its BuildContext.
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
        // Add more named routes here if needed.
        // Make sure any named routes that directly navigate to a screen needing providers
        // are also created within a context that has the providers.
      },
      home: seenOnboarding
          ? const AuthDecisionPage() // <-- Use a dedicated widget for authentication decision
          : const OnboardingPage(),
    );
  }
}

// This new widget will contain the StreamBuilder logic
class AuthDecisionPage extends StatelessWidget {
  const AuthDecisionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            // User is not logged in, show AuthGate (which should lead to login/register)
            return const auth_gate();
          } else {
            // User is logged in, show RootPage
            // You can also consider loading user data here via UserProvider.of(context).fetchUserData()
            // but UserProvider's constructor already listens to auth state changes.
            return const RootPage();
          }
        }
        // While waiting for auth state, show a loading spinner or splash screen
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}