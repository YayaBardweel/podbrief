import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class page1 extends StatefulWidget {
  const page1({super.key});

  @override
  State<page1> createState() => _page1State();
}

class _page1State extends State<page1> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                "assets/lottie/welcom .json"), // Used absolute path
          ),
          Text("Welcome to PodBrief",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 20, // Added some spacing between text and Lottie animation
          ),
          Text('Turn podcasts into instant summaries using AI.')
        ],
        ),
      ),
    );

  }
}