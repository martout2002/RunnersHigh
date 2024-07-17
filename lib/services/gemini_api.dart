import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:developer';

class GeminiService {
  final Gemini gemini = Gemini.instance;

  final String runRecommendationPrompt = "You are a personal fitness instructor. Every month has 4 weeks, a year has 52 weeks. Based on the history: {userHistory}, the goal: {userGoal}, and the comfortable pace: {userPace} min/km, what is the recommended run program? "
      "Please provide the program in the following format with distances in km and pace in min/km: "
      "**Week X:**\n"
      "* Run 1: [distance] km at [pace] min/km pace\n"
      "* Run 2: [distance] km at [pace] min/km pace\n"
      "... \n"
      "**Week Y:**\n"
      "* Run 1: [distance] km at [pace] min/km pace\n"
      "* Run 2: [distance] km at [pace] min/km pace\n"
      "...";

  Future<Map<String, dynamic>?> _getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = (snapshot.value as Map).map<String, dynamic>(
          (key, value) => MapEntry(key as String, value as dynamic),
        );
        // log('User profile data retrieved: $data');
        return data;
      }
    }
    return null;
  }

  Future<String?> _fetchRunRecommendation(String prompt) async {
    try {
      final response = await gemini.text(prompt);
      return response?.output;
    } catch (e) {
      log('Error fetching recommendation: $e');
      return null;
    }
  }

  Future<String?> getRunRecommendation(String userHistory, String? userGoal, String? userPace, {Function(int)? onRetry}) async {
    const maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      if (attempt > 0 && onRetry != null) {
        onRetry(attempt); // Notify the user about retrying
      }

      final prompt = runRecommendationPrompt
          .replaceAll("{userHistory}", userHistory)
          .replaceAll("{userGoal}", userGoal ?? "unspecified goal")
          .replaceAll("{userPace}", userPace ?? "unspecified pace");

      final recommendation = await _fetchRunRecommendation(prompt);
      if (recommendation != null && _validateRecommendation(recommendation)) {
        return recommendation;
      } else {
        log('Invalid recommendation received: $recommendation');
        if (onRetry != null) {
          onRetry(attempt + 1); // Notify the user about retrying
        }
        await Future.delayed(const Duration(seconds: 2)); // Delay before retry
      }
      attempt++;
    }

    return null; // Return null if all attempts fail
  }

  Future<String?> getRunRecommendationBasedOnGoal(String? userGoal, String? userPace, {Function(int)? onRetry}) async {
    return getRunRecommendation("", userGoal, userPace, onRetry: onRetry);
  }

  bool _validateRecommendation(String recommendation) {
    List<String> weeks = recommendation.split(RegExp(r'\n{2,}'));
    for (String weekData in weeks) {
      if (weekData.trim().isEmpty) continue;
      List<String> lines = weekData.split('\n').where((line) => line.trim().isNotEmpty).toList();
      String weekTitle = lines[0].trim();
      if (!_isValidWeekTitle(weekTitle)) {
        log('Invalid week title: $weekTitle');
        return false;
      }
      for (int j = 1; j < lines.length; j++) {
        String runDetail = lines[j].trim();
        if (!_isValidRun(runDetail)) {
          log('Invalid run detail: $runDetail');
          return false;
        }
      }
    }
    return true;
  }

  Future<void> storeRecommendation(String recommendation) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child('recommendations').child(user.uid);
      Map<String, dynamic> structuredData = processRecommendation(recommendation);

      try {
        log('Structured data to store: $structuredData');
        await ref.set({
          'recommendation': structuredData,
          'timestamp': DateTime.now().toIso8601String(),
        });
        log('Recommendation stored successfully.');
      } catch (e) {
        log('Error storing recommendation: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> getStoredRecommendation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child('recommendations').child(user.uid);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = (snapshot.value as Map).map<String, dynamic>(
          (key, value) => MapEntry(key as String, value as dynamic),
        );
        // log('Stored recommendation retrieved: $data');
        return data;
      }
    }
    return null;
  }

  Map<String, dynamic> processRecommendation(String recommendation) {
    Map<String, dynamic> structuredData = {};
    List<String> weeks = recommendation.split(RegExp(r'\n{2,}'));

    for (String weekData in weeks) {
      if (weekData.trim().isEmpty) continue;  // Skip empty lines
      List<String> lines = weekData.split('\n').where((line) => line.trim().isNotEmpty).toList();
      String weekTitle = lines[0].trim();

      if (_isValidWeekTitle(weekTitle)) {
        Map<String, dynamic> weekRuns = {};
        for (int j = 1; j < lines.length; j++) {
          String runDetail = lines[j].trim();
          if (_isValidRun(runDetail)) {
            String runKey = 'Run ${weekRuns.length + 1}';
            weekRuns[runKey] = {
              'details': _cleanRunDetail(runDetail), // Clean run detail
              'completed': false // Default completion status
            };
          } else {
            log('Invalid run detail: $runDetail');  // Debugging log
          }
        }
        structuredData[_cleanTitle(weekTitle)] = weekRuns; // Clean week title
      } else {
        log('Invalid week title: $weekTitle');  // Debugging log
      }
    }

    log('Processed recommendation: $structuredData');  // Debugging log
    return structuredData;
  }

  bool _isValidWeekTitle(String title) {
    bool isValid = RegExp(r'^\*\*Week \d+(-\d+)?:\*\*$').hasMatch(title);
    if (!isValid) {
      log('Invalid week title: $title');
    }
    return isValid;
  }

  bool _isValidRun(String runDetail) {
    bool isValid = RegExp(r'^\* (Run \d+|Interval Run|Hill Repeats|Tempo Run|Rest): .*$').hasMatch(runDetail);
    if (!isValid) {
      log('Invalid run detail: $runDetail');
    }
    return isValid;
  }

  String _cleanTitle(String title) {
    return title.replaceAll('**', '');
  }

  String _cleanRunDetail(String runDetail) {
    return runDetail.replaceAll('* ', '');
  }
}
