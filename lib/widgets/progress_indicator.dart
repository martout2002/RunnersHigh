import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:developer';

class ProgressIndicatorWidget extends StatefulWidget {
  final Map<String, dynamic>? runRecommendation;

  const ProgressIndicatorWidget({super.key, required this.runRecommendation});

  @override
  _ProgressIndicatorWidgetState createState() => _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateProgress();
  }

  @override
  void didUpdateWidget(ProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('ProgressIndicatorWidget didUpdateWidget called');
    _calculateProgress();
  }

  void _calculateProgress() {
    if (widget.runRecommendation != null) {
      int totalRuns = 0;
      int completedRuns = 0;

      log('Calculating progress for: ${widget.runRecommendation}'); // Log the run recommendation data
      widget.runRecommendation!.forEach((week, runs) {
        log('Processing week: $week with runs: $runs'); // Log each week with runs data
        if (runs is Map) {
          runs.forEach((run, details) {
            log('Processing run: $run with details: $details'); // Log each run
            if (details is Map) {
              totalRuns++;
              if (details['completed'] == true) {
                completedRuns++;
              }
            } else {
              log('Invalid details format for run: $run'); // Log invalid format
            }
          });
        } else {
          log('Invalid runs format for week: $week - $runs'); // Log invalid format
        }
      });

      double newProgress = totalRuns > 0 ? completedRuns / totalRuns : 0.0;
      log('Calculated progress: $newProgress (completed: $completedRuns / total: $totalRuns)');
      setState(() {
        _progress = newProgress;
      });
    } else {
      log('runRecommendation is null'); // Log if runRecommendation is null
      setState(() {
        _progress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    log('Building ProgressIndicatorWidget with progress: $_progress');
    // Determine the text color based on the current theme
    Color textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CircularPercentIndicator(
        radius: 100.0,
        lineWidth: 10.0,
        percent: _progress,
        center: Text(
          "${(_progress * 100).toStringAsFixed(1)}%",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: textColor),
        ),
        progressColor: Colors.blue,
      ),
    );
  }
}
