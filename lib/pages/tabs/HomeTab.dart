import 'package:flutter/material.dart';
import 'package:echomind/widgets/welcome_header.dart';
import 'package:echomind/widgets/transcript_input_card.dart';
import 'package:echomind/widgets/recent_summaries_header.dart';
import 'package:echomind/widgets/summary_card.dart';
import 'package:echomind/constants/list.dart';

class HomeTab extends StatelessWidget {
  final String username;
  final bool isLoading;

  const HomeTab({
    Key? key,
    required this.username,
    required this.isLoading,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // We use a plain ListView here, because the AppBar is above us in RootPage
    return ListView(
      padding: const EdgeInsets.only(top: 100), // to clear the SliverAppBar
      children: [
        WelcomeHeader(
          username: username,
          isLoading: isLoading,
          onAddTranscript: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Add Transcript clicked!')));
          },
        ),
        TranscriptInputCard(
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Tap to input/paste transcript!')));
          },
        ),
        const RecentSummariesHeader(),
        ...SummaryData.summaries
            .map((s) => SummaryCard(summary: s))
            .toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}
