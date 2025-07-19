import 'package:flutter/material.dart';
import 'package:echomind/mod/summary_model.dart'; // Make sure to import the correct model

class FullSummaryPage extends StatelessWidget {
  final Summary summary;

  const FullSummaryPage({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a modern color scheme
    final Color primaryColor = Colors.deepPurple; // A modern, rich primary color
    final Color accentColor = Colors.deepPurpleAccent; // A complementary accent
    final Color backgroundColor = Colors.grey[50]!; // Light background for content
    final Color textColor = Colors.grey[800]!; // Darker text for readability
    final Color lightTextColor = Colors.grey[600]!; // Lighter text for secondary info

    return Scaffold(
      backgroundColor: backgroundColor, // Set scaffold background
      appBar: AppBar(
        title: Text(
          summary.title,
          style: TextStyle(
            color: Colors.white, // App bar title in white for contrast
            fontWeight: FontWeight.bold, // Make title bold
          ),
        ),
        backgroundColor: primaryColor, // Use the defined primary color
        elevation: 4, // Add a subtle shadow to the app bar
        iconTheme: IconThemeData(color: Colors.white), // White back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Date Card
              Card(
                elevation: 2, // Subtle shadow for the card
                margin: const EdgeInsets.only(bottom: 16.0), // Space below the card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today, // Calendar icon
                        color: accentColor, // Accent color for the icon
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Summarized on: ${summary.createdAt.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: 14,
                          color: lightTextColor, // Lighter text for metadata
                          fontWeight: FontWeight.w500, // Slightly bolder
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Full Summary Text Card
              Card(
                elevation: 4, // More pronounced shadow for the main content
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0), // More padding inside the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary Details', // A clear heading for the summary text
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor, // Heading in primary color
                        ),
                      ),
                      const Divider(height: 20, thickness: 1), // A subtle divider
                      Text(
                        summary.summaryText, // Full summary text
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5, // Increase line height for better readability
                          color: textColor, // Use defined text color
                        ),
                      ),
                      const SizedBox(height: 20), // Space at the bottom of the card
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.lightbulb_outline, // A subtle icon at the bottom
                          color: lightTextColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}