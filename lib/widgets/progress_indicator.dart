import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final Map<String, dynamic>? runRecommendation;

  const ProgressIndicatorWidget({Key? key, required this.runRecommendation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = _calculateProgress();

    // Determine the text color based on the current theme
    Color textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CircularPercentIndicator(
        radius: 100.0,
        lineWidth: 10.0,
        percent: progress,
        center: Text(
          "${(progress * 100).toStringAsFixed(1)}%",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: textColor),
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
        if (runs is Map<String, dynamic>) {
          runs.forEach((run, details) {
            if (details is Map<String, dynamic>) {
              totalRuns++;
              if (details['completed'] == true) {
                completedRuns++;
              }
            }
          });
        }
      });

      return totalRuns > 0 ? completedRuns / totalRuns : 0.0;
    }
    return 0.0;
  }
}
