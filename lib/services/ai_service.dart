class AIService {
  Future<String> generateSummary(String transcript) async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));
    // In the future, replace with actual LLaMA/Cloud call
    return "This is a summarized version of your transcript: ${transcript.substring(0, transcript.length > 100 ? 100 : transcript.length)}...";
  }
}
