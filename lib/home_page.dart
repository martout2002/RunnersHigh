import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/gemini_api.dart';
import 'customAppBar.dart';
import 'run_tracking_page.dart';
import 'widgets/progress_indicator.dart';
import 'widgets/recommendation_widget.dart';
import 'widgets/run_list.dart';
import 'widgets/floating_action_button.dart';
import 'dart:developer';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Run Tracker', onToggleTheme: widget.onToggleTheme),
      drawer: const NavDrawer(),
      body: Column(
        children: [
          ProgressIndicatorWidget(runRecommendation: _runRecommendation, pastRuns: _pastRuns),
          if (_runRecommendation != null) Expanded(child: RecommendationWidget(recommendation: _runRecommendation!, pastRuns: _pastRuns)),
          Expanded(child: RunList(pastRuns: _pastRuns)),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(onToggleTheme: widget.onToggleTheme),
    );
  }
}
