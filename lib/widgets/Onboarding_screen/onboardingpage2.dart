import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class page2 extends StatefulWidget {
  const page2({super.key});

  @override
  State<page2> createState() => _page2State();
}

class _page2State extends State<page2> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      // Changed background color for better visibility
      child: Center( // Centered the content
        child: Column( // Used Column to stack elements vertically
          mainAxisAlignment: MainAxisAlignment.center, // Center items vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
          children: [
            SizedBox(
              height: 300, // Adjusted height for better visual balance
              width: 300,  // Adjusted width for better visual balance
              child: Lottie.asset(
                  "assets/lottie/Save Time & Energy.json"), // Used absolute path
            ),
            Text("Save Time & Energy",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 20, // Added some spacing between text and Lottie animation
            ),
            Text('No need to listen for hours — extract key points in seconds')
          ],
        ),
      ),
    );;
  }
}
