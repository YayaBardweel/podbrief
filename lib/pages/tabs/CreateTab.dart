import 'package:flutter/material.dart';
import 'package:echomind/constants/colors.dart'; // Use your custom theme colors

class CreateTab extends StatefulWidget {
  const CreateTab({Key? key}) : super(key: key);

  @override
  State<CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  final TextEditingController _transcriptController = TextEditingController();

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  void _submitTranscript() {
    final transcript = _transcriptController.text.trim();
    if (transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a transcript")),
      );
      return;
    }
    // Proceed with summarizing the transcript or uploading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Summarizing your transcript...")),
    );
    // Add functionality for AI summarization here
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
                onPressed: _submitTranscript,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Summarize Transcript',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Optional: Add more functionality like file upload if required
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Trigger file upload functionality
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
