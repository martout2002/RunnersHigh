import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  Future<String?> getRunRecommendation(String userHistory, String? userGoal) async {
    final gemini = Gemini.instance;

    try {
      final response = await gemini.text(
        "Based on the history: $userHistory and the goal: $userGoal, what is the recommended run program?",
      );

      if (response != null) {
        return response.output;
      } else {
        throw Exception('Failed to fetch recommendation');
      }
    } catch (e) {
      throw Exception('Error fetching recommendation: $e');
    }
  }
}

