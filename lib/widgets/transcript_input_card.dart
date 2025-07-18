import 'package:flutter/material.dart';
import 'package:echomind/constants/colors.dart';

class TranscriptInputCard extends StatelessWidget {
  final VoidCallback onTap;

  const TranscriptInputCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        splashColor: kPrimaryColor.withOpacity(0.3), // Splash color for better UX
        highlightColor: kPrimaryColor.withOpacity(0.1), // Highlight color for feedback
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic, color: kPrimaryColor, size: 35), // Mic icon for recording
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    'Tap to start recording or paste your transcript',
                    style: TextStyle(
                      fontSize: 17,
                      color: kTextColorDark,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
