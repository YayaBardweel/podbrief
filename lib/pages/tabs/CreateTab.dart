// lib/pages/tabs/CreateTab.dart (Updated with Better Auth Handling)
import 'package:echomind/mod/summary_model.dart';
import 'package:flutter/material.dart';
import 'package:echomind/constants/colors.dart';
import 'package:echomind/services/ai_service.dart';
import 'package:echomind/services/db_service.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class CreateTab extends StatefulWidget {
  const CreateTab({Key? key}) : super(key: key);

  @override
  State<CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  final TextEditingController _transcriptController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  // Check if user is authenticated
  bool _isUserAuthenticated() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  // Sign in anonymously if not authenticated
  Future<User?> _ensureUserAuthenticated() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      try {
        print('Attempting to sign in anonymously...');
        // Sign in anonymously
        UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
        user = userCredential.user;
        print('Successfully signed in anonymously: ${user?.uid}');

        // Wait a moment for the auth state to propagate
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('Failed to sign in anonymously: $e');
        // Try to get more specific error information
        if (e is FirebaseAuthException) {
          print('Firebase Auth Error Code: ${e.code}');
          print('Firebase Auth Error Message: ${e.message}');
        }
        return null;
      }
    } else {
      print('User already authenticated: ${user.uid}');
    }

    return user;
  }

  void _submitTranscript() async {
    final transcript = _transcriptController.text.trim();
    if (transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a transcript")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure user is authenticated (sign in anonymously if needed)
      final user = await _ensureUserAuthenticated();

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication failed. Please try again.")),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Show loading feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Summarizing your transcript...")),
      );

      // Generate summary using AI service (temporarily disabled for testing)
      // final summaryText = await AIService().generateSummary(transcript);
      final summaryText = "This is a test summary for: ${transcript.substring(0, math.min(50, transcript.length))}..."; // Temporary test summary

      // Create a Summary object with detailed logging
      print('Creating summary with userId: ${user.uid}');
      final summary = Summary(
        id: const Uuid().v4(),
        userId: user.uid, // Use authenticated user's UID
        title: 'Podcast Summary: ${DateTime.now().toLocal().toString().split(' ')[0]}',
        transcript: transcript,
        summaryText: summaryText,
        createdAt: DateTime.now(),
      );

      print('Attempting to save summary to Firestore...');
      // Save to Firestore using DBService
      await DBService().saveSummary(summary);
      print('Summary saved successfully!');

      // Clear the input field
      _transcriptController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Summary saved successfully!")),
      );
    } catch (e) {
      String errorMessage = "An error occurred while creating the summary.";

      // Handle specific Firebase errors
      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            errorMessage = "Permission denied. Please check your authentication.";
            break;
          case 'unavailable':
            errorMessage = "Service unavailable. Please try again later.";
            break;
          default:
            errorMessage = "Firebase error: ${e.message}";
        }
      } else {
        errorMessage = "Error: ${e.toString()}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      print('Error submitting transcript: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Create a Podcast Summary',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            Text(
              'Paste your podcast transcript below to get a quick summary.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 32),

            // Authentication status (for debugging)
            if (!_isUserAuthenticated())
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[800]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will be signed in automatically when you create a summary.',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Transcript input field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _transcriptController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Paste your transcript here...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitTranscript,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Summarizing...',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                )
                    : const Text(
                  'Summarize Transcript',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Optional: Add more functionality like file upload if required
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () {
                  // Trigger file upload functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("File upload not yet implemented.")),
                  );
                },
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text('Upload Transcript'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}