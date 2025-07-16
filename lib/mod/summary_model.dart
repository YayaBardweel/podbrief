// lib/models/summary_model.dart (Updated)
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp

class Summary {
  final String id;
  final String userId; // Add this field to link summary to user
  final String title;
  final String transcript;
  final String summaryText;
  final DateTime createdAt;

  Summary({
    required this.id,
    required this.userId, // Mark as required
    required this.title,
    required this.transcript,
    required this.summaryText,
    required this.createdAt,
  });

  // Method to convert the Summary object to a Map for saving in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId, // Include userId in the map
      'title': title,
      'transcript': transcript,
      'summaryText': summaryText,
      'createdAt': Timestamp.fromDate(createdAt), // Store as Firestore Timestamp
    };
  }

  // Factory method to create a Summary object from Firestore document data
  factory Summary.fromMap(Map<String, dynamic> map) {
    return Summary(
      id: map['id'] ?? 'Unknown ID',
      userId: map['userId'] ?? 'Unknown User', // Get userId from map
      title: map['title'] ?? 'Untitled',
      transcript: map['transcript'] ?? '',
      summaryText: map['summaryText'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), // Handle Timestamp
    );
  }

  // Factory method to create Summary from a DocumentSnapshot
  factory Summary.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data was null for Summary ID: ${doc.id}");
    }
    return Summary(
      id: doc.id, // Often the document ID is used as the summary ID
      userId: data['userId'] as String? ?? 'Unknown User',
      title: data['title'] as String? ?? 'Untitled',
      transcript: data['transcript'] as String? ?? '',
      summaryText: data['summaryText'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}