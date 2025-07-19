import 'package:echomind/services/ai_service.dart';
import 'package:flutter/material.dart';
void main(){
  runApp(DebugOllamaWidget());
}
 // Your AI service file

class DebugOllamaWidget extends StatefulWidget {
  @override
  _DebugOllamaWidgetState createState() => _DebugOllamaWidgetState();
}

class _DebugOllamaWidgetState extends State<DebugOllamaWidget> {
  final AIService _aiService = AIService();
  String _debugInfo = 'Press button to test connection...';
  bool _isLoading = false;

  Future<void> _runDebugTests() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing connection...\n';
    });

    try {
      // Test 1: Basic connection
      final isConnected = await _aiService.testConnection();
      setState(() {
        _debugInfo += 'Connection test: ${isConnected ? "✅ SUCCESS" : "❌ FAILED"}\n';
      });

      if (!isConnected) {
        setState(() {
          _debugInfo += '\n❌ Ollama server is not running or not accessible\n';
          _debugInfo += 'Solutions:\n';
          _debugInfo += '1. Make sure Ollama is installed\n';
          _debugInfo += '2. Run "ollama serve" in terminal\n';
          _debugInfo += '3. Check if port 11434 is free\n';
        });
        return;
      }

      // Test 2: List available models
      final models = await _aiService.getAvailableModels();
      setState(() {
        _debugInfo += 'Available models: ${models.length} found\n';
        if (models.isNotEmpty) {
          _debugInfo += 'Models: ${models.join(", ")}\n';
        } else {
          _debugInfo += '❌ No models found\n';
        }
      });

      // Test 3: Check if llama3.2 is available
      final isLlamaAvailable = await _aiService.isOllamaAvailable();
      setState(() {
        _debugInfo += 'Llama 3.2 available: ${isLlamaAvailable ? "✅ YES" : "❌ NO"}\n';
      });

      if (!isLlamaAvailable) {
        setState(() {
          _debugInfo += '\n❌ Llama 3.2 not found\n';
          _debugInfo += 'Solutions:\n';
          _debugInfo += '1. Run "ollama pull llama3.2" in terminal\n';
          _debugInfo += '2. Wait for download to complete\n';
          _debugInfo += '3. Try "ollama pull llama3.2:latest" if above fails\n';
        });
      }

      // Test 4: Try a simple generation if model is available
      if (isLlamaAvailable) {
        setState(() {
          _debugInfo += '\nTesting text generation...\n';
        });

        try {
          final response = await _aiService.generateText('Say hello in one word');
          setState(() {
            _debugInfo += 'Generation test: ✅ SUCCESS\n';
            _debugInfo += 'Response: $response\n';
          });
        } catch (e) {
          setState(() {
            _debugInfo += 'Generation test: ❌ FAILED\n';
            _debugInfo += 'Error: $e\n';
          });
        }
      }

    } catch (e) {
      setState(() {
        _debugInfo += '\n❌ Unexpected error: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       home: Scaffold(
        appBar: AppBar(
          title: Text('Ollama Debug'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _runDebugTests,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Test Ollama Connection'),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _debugInfo,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}