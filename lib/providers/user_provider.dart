// lib/providers/user_provider.dart (with debug prints)
import 'package:echomind/mod/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserProvider() {
    print('UserProvider initialized.');
    _initializeUser();
  }

  void _initializeUser() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      print('Auth state changed. User: ${user?.uid}');
      if (user != null) {
        await fetchUserData(user.uid);
      } else {
        _currentUser = null;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        print('User is null. _currentUser set to null. Notifying listeners.');
      }
    });
  }

  Future<void> fetchUserData(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print('Fetching user data for UID: $uid. isLoading = true. Notifying.');

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null || firebaseUser.uid != uid) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        print('Firebase user null or UID mismatch. _currentUser set to null.');
        return;
      }

      // Initialize with Firebase Auth data first
      _currentUser = UserModel.fromFirebaseAuth(firebaseUser);
      notifyListeners();
      print('Initialized _currentUser from FirebaseAuth: ${_currentUser?.username}. Notifying.');


      // Then try to get from Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      print('Firestore doc exists: ${doc.exists}');

      if (doc.exists) {
        _currentUser = _currentUser!.copyWithFirestoreData(doc);
        print('Updated _currentUser with Firestore data: ${_currentUser?.username}.');
      } else {
        print('Firestore document for $uid does not exist. Creating one.');
        // If document doesn't exist, create it (this is crucial for new sign-ups)
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
          'email': firebaseUser.email,
          'registrationDate': firebaseUser.metadata.creationTime != null
              ? Timestamp.fromDate(firebaseUser.metadata.creationTime!)
              : null,
          // Add initial values for totalSummaries and totalListeningTime if needed
          'totalSummaries': 0,
          'totalListeningTime': 0,
        }, SetOptions(merge: true)); // Use merge: true to avoid overwriting if doc might partially exist

        // Fetch again to get the newly created data, including stats
        final updatedDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (updatedDoc.exists) {
          _currentUser = _currentUser!.copyWithFirestoreData(updatedDoc);
          print('Created and updated _currentUser with new Firestore data: ${_currentUser?.username}.');
        }
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = 'Authentication error: ${e.message}';
      _currentUser = null;
      print('FirebaseAuthException fetching user data: $e');
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      _currentUser = null;
      print('General error fetching user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('Finished fetching user data. isLoading = false. Notifying.');
    }
  }

  String getUsernameInitial() {
    if (_isLoading) return '...'; // Show loading for initial
    if (_currentUser == null || _currentUser!.username.isEmpty) return 'U';
    return _currentUser!.username.substring(0, 1).toUpperCase();
  }

  String getDisplayName() {
    if (_isLoading) return 'Loading...';
    if (_errorMessage != null) return 'Error User'; // Indicate an error state
    return _currentUser?.username ?? 'Guest'; // Default to 'Guest' if null
  }
}