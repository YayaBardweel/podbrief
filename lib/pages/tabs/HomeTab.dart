import 'package:flutter/material.dart';
import 'package:echomind/widgets/welcome_header.dart';
import 'package:echomind/widgets/transcript_input_card.dart';
import 'package:echomind/widgets/recent_summaries_header.dart';
import 'package:echomind/widgets/summary_card.dart';
import 'package:echomind/constants/list.dart'; // Ensure your data file is correctly imported
import 'package:echomind/mod/summary_model.dart'; // Ensure Summary model is imported for correct type mapping

class HomeTab extends StatelessWidget {
  final String username;
  final bool isLoading;
  final VoidCallback? onNavigateToCreate;

  const HomeTab({
    Key? key,
    required this.username,
    required this.isLoading,
    this.onNavigateToCreate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 100), // To clear SliverAppBar space
      children: [
        // Welcome Header with user info and action
        WelcomeHeader(
          username: username,
          isLoading: isLoading,
          onAddTranscript: onNavigateToCreate ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add Transcript clicked!')),
            );
          },
        ),
        // Input Card for transcripts
        TranscriptInputCard(
          onTap: onNavigateToCreate ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tap to input/paste transcript!')),
            );
          },
        ),
        // Recent Summaries header
        const RecentSummariesHeader(),

        // Displaying summaries if available, otherwise show "No summaries available"
        if (SummaryData.summaries.isNotEmpty)
          ...SummaryData.summaries.map((summaryData) {
            // Convert each map entry to a Summary object
            final summary = Summary.fromMap(summaryData);
            return SummaryCard(summary: summary); // Pass the correct type to SummaryCard
          }).toList()
        else
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'No summaries available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
