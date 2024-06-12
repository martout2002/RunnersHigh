import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/gemini_api.dart';
import 'customAppBar.dart';
import 'run_tracking_page.dart';
import 'recommendation_widget.dart';
import 'dart:developer';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double progress = 0.0;
  List<Map<String, dynamic>> _pastRuns = [];
  Map<String, dynamic>? _runRecommendation;
  String? _userGoal;
  String? _userPace;
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
      // Location permission is granted, initialize location-based services here
    } else {
      if (await Permission.location.isPermanentlyDenied) {
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
          if (data['goal'] != null && data['pace'] != null) {
            if (mounted) {
              setState(() {
                _userGoal = data['goal'];
                _userPace = data['pace'];
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
        log('Error fetching user data: $error');
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
          if (mounted) {
            setState(() {
              _pastRuns = data.keys.map((key) => {'key': key, ...Map<String, dynamic>.from(data[key])}).toList();
            });
          }
          _fetchRunRecommendation();
        } else {
          _fetchRunRecommendation();
        }
      });
    }
  }

  Future<void> _fetchRunRecommendation() async {
    final storedRecommendation = await _geminiService.getStoredRecommendation();
    if (storedRecommendation != null) {
      final timestamp = DateTime.parse(storedRecommendation['timestamp']);
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      if (timestamp.isAfter(oneWeekAgo)) {
        if (mounted) {
          setState(() {
            _runRecommendation = Map<String, dynamic>.from(storedRecommendation['recommendation']);
          });
        }
        _updateProgress();
        return;
      }
    }

    String? recommendation;
    if (_pastRuns.isEmpty) {
      recommendation = await _geminiService.getRunRecommendationBasedOnGoal(_userGoal, _userPace);
    } else {
      final userHistory = _pastRuns.map((run) => "Run on ${run['date']}: ${run['distance']} meters at ${run['pace']} pace").join("\n");
      recommendation = await _geminiService.getRunRecommendation(userHistory, _userGoal, _userPace);
    }

    if (recommendation != null) {
      await _geminiService.storeRecommendation(recommendation);
      if (mounted) {
        setState(() {
          _runRecommendation = _geminiService.processRecommendation(recommendation!);
        });
      }
    }
    _updateProgress();
  }

  void _updateProgress() {
    if (_runRecommendation != null) {
      int totalRuns = 0;
      int completedRuns = 0;

      _runRecommendation!.forEach((week, runs) {
        runs.forEach((run, details) {
          if (_isValidRun(details)) {  // Ensure only valid runs are counted
            totalRuns++;
            if (_checkIfRunCompleted(details)) {
              completedRuns++;
            }
          }
        });
      });

      setState(() {
        progress = totalRuns > 0 ? completedRuns / totalRuns : 0.0;
      });
    }
  }

  bool _isValidRun(String details) {
    return details.contains('Run') && details.contains('m') && details.contains('pace');
  }

  bool _checkIfRunCompleted(String details) {
    for (var run in _pastRuns) {
      if (details.contains(run['distance'].toString()) && details.contains(run['pace'])) {
        return true;
      }
    }
    return false;
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
        _fetchRunRecommendation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Run Tracker', onToggleTheme: widget.onToggleTheme),
      drawer: const NavDrawer(),
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
                final key = run['key'];
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
