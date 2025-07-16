// lib/models/user_model.dart (Revised to include stats)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserModel {
  final String uid;
  final String username;
  final String email;
  final DateTime? registrationDate;
  final int totalSummaries; // Added
  final int totalListeningTime; // Added

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.registrationDate,
    this.totalSummaries = 0, // Default value
    this.totalListeningTime = 0, // Default value
  });

  factory UserModel.fromFirebaseAuth(firebase_auth.User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      username: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
      email: firebaseUser.email ?? 'No Email',
      registrationDate: firebaseUser.metadata.creationTime,
      totalSummaries: 0, // Default for Firebase Auth only init
      totalListeningTime: 0, // Default for Firebase Auth only init
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data was null");
    }
    return UserModel(
      uid: doc.id,
      username: data['username'] as String? ?? data['displayName'] as String? ?? (data['email'] as String?)?.split('@').first ?? 'User',
      email: data['email'] as String? ?? 'No Email',
      registrationDate: (data['registrationDate'] as Timestamp?)?.toDate(),
      totalSummaries: (data['totalSummaries'] as int?) ?? 0, // Read from Firestore
      totalListeningTime: (data['totalListeningTime'] as int?) ?? 0, // Read from Firestore
    );
  }

  UserModel copyWithFirestoreData(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return this; // Return current instance if no data

    return UserModel(
      uid: this.uid,
      username: data['username'] as String? ?? this.username,
      email: data['email'] as String? ?? this.email,
      registrationDate: (data['registrationDate'] as Timestamp?)?.toDate() ?? this.registrationDate,
      totalSummaries: (data['totalSummaries'] as int?) ?? this.totalSummaries, // Update if present
      totalListeningTime: (data['totalListeningTime'] as int?) ?? this.totalListeningTime, // Update if present
    );
  }
}