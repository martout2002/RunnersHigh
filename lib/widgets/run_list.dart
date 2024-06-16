import 'package:flutter/material.dart';
import 'run_card.dart';

class RunList extends StatelessWidget {
  final List<Map<String, dynamic>> pastRuns;

  const RunList({Key? key, required this.pastRuns}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pastRuns.length,
      itemBuilder: (context, index) {
        final run = pastRuns[index];
        final key = run['key'];
        return RunCard(run: run, key: key, runKey: '',);
      },
    );
  }
}
