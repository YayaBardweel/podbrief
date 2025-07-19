// lib/pages/tabs/CreateTab.dart (Updated with Llama 3.2)
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
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;
  String _currentStatus = '';
  bool _isOllamaAvailable = false;
  late AIService _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = AIService();
    _checkOllamaStatus();
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // Check if Ollama is available
  Future<void> _checkOllamaStatus() async {
    try {
      final isAvailable = await _aiService.isOllamaAvailable();
      setState(() {
        _isOllamaAvailable = isAvailable;
      });

      if (!isAvailable) {
        _showSnackBar('Ollama is not available. AI features will use fallback mode.', isError: true);
      }
    } catch (e) {
      setState(() {
        _isOllamaAvailable = false;
      });
      debugPrint('Error checking Ollama status: $e');
    }
  }

  // Pull Llama 3.2 model
  Future<void> _pullLlamaModel() async {
    setState(() {
      _isLoading = true;
      _currentStatus = 'Downloading Llama 3.2 model...';
    });

    try {
      await _aiService.pullModel();
      await _checkOllamaStatus();
      _showSnackBar('Llama 3.2 model downloaded successfully!');
    } catch (e) {
      _showSnackBar('Failed to download model: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
        _currentStatus = '';
      });
    }
  }

  // Check if user is authenticated
  bool get _isUserAuthenticated => FirebaseAuth.instance.currentUser != null;

  // Sign in anonymously if not authenticated
  Future<User?> _ensureUserAuthenticated() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      try {
        setState(() {
          _currentStatus = 'Authenticating...';
        });

        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        user = userCredential.user;

        // Wait for auth state to propagate
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Authentication failed: $e');
        throw Exception('Authentication failed. Please try again.');
      }
    }

    return user;
  }

  // Generate a smart title from transcript using AI
  Future<String> _generateSmartTitle(String transcript) async {
    if (!_isOllamaAvailable) {
      return _generateTitleFromTranscript(transcript);
    }

    try {
      setState(() {
        _currentStatus = 'Generating smart title...';
      });

      final titlePrompt = '''
      Please create a concise, engaging title for this podcast transcript. 
      The title should be 3-8 words long and capture the main topic or theme.
      Do not include quotes or extra formatting, just return the title.
      
      Transcript: ${transcript.substring(0, transcript.length > 500 ? 500 : transcript.length)}...
      ''';

      final aiTitle = await _aiService.generateText(titlePrompt);
      // Clean up the AI response
      final cleanTitle = aiTitle.trim().replaceAll(RegExp(r'[^\w\s]'), '').trim();

      return cleanTitle.length > 60 ? cleanTitle.substring(0, 57) + '...' : cleanTitle;
      } catch (e) {
        debugPrint('Smart title generation failed: $e');
        return _generateTitleFromTranscript(transcript);
      }
    }

  // Generate a simple title from transcript (fallback)
  String _generateTitleFromTranscript(String transcript) {
    final words = transcript.split(' ');
    if (words.length < 5) return 'Podcast Summary';

    // Take first 5-8 words and clean them up
    final titleWords = words.take(8).map((word) =>
        word.replaceAll(RegExp(r'[^\w\s]'), '').trim()
    ).where((word) => word.isNotEmpty).take(5);

    String title = titleWords.join(' ');
    if (title.length > 50) {
      title = title.substring(0, 47) + '...';
    }

    return title.isEmpty ? 'Podcast Summary' : title;
  }

  // Validate transcript input
  String? _validateTranscript(String transcript) {
    if (transcript.isEmpty) {
      return 'Please enter a transcript';
    }
    if (transcript.length < 50) {
      return 'Transcript is too short. Please enter at least 50 characters.';
    }
    if (transcript.length > 10000) {
      return 'Transcript is too long. Please keep it under 10,000 characters.';
    }
    return null;
  }

  void _submitTranscript() async {
    final transcript = _transcriptController.text.trim();

    // Validate input
    final validationError = _validateTranscript(transcript);
    if (validationError != null) {
      _showSnackBar(validationError, isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _currentStatus = 'Starting...';
    });

    try {
      // Ensure user is authenticated
      final user = await _ensureUserAuthenticated();
      if (user == null) {
        throw Exception('Authentication failed');
      }

      // Generate smart title if not provided
      String title = _titleController.text.trim();
      if (title.isEmpty) {
        title = await _generateSmartTitle(transcript);
      }

      // Update status
      setState(() {
        _currentStatus = _isOllamaAvailable
            ? 'Generating AI summary with Llama 3.2...'
            : 'Generating summary...';
      });

      // Generate summary using AI service
      String summaryText;
      try {
        if (_isOllamaAvailable) {
          // Use Llama 3.2 for enhanced summary
          final enhancedPrompt = '''
          Please create a comprehensive summary of this podcast transcript. Include:
          
          1. Main topics and key points
          2. Important insights or takeaways
          3. Notable quotes or statements
          4. Action items or recommendations (if any)
          
          Format the summary with clear headings and bullet points for easy reading.
          
          Transcript: $transcript
          ''';
          summaryText = await _aiService.generateText(enhancedPrompt);
        } else {
          // Use basic summary generation
          summaryText = await _aiService.generateSummary(transcript);
        }
      } catch (e) {
        debugPrint('AI Service failed, using fallback: $e');
        // Fallback summary generation
        summaryText = _generateFallbackSummary(transcript);
      }

      // Update status
      setState(() {
        _currentStatus = 'Saving summary...';
      });

      // Create Summary object
      final summary = Summary(
        id: const Uuid().v4(),
        userId: user.uid,
        title: title,
        transcript: transcript,
        summaryText: summaryText,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await DBService().saveSummary(summary);

      // Clear inputs and show success
      _transcriptController.clear();
      _titleController.clear();
      _showSnackBar('Summary created successfully with ${_isOllamaAvailable ? 'Llama 3.2' : 'fallback'} AI!');

      // Optional: Navigate to summary view
      // Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryDetailPage(summary: summary)));

    } catch (e) {
      _handleError(e);
    } finally {
      setState(() {
        _isLoading = false;
        _currentStatus = '';
      });
    }
  }

  // Generate a simple fallback summary
  String _generateFallbackSummary(String transcript) {
    final words = transcript.split(' ');
    final wordCount = words.length;
    final sentences = transcript.split(RegExp(r'[.!?]+'));

    // Create a basic summary
    final summary = StringBuffer();
    summary.writeln('📊 **Summary Statistics:**');
    summary.writeln('• Word Count: $wordCount words');
    summary.writeln('• Estimated Reading Time: ${(wordCount / 200).ceil()} minutes');
    summary.writeln('• Sentences: ${sentences.length}');
    summary.writeln('\n📝 **Content Preview:**');

    // Add first few sentences
    final previewSentences = sentences.take(3).map((s) => s.trim()).where((s) => s.isNotEmpty);
    for (final sentence in previewSentences) {
      summary.writeln('• ${sentence.length > 100 ? sentence.substring(0, 97) + '...' : sentence}');
    }

    summary.writeln('\n💡 **Note:** This is a basic summary. For AI-powered insights, please ensure Ollama with Llama 3.2 is running.');

    return summary.toString();
  }

  void _handleError(dynamic error) {
    String errorMessage = 'An unexpected error occurred.';

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          errorMessage = 'Permission denied. Please check your authentication.';
          break;
        case 'unavailable':
          errorMessage = 'Service unavailable. Please try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        default:
          errorMessage = 'Firebase error: ${error.message}';
      }
    } else if (error is Exception) {
      errorMessage = error.toString().replaceAll('Exception: ', '');
    }

    _showSnackBar(errorMessage, isError: true);
    debugPrint('Error in _submitTranscript: $error');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Transcript'),
        content: const Text('File upload functionality will be implemented soon. For now, please paste your transcript directly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with AI status
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Create a Podcast Summary',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isOllamaAvailable ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isOllamaAvailable ? Icons.smart_toy : Icons.warning,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isOllamaAvailable ? 'Llama 3.2' : 'Fallback',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Instructions with AI info
            Text(
              _isOllamaAvailable
                  ? 'Paste your podcast transcript below to get an AI-powered summary using Llama 3.2.'
                  : 'Paste your podcast transcript below. AI features are in fallback mode.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),

            // Ollama status and controls
            if (!_isOllamaAvailable)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ollama with Llama 3.2 is not available. You can still create summaries with basic AI.',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _checkOllamaStatus,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Check Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pullLlamaModel,
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Download Model'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            if (!_isOllamaAvailable) const SizedBox(height: 16),

            // Authentication status
            if (!_isUserAuthenticated)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will be signed in automatically when you create a summary.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (!_isUserAuthenticated) const SizedBox(height: 16),

            // Optional title input
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
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: _isOllamaAvailable
                      ? 'Summary title (optional - AI will generate one)'
                      : 'Summary title (optional - will be auto-generated)',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.title, color: Colors.grey[600]),
                ),
                style: const TextStyle(fontFamily: 'Poppins'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.article, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Transcript',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_transcriptController.text.length}/10000',
                        style: TextStyle(
                          fontSize: 12,
                          color: _transcriptController.text.length > 10000
                              ? Colors.red
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _transcriptController,
                    maxLines: 10,
                    onChanged: (value) => setState(() {}), // Update character count
                    decoration: InputDecoration(
                      hintText: 'Paste your transcript here...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Loading status
            if (_isLoading && _currentStatus.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentStatus,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_isLoading) const SizedBox(height: 16),

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
                  elevation: _isLoading ? 0 : 2,
                ),
                child: _isLoading
                    ? const Row(
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
                    SizedBox(width: 12),
                    Text(
                      'Processing...',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isOllamaAvailable ? Icons.smart_toy : Icons.summarize,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOllamaAvailable ? 'Create AI Summary' : 'Create Summary',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Upload button
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _showUploadDialog,
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text('Upload Transcript File'),
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