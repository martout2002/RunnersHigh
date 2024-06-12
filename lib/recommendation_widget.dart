import 'package:flutter/material.dart';
import 'dart:developer';

class RecommendationWidget extends StatelessWidget {
  final Map<String, dynamic> recommendation;
  final List<Map<String, dynamic>> pastRuns;

  const RecommendationWidget({
    super.key,
    required this.recommendation,
    required this.pastRuns,
  });

  bool _checkIfMetRequirement(String requirement) {
    for (var run in pastRuns) {
      if (requirement.contains(run['distance'].toString()) && requirement.contains(run['pace'].toString())) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    log('Recommendation data: $recommendation'); // Debugging log
    log('Past runs data: $pastRuns'); // Debugging log

    var sortedKeys = recommendation.keys.toList()
      ..sort((a, b) {
        try {
          return int.parse(a.split(' ')[1].split('-')[0]).compareTo(int.parse(b.split(' ')[1].split('-')[0]));
        } catch (e) {
          return 0; // If parsing fails, consider them equal
        }
      });

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        String phaseKey = sortedKeys[index];
        Map<String, dynamic> phaseDetails = Map<String, dynamic>.from(recommendation[phaseKey]);
        log('Phase details for $phaseKey: $phaseDetails'); // Debugging log

        var sortedRuns = phaseDetails.keys.toList()
          ..sort((a, b) {
            try {
              return int.parse(a.split(' ')[1]).compareTo(int.parse(b.split(' ')[1]));
            } catch (e) {
              return 0; // If parsing fails, consider them equal
            }
          });

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text(phaseKey, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: sortedRuns.map((runKey) {
              final isMet = _checkIfMetRequirement(phaseDetails[runKey]);
              return ListTile(
                leading: Icon(
                  isMet ? Icons.check_circle : Icons.check_circle_outline,
                  color: isMet ? Colors.green : Colors.grey,
                  size: 40.0,
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
