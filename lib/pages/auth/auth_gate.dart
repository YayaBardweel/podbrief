import 'package:echomind/pages/auth/login_page.dart';
import 'package:echomind/pages/root_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class auth_gate extends StatefulWidget {
  const auth_gate({super.key});
  @override
  State<auth_gate> createState() => _auth_gateState();
}
class _auth_gateState extends State<auth_gate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // If the user is logged in, go to RootPage
            return  RootPage();
          } else {
            // If not logged in, show login page
            return login_page();
          }
        },
      ),
    );
  }
}