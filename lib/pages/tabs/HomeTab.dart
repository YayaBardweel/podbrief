import 'package:flutter/material.dart';
import 'package:echomind/widgets/welcome_header.dart';
import 'package:echomind/widgets/transcript_input_card.dart';
import 'package:echomind/widgets/recent_summaries_header.dart';
import 'package:echomind/widgets/summary_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:echomind/mod/summary_model.dart';

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

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Center(child: Text("User not authenticated"));
    }

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

        // Fetch and display recent summaries from Firestore
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('summaries')
              .where('userId', isEqualTo: _userId) // Filter by user ID
              .orderBy('createdAt', descending: true) // Order by createdAt
              .limit(5) // Limit to the most recent 5 summaries
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final recentSummaries = snapshot.data?.docs ?? [];

            if (recentSummaries.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No recent summaries available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return Column(
              children: recentSummaries.map((doc) {
                final summaryData = doc.data() as Map<String, dynamic>;
                final summary = Summary.fromMap(summaryData);
                return SummaryCard(summary: summary); // Display each summary
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
