
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:echomind/constants/colors.dart';
import 'package:echomind/widgets/summary_card.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('summaries')
            .where('userId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
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

          // Build a padded list of SummaryCard widgets
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            itemCount: docs.length,
            itemBuilder: (c, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final summaryMap = {
                'title':   data['title']   as String? ?? 'Untitled',
                'date':    (data['createdAt'] as Timestamp)
                    .toDate()
                    .toLocal()
                    .toString()
                    .split(' ')[0], // YYYY-MM-DD
                'preview': data['summary'] as String? ?? '',
              };

              return SummaryCard(summary: summaryMap);
            },
          );
        },
      ),
      // Floating "Clear History" action
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Optional: confirm with the user first
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Clear All History?'),
              content: const Text('This will permanently delete all your summaries.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(_, true),  child: const Text('Clear')),
              ],
            ),
          );
          if (ok == true) {
            final batch = FirebaseFirestore.instance.batch();
            final snap2 = await FirebaseFirestore.instance
                .collection('summaries')
                .where('userId', isEqualTo: uid)
                .get();
            for (var doc in snap2.docs) batch.delete(doc.reference);
            await batch.commit();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All history cleared.')),
            );
          }
        },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.delete_outline),
        label: const Text('Clear All'),
      ),
    );
  }
}
