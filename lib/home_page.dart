import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/gemini_api.dart';
import 'customAppBar.dart';
import 'run_tracking_page.dart';
import 'recommendation_widget.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double progress = 0.0;
  List<Map<String, dynamic>> _pastRuns = [];
  String? _runRecommendation;
  String? _userGoal;
  late GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
    _checkOnboardingStatus();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      // Location permission is granted
      // Initialize Google Maps or location-based services here
    } else {
      // Location permission is not granted
      if (await Permission.location.isPermanentlyDenied) {
        // Handle the case where the user has permanently denied the permission
        openAppSettings();
      }
    }
  }

  void _checkOnboardingStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      userRef.get().then((snapshot) {
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          if (data['name'] != null && data['age'] != null && data['gender'] != null && data['experience'] != null && data['goal'] != null) {
            if (mounted) {
              setState(() {
                _userGoal = data['goal'];
              });
            }
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
          if (mounted) {
            setState(() {
              _pastRuns = runKeys.map((key) => {'key': key, ...Map<String, dynamic>.from(data[key])}).toList();
            });
          }
          print('Run data initialized: $_pastRuns'); // Debug print statement
          _fetchRunRecommendation();  // Fetch recommendation after initializing run data
        } else {
          _fetchRunRecommendation();  // Fetch recommendation even if there is no run data
        }
      });
    }
  }

  Future<void> _fetchRunRecommendation() async {
    print('Fetching run recommendation...'); // Debug print statement
    final storedRecommendation = await _geminiService.getStoredRecommendation();

    if (storedRecommendation != null) {
      final timestamp = DateTime.parse(storedRecommendation['timestamp']);
      final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

      if (timestamp.isAfter(oneWeekAgo)) {
        if (mounted) {
          setState(() {
            _runRecommendation = storedRecommendation['recommendation'];
          });
        }
        print('Using stored recommendation: $_runRecommendation'); // Debug print statement
        return;
      }
    }

    String? recommendation;
    if (_pastRuns.isEmpty) {
      try {
        recommendation = await _geminiService.getRunRecommendationBasedOnGoal(_userGoal);
      } catch (e) {
        print('Error fetching recommendation based on goal: $e');
      }
    } else {
      final userHistory = _pastRuns.map((run) => "Run on ${run['date']}: ${run['distance']} meters at ${run['pace']} pace").join("\n");
      try {
        recommendation = await _geminiService.getRunRecommendation(userHistory, _userGoal);
      } catch (e) {
        print('Error fetching recommendation: $e');
      }
    }

    if (recommendation != null) {
      await _geminiService.storeRecommendation(recommendation);
      if (mounted) {
        setState(() {
          _runRecommendation = recommendation;
        });
      }
      print('Run recommendation fetched: $_runRecommendation'); // Debug print statement
    }
  }

  void _deleteRun(String key) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final runRef = FirebaseDatabase.instance.ref().child('runs').child(user.uid).child(key);
      runRef.remove().then((_) {
        if (mounted) {
          setState(() {
            _pastRuns.removeWhere((run) => run['key'] == key);
          });
        }
        _fetchRunRecommendation(); // Update recommendation after deleting a run
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
          if (_runRecommendation != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RecommendationWidget(
                  recommendation: _runRecommendation!,
                  pastRuns: _pastRuns,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _pastRuns.length,
              itemBuilder: (context, index) {
                final run = _pastRuns[index];
                final key = run['key']; // Get the key for deletion
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
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${run['name'] ?? 'Unnamed Run'}\nTime: ${run['time']}',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _deleteRun(key),
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
