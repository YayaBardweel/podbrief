import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = 'http://10.0.2.2:11434';  // Fixed: removed asterisk, made private
  static const String _model = 'llama3.2';  // Fixed: removed asterisk, made private

  /// Generate a detailed summary using Llama 3.2 via Ollama
  Future<String> generateSummary(String transcript) async {
    try {
      final response = await _makeOllamaRequest(  // Fixed: removed asterisk
        '''
        Please provide a detailed summary of the following transcript. The summary should include:
        1. Main topics discussed.
        2. Key insights or takeaways.
        3. Notable quotes or statements.
        4. Actionable items or recommendations (if any).
        5. The overall theme of the podcast.

        Format the summary with headings and bullet points for easy reading.

        Transcript: $transcript
        ''',
      );
      return response;
    } catch (e) {
      throw Exception('Failed to generate summary: $e');
    }
  }

  /// Generate general text using Llama 3.2 via Ollama
  Future<String> generateText(String prompt) async {
    try {
      final response = await _makeOllamaRequest(prompt);
      return response;
    } catch (e) {
      throw Exception('Failed to generate text: $e');
    }
  }

  /// Make request to Ollama API
  Future<String> _makeOllamaRequest(String prompt) async {  // Fixed: removed asterisk, made private
    final url = Uri.parse('$_baseUrl/api/generate');  // Fixed: removed asterisk

    final requestBody = {
      'model': _model,  // Fixed: removed asterisk
      'prompt': prompt,
      'stream': false,
      'options': {
        'temperature': 0.7,
        'max_tokens': 2048,  // Fixed: removed asterisk from max_tokens
        'top_p': 0.9,
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['response'] ?? 'No response generated';
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Check if Ollama is running and model is available
  Future<bool> isOllamaAvailable() async {
    try {
      final url = Uri.parse('$_baseUrl/api/tags');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = data['models'] as List<dynamic>;
        // Fixed: Check for exact model name match
        return models.any((model) =>
        model['name'].toString().startsWith('llama3.2') ||
            model['name'].toString().contains('llama3.2')
        );
      }
      return false;
    } catch (e) {
      print('Error checking Ollama availability: $e');  // Added debugging
      return false;
    }
  }

  /// Pull Llama 3.2 model if not available
  Future<void> pullModel() async {
    try {
      final url = Uri.parse('$_baseUrl/api/pull');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': _model}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to pull model: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to pull model: $e');
    }
  }

  /// Test connection to Ollama server
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/api/version');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  /// Get list of available models
  Future<List<String>> getAvailableModels() async {
    try {
      final url = Uri.parse('$_baseUrl/api/tags');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = data['models'] as List<dynamic>;
        return models.map((model) => model['name'].toString()).toList();
      }
      return [];
    } catch (e) {
      print('Error getting available models: $e');
      return [];
    }
  }
}