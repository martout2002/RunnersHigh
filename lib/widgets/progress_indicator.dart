import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final Map<String, dynamic>? runRecommendation;
  final List<Map<String, dynamic>> pastRuns;

  const ProgressIndicatorWidget({Key? key, required this.runRecommendation, required this.pastRuns}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = _calculateProgress();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CircularPercentIndicator(
        radius: 100.0,
        lineWidth: 10.0,
        percent: progress,
        center: Text(
          "${(progress * 100).toStringAsFixed(1)}%",
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        progressColor: Colors.blue,
      ),
    );
  }

  double _calculateProgress() {
    if (runRecommendation != null) {
      int totalRuns = 0;
      int completedRuns = 0;

      runRecommendation!.forEach((week, runs) {
        runs.forEach((run, details) {
          if (_isValidRun(details)) {
            totalRuns++;
            if (_checkIfRunCompleted(details)) {
              completedRuns++;
            }
          }
        });
      });

      return totalRuns > 0 ? completedRuns / totalRuns : 0.0;
    }
    return 0.0;
  }

  bool _isValidRun(String details) {
    return details.contains('Run') && details.contains('m') && details.contains('pace');
  }

  bool _checkIfRunCompleted(String details) {
    for (var run in pastRuns) {
      if (details.contains(run['distance'].toString()) && details.contains(run['pace'])) {
        return true;
      }
    }
    return false;
  }
}
