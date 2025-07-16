import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echomind/mod/summary_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID dynamically (don't store as instance variable)
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> saveSummary(Summary summary) async {
    try {
      print('DBService: Attempting to save summary...');
      print('DBService: Current user ID: $_userId');
      print('DBService: Summary user ID: ${summary.userId}');

      if (_userId == null) {
        print('DBService: No authenticated user found');
        throw Exception('No authenticated user found');
      }

      // Save to the top-level 'summaries' collection (to match your Firebase rules)
      await _firestore
          .collection('summaries')  // Top-level collection
          .doc(summary.id)
          .set(summary.toMap());

      print('DBService: Summary saved successfully');
    } catch (e) {
      print('DBService: Error saving summary: $e');
      rethrow;
    }
  }

  Stream<List<Summary>> getSummaries() {
    if (_userId == null) {
      print('DBService: No user ID for getSummaries');
      return const Stream.empty();
    }

    print('DBService: Getting summaries for user: $_userId');

    // Query the top-level 'summaries' collection filtered by userId
    return _firestore
        .collection('summaries')  // Top-level collection
        .where('userId', isEqualTo: _userId)  // Filter by current user
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Summary.fromFirestore(doc))  // Use fromFirestore instead of fromMap
        .toList());
  }

  Future<void> deleteSummary(String id) async {
    try {
      if (_userId == null) {
        throw Exception('No authenticated user found');
      }

      print('DBService: Deleting summary: $id');

      // Delete from the top-level 'summaries' collection
      await _firestore
          .collection('summaries')  // Top-level collection
          .doc(id)
          .delete();

      print('DBService: Summary deleted successfully');
    } catch (e) {
      print('DBService: Error deleting summary: $e');
      rethrow;
    }
  }

  Future<void> deleteAllSummaries() async {
    try {
      if (_userId == null) {
        throw Exception('No authenticated user found');
      }

      print('DBService: Deleting all summaries for user: $_userId');

      // Get all summaries for the current user
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('summaries')
          .where('userId', isEqualTo: _userId)
          .get();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('DBService: All summaries deleted successfully');
    } catch (e) {
      print('DBService: Error deleting all summaries: $e');
      rethrow;
    }
  }
}