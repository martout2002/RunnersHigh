import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GeminiService {
  final Gemini gemini = Gemini.instance;

  Future<String?> getRunRecommendation(String userHistory, String? userGoal) async {
    _logDebug('Fetching run recommendation from API...');
    try {
      final response = await gemini.text(
        "Based on the history: $userHistory and the goal: $userGoal, what is the recommended run program?",
      );

      if (response != null) {
        _logDebug('API response received: ${response.output}');
        return response.output;
      } else {
        throw Exception('Failed to fetch recommendation');
      }
    } catch (e) {
      _logDebug('Error fetching recommendation: $e');
      throw Exception('Error fetching recommendation: $e');
    }
  }

  Future<String?> getRunRecommendationBasedOnGoal(String? userGoal) async {
    _logDebug('Fetching run recommendation based on goal from API...');
    try {
      final response = await gemini.text(
        "Based on the goal: $userGoal, what is the recommended run program?",
      );

      if (response != null) {
        _logDebug('API response received: ${response.output}');
        return response.output;
      } else {
        throw Exception('Failed to fetch recommendation based on goal');
      }
    } catch (e) {
      _logDebug('Error fetching recommendation based on goal: $e');
      throw Exception('Error fetching recommendation based on goal: $e');
    }
  }

  Future<void> storeRecommendation(String recommendation) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child('recommendations').child(user.uid);
      await ref.set({
        'recommendation': recommendation,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _logDebug('Recommendation stored in Firebase.');
    }
  }

  Future<Map<String, dynamic>?> getStoredRecommendation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child('recommendations').child(user.uid);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        _logDebug('Stored recommendation retrieved from Firebase.');
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    }
    return null;
  }

  void _logDebug(String message) {
    print('DEBUG: $message'); // You can replace this with a more sophisticated logging mechanism if needed.
  }
}
