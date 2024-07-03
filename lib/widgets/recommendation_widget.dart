import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

class RecommendationWidget extends StatefulWidget {
  final Map<String, dynamic> recommendation;
  final List<Map<String, dynamic>> pastRuns;
  final Function(Map<String, dynamic>) onRecommendationUpdated; // Callback for when recommendation is updated

  const RecommendationWidget({
    super.key,
    required this.recommendation,
    required this.pastRuns,
    required this.onRecommendationUpdated, // Accept callback in constructor
  });

  @override
  _RecommendationWidgetState createState() => _RecommendationWidgetState();
}

class _RecommendationWidgetState extends State<RecommendationWidget> {
  bool _checkIfMetRequirement(String requirement) {
    for (var run in widget.pastRuns) {
      if (requirement.contains(run['distance'].toString()) && requirement.contains(run['pace'].toString())) {
        return true;
      }
    }
    return false;
  }

  Future<void> _toggleRunCompletion(String week, String runKey) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance
          .ref()
          .child('recommendations')
          .child(user.uid)
          .child('recommendation')
          .child(week)
          .child(runKey)
          .child('completed');
      bool isCompleted = widget.recommendation[week][runKey]['completed'] ?? false;
      log('Toggling run completion: $week - $runKey from $isCompleted to ${!isCompleted}');
      try {
        await ref.set(!isCompleted);
        setState(() {
          widget.recommendation[week][runKey]['completed'] = !isCompleted;
        });
        widget.onRecommendationUpdated(widget.recommendation); // Notify parent of update
        log('Run completion toggled: $week - $runKey to ${!isCompleted}');
      } catch (e) {
        log('Error toggling run completion: $e');
      }
    }
  }

  int _extractWeekNumber(String key) {
    try {
      return int.parse(RegExp(r'\d+').firstMatch(key)!.group(0)!);
    } catch (e) {
      log('Error parsing week number from key: $key');
      return 0; // Return a default value if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    // log('Recommendation data: ${widget.recommendation}'); // Debugging log
    // log('Past runs data: ${widget.pastRuns}'); // Debugging log

    // Sort keys in ascending order
    var sortedKeys = widget.recommendation.keys.toList()
      ..sort((a, b) => _extractWeekNumber(a).compareTo(_extractWeekNumber(b)));

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        String phaseKey = sortedKeys[index];
        var phaseDetails = widget.recommendation[phaseKey];
        // log('Phase details for $phaseKey: $phaseDetails'); // Debugging log

        // Sort runs in ascending order
        var sortedRuns = phaseDetails.keys.toList()
          ..sort((a, b) => _extractWeekNumber(a).compareTo(_extractWeekNumber(b)));

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text(phaseKey, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: sortedRuns.map<Widget>((runKey) {
              var runDetails = phaseDetails[runKey];
              if (runDetails is! Map) {
                log('Invalid run details format for $runKey: $runDetails');
                return Container(); // Skip invalid run details
              }
              final isMet = _checkIfMetRequirement(runDetails['details'] ?? '');
              final isCompleted = runDetails['completed'] ?? false;
              return ListTile(
                leading: IconButton(
                  icon: Icon(
                    isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                    color: isCompleted ? Colors.green : Colors.grey,
                    size: 40.0,
                  ),
                  onPressed: () {
                    _toggleRunCompletion(phaseKey, runKey);
                  },
                ),
                title: Text(runKey, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(runDetails['details'] ?? '', style: const TextStyle(fontSize: 16.0)),
              );
            }).toList(), // Explicitly cast to List<Widget>
          ),
        );
      },
    );
  }
}
