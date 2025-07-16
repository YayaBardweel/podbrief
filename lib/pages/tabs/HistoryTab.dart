// lib/pages/history_tab.dart (Updated with Better Auth Handling)
import 'package:echomind/mod/summary_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:echomind/constants/colors.dart';
import 'package:echomind/widgets/summary_card.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  bool _isLoading = false;

  // Ensure user is authenticated (sign in anonymously if needed)
  Future<User?> _ensureUserAuthenticated() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      try {
        // Sign in anonymously
        UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
        user = userCredential.user;
        print('Signed in anonymously for history: ${user?.uid}');
      } catch (e) {
        print('Failed to sign in anonymously: $e');
        return null;
      }
    }

    return user;
  }

  @override
  void initState() {
    super.initState();
    // Ensure user is authenticated when the tab loads
    _ensureUserAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          User? user = authSnapshot.data;

          // If no user, try to authenticate
          if (user == null) {
            return FutureBuilder<User?>(
              future: _ensureUserAuthenticated(),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Authenticating...'),
                      ],
                    ),
                  );
                }

                if (futureSnapshot.hasError || futureSnapshot.data == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Authentication failed',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _ensureUserAuthenticated();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                user = futureSnapshot.data;
                return _buildHistoryView(user!);
              },
            );
          }

          return _buildHistoryView(user);
        },
      ),

      // Floating "Clear History" action
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : () => _clearHistory(),
        backgroundColor: _isLoading ? Colors.grey : Colors.redAccent,
        icon: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.delete_outline),
        label: Text(_isLoading ? 'Clearing...' : 'Clear All'),
      ),
    );
  }

  Widget _buildHistoryView(User user) {
    final uid = user.uid;

    return StreamBuilder<QuerySnapshot>(
      // Query the top-level 'summaries' collection and filter by user ID
      // Note: Removed orderBy to avoid needing a composite index
      stream: FirebaseFirestore.instance
          .collection('summaries')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading summaries',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: ${snap.error}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Force rebuild to retry
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final docs = snap.data?.docs ?? [];

        // Sort documents by createdAt in memory (since we removed orderBy from query)
        docs.sort((a, b) {
          try {
            final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;

            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;

            return bTime.compareTo(aTime); // Descending order (newest first)
          } catch (e) {
            return 0; // If sorting fails, maintain original order
          }
        });

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No summaries yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a summary to see it here.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          itemCount: docs.length,
          itemBuilder: (c, i) {
            try {
              // Use the fromFirestore factory to parse the document
              final summary = Summary.fromFirestore(docs[i]);
              return SummaryCard(summary: summary);
            } catch (e) {
              // Handle individual document parsing errors
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error loading summary: ${e.toString()}',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _clearHistory() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to clear history.')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This will permanently delete all your summaries.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final batch = FirebaseFirestore.instance.batch();
        // Query the top-level 'summaries' collection and filter by user ID
        final snap2 = await FirebaseFirestore.instance
            .collection('summaries')
            .where('userId', isEqualTo: user.uid)
            .get();

        for (var doc in snap2.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All history cleared.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing history: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}