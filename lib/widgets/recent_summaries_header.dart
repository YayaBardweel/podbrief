import 'package:flutter/material.dart';
import 'package:echomind/constants/colors.dart';

class RecentSummariesHeader extends StatelessWidget {
  const RecentSummariesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Recent Summaries',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kTextColorDark,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
