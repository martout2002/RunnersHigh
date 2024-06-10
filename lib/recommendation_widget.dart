import 'package:flutter/material.dart';

class RecommendationWidget extends StatelessWidget {
  final String recommendation;
  final List<Map<String, dynamic>> pastRuns;

  const RecommendationWidget({
    Key? key,
    required this.recommendation,
    required this.pastRuns,
  }) : super(key: key);

  List<Map<String, String>> _parseRecommendation(String recommendation) {
    final phases = recommendation.split('Phase');
    return phases.skip(1).map((phase) {
      final parts = phase.split('.').map((part) => part.trim()).toList();
      String intensity = parts.length > 0 ? parts[0] : '';
      String rest = parts.length > 1 ? parts[1] : '';

      return {
        'intensity': intensity,
        'rest': rest,
      };
    }).toList();
  }

  bool _checkIfMetRequirement(String intensity) {
    // Basic logic to check if user met the requirement, can be enhanced
    // Assuming the intensity string contains details about the requirement
    for (var run in pastRuns) {
      if (run['distance'] >= 5) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final phases = _parseRecommendation(recommendation);

    return ListView.builder(
      itemCount: phases.length,
      itemBuilder: (context, index) {
        final phase = phases[index];
        final isMet = _checkIfMetRequirement(phase['intensity']!);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            leading: Icon(
              isMet ? Icons.check_circle : Icons.check_circle_outline,
              color: isMet ? Colors.green : Colors.grey,
              size: 40.0,
            ),
            title: Text(
              phase['intensity']!,
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Rest: ${phase['rest']}',
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        );
      },
    );
  }
}
