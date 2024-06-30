import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

class RecommendationWidget extends StatefulWidget {
  final Map<String, dynamic> recommendation;
  final List<Map<String, dynamic>> pastRuns;

  const RecommendationWidget({
    super.key,
    required this.recommendation,
    required this.pastRuns,
  });

  @override
  _RecommendationWidgetState createState() => _RecommendationWidgetState();
}

class _RecommendationWidgetState extends State<RecommendationWidget> {
  Map<String, Set<String>> completedRuns = {};

  bool _checkIfMetRequirement(String requirement) {
    for (var run in widget.pastRuns) {
      if (requirement.contains(run['distance'].toString()) && requirement.contains(run['pace'].toString())) {
        return true;
      }
    }
    return false;
  }

  Future<void> _loadCompletedRuns() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child('completed_runs').child(user.uid);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        setState(() {
          completedRuns = data.map((key, value) => MapEntry(key as String, Set<String>.from(value.keys)));
        });
        log('Completed runs loaded: $completedRuns');
      }
    }
  }

  Future<void> _toggleRunCompletion(String week, String runKey) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child('completed_runs').child(user.uid).child(week).child(runKey);
      if (completedRuns[week]?.contains(runKey) ?? false) {
        // Untick the run
        try {
          await ref.remove();
          setState(() {
            completedRuns[week]?.remove(runKey);
            if (completedRuns[week]?.isEmpty ?? false) {
              completedRuns.remove(week);
            }
          });
          log('Run unmarked as completed: $week - $runKey');
        } catch (e) {
          log('Error unmarking run as completed: $e');
        }
      } else {
        // Tick the run
        try {
          await ref.set({'completed': true});
          setState(() {
            completedRuns.putIfAbsent(week, () => {}).add(runKey);
          });
          log('Run marked as completed: $week - $runKey');
        } catch (e) {
          log('Error marking run as completed: $e');
        }
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
  void initState() {
    super.initState();
    _loadCompletedRuns();
  }

  @override
  Widget build(BuildContext context) {
    log('Recommendation data: ${widget.recommendation}'); // Debugging log
    log('Past runs data: ${widget.pastRuns}'); // Debugging log

    // Sort keys in ascending order
    var sortedKeys = widget.recommendation.keys.toList()
      ..sort((a, b) => _extractWeekNumber(a).compareTo(_extractWeekNumber(b)));

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        String phaseKey = sortedKeys[index];
        Map<String, dynamic> phaseDetails = Map<String, dynamic>.from(widget.recommendation[phaseKey]);
        log('Phase details for $phaseKey: $phaseDetails'); // Debugging log

        // Sort runs in ascending order
        var sortedRuns = phaseDetails.keys.toList()
          ..sort((a, b) => _extractWeekNumber(a).compareTo(_extractWeekNumber(b)));

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text(phaseKey, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: sortedRuns.map((runKey) {
              final isMet = _checkIfMetRequirement(phaseDetails[runKey]);
              final isCompleted = completedRuns[phaseKey]?.contains(runKey) ?? false;
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
                subtitle: Text(phaseDetails[runKey], style: const TextStyle(fontSize: 16.0)),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
