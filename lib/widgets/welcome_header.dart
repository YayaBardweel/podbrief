import 'package:flutter/material.dart';
import 'package:echomind/constants/colors.dart';

class WelcomeHeader extends StatelessWidget {
  final String username;
  final bool isLoading;
  final VoidCallback onAddTranscript;

  const WelcomeHeader({
    super.key,
    required this.username,
    required this.isLoading,
    required this.onAddTranscript,
  });

  @override
  Widget build(BuildContext context) {
    // Handle null or empty username gracefully
    final displayUsername = (username.isNotEmpty) ? username : 'User';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kPrimaryColor.withOpacity(0.9),
              kAccentColor.withOpacity(0.8)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conditional greeting message based on isLoading
            Text(
              isLoading ? 'Loading your profile...' : 'Good Morning, $displayUsername!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: kTextColorLight,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            // Description text
            Text(
              'Summarize your podcasts in seconds.',
              style: TextStyle(
                fontSize: 16,
                color: kTextColorLight.withOpacity(0.8),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            // Add Transcript button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onAddTranscript,
                icon: const Icon(Icons.add, color: kPrimaryColor),
                label: const Text(
                  'Add Transcript',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: kPrimaryColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
