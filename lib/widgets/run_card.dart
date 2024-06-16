import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RunCard extends StatelessWidget {
  final Map<String, dynamic> run;
  final String runKey;

  const RunCard({Key? key, required this.run, required this.runKey});

  Future<void> _deleteRun(BuildContext context, String key) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final runRef = FirebaseDatabase.instance.ref().child('runs').child(user.uid).child(key);
      await runRef.remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Run deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(
          run['distance'] >= 5 ? Icons.directions_run : Icons.directions_walk,
          color: run['distance'] >= 5 ? Colors.green : Colors.blue,
          size: 40.0,
        ),
        title: Text(
          '${run['distance'].toStringAsFixed(2)} mi',
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${run['name'] ?? 'Unnamed Run'}\nTime: ${run['time']}\nPace: ${run['pace']}',
          style: const TextStyle(fontSize: 16.0),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _deleteRun(context, key as String),
              child: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 30.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Icon(
              run['distance'] >= 5 ? Icons.check_circle : Icons.check_circle_outline,
              color: run['distance'] >= 5 ? Colors.green : Colors.grey,
              size: 30.0,
            ),
          ],
        ),
      ),
    );
  }
}
