
import 'package:flutter/material.dart';
import 'package:echomind/constants/list.dart';

class SummarySearchDelegate extends SearchDelegate<String> {
  // called when user taps a suggestion
  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () => query = '',
    )
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, ''),
  );

  // called to show filtered results
  @override
  Widget buildResults(BuildContext context) {
    final results = SummaryData.summaries
        .where((s) => s['title']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final s = results[i];
        return ListTile(
          title: Text(s['title']!),
          subtitle: Text(s['preview']!),
          onTap: () => close(context, s['title']!),
        );
      },
    );
  }

  // called to show live suggestions
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = SummaryData.summaries
        .where((s) => s['title']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        final s = suggestions[i];
        return ListTile(
          title: Text(s['title']!),
          onTap: () {
            query = s['title']!;
            showResults(context);
          },
        );
      },
    );
  }
}
