import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'customAppBar.dart';
import 'run_tracking_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double progress = 0.0;
  List<Map<String, dynamic>> _pastRuns = [];

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  void _checkOnboardingStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      userRef.get().then((snapshot) {
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          if (data['name'] != null && data['age'] != null && data['gender'] != null && data['experience'] != null && data['goal'] != null) {
            _initializeRunData();
          } else {
            Navigator.pushReplacementNamed(context, '/onboarding');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      }).catchError((error) {
        // Handle the error here
        print('Error fetching user data: $error');
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _initializeRunData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final runRef = FirebaseDatabase.instance.ref().child('runs').child(user.uid);
      runRef.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final runKeys = data.keys.toList();
          setState(() {
            _pastRuns = runKeys.map((key) => {'key': key, ...Map<String, dynamic>.from(data[key])}).toList();
          });
        }
      });
    }
  }

  void _deleteRun(String key) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final runRef = FirebaseDatabase.instance.ref().child('runs').child(user.uid).child(key);
      runRef.remove().then((_) {
        setState(() {
          _pastRuns.removeWhere((run) => run['key'] == key);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Run Tracker', onToggleTheme: widget.onToggleTheme),
      drawer: const NavDrawer(), // Add the NavDrawer
      body: Column(
        children: [
          Padding(
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
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _pastRuns.length,
              itemBuilder: (context, index) {
                final run = _pastRuns[index];
                final key = run['key']; // Get the key for deletion
                return ListTile(
                  title: Text(run['name'] ?? 'Unnamed Run'),
                  subtitle: Text('Distance: ${run['distance'].toStringAsFixed(2)} meters, Pace: ${run['pace'].toStringAsFixed(2)} min/km'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteRun(key);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RunTrackingPage(onToggleTheme: widget.onToggleTheme),
            ),
          );
        },
        child: const Icon(Icons.run_circle),
      ),
    );
  }
}
