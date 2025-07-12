import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class page3 extends StatefulWidget {
  const page3({super.key});

  @override
  State<page3> createState() => _page3State();
}

class _page3State extends State<page3> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      child: Center( // Centered the content
        child: Column( // Used Column to stack elements vertically
          mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
          children: [
            SizedBox(
              height: 300, // Adjusted height for better visual balance
              width: 300,  // Adjusted width for better visual balance
              child: Lottie.asset(
                  "assets/lottie/Smart. Fast. Yours.json"), // Used absolute path
            ),
            Text("Smart. Fast. Yours.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 20, // Added some spacing between text and Lottie animation
            ),
            Text('Save, share, and learn from any podcast, fast.')
          ],
        ),
      ),
    );;
  }
}
