import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SummarySearchDelegate extends SearchDelegate<String> {
  // Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Get the current user ID
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

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
    if (userId == null) {
      return const Center(
        child: Text("User not authenticated"),
      );
    }

    // Return empty results if query is empty
    if (query.isEmpty) {
      return const Center(
        child: Text("Enter a search term"),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('summaries')
          .where('userId', isEqualTo: userId) // Filter by user
          .orderBy('createdAt', descending: true) // Use existing index
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];

        // Filter results locally based on query
        final results = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final transcript = (data['transcript'] ?? '').toString().toLowerCase();
          final summaryText = (data['summaryText'] ?? '').toString().toLowerCase();
          final searchQuery = query.toLowerCase();

          return title.contains(searchQuery) ||
              transcript.contains(searchQuery) ||
              summaryText.contains(searchQuery);
        }).toList();

        if (results.isEmpty) {
          return const Center(
            child: Text("No results found"),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final summary = results[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(summary['title'] ?? 'No Title'),
              subtitle: Text(
                summary['summaryText'] ?? 'No Summary Available',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => close(context, summary['title'] ?? ''),
            );
          },
        );
      },
    );
  }

  // called to show live suggestions
  @override
  Widget buildSuggestions(BuildContext context) {
    if (userId == null) {
      return const Center(
        child: Text("User not authenticated"),
      );
    }

    // Return empty suggestions if query is empty
    if (query.isEmpty) {
      return const Center(
        child: Text("Start typing to see suggestions"),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('summaries')
          .where('userId', isEqualTo: userId) // Filter by user
          .orderBy('createdAt', descending: true) // Use existing index
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];

        // Filter suggestions locally based on query
        final suggestions = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final searchQuery = query.toLowerCase();

          return title.contains(searchQuery);
        }).toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final summary = suggestions[index].data() as Map<String, dynamic>;
            final title = summary['title'] ?? 'No Title';

            return ListTile(
              title: Text(title),
              leading: const Icon(Icons.history),
              onTap: () {
                query = title;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}