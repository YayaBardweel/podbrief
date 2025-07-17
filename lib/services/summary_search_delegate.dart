import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SummarySearchDelegate extends SearchDelegate<String> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user ID
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

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
    if (_userId == null) {
      return Center(
        child: Text("User not authenticated"),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('summaries')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .where('transcript', isGreaterThanOrEqualTo: query)
          .where('transcript', isLessThanOrEqualTo: query + '\uf8ff')
// Range query for title
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final results = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (_, i) {
            final summary = results[i].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(summary['title'] ?? 'No Title'),
              subtitle: Text(summary['summaryText'] ?? 'No Summary Available'),
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
    if (_userId == null) {
      return Center(
        child: Text("User not authenticated"),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('summaries')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .where('transcript', isGreaterThanOrEqualTo: query)
          .where('transcript', isLessThanOrEqualTo: query + '\uf8ff')
      // Range query for title
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final suggestions = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (_, i) {
            final summary = suggestions[i].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(summary['title'] ?? 'No Title'),
              onTap: () {
                query = summary['title'] ?? '';
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}
