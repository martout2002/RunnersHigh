import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'customAppBar.dart';

class RunTrackingPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const RunTrackingPage({super.key, required this.onToggleTheme});

  @override
  RunTrackingPageState createState() => RunTrackingPageState();
}

class RunTrackingPageState extends State<RunTrackingPage> {
  bool _isRecording = false;
  bool _isPaused = false;
  double _distance = 0.0;
  double _pace = 0.0;
  Duration _duration = const Duration();
  Timer? _timer;
  final List<LatLng> _route = [];
  GoogleMapController? _mapController;
  Position? _lastPosition;
  DatabaseReference? _runRef;
  User? _user;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _requestLocationPermission();
    _getCurrentLocationAndSetMap();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _checkAuthentication() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _initializeRunData();
    }
  }

  void _initializeRunData() {
    if (_user != null) {
      _runRef = FirebaseDatabase.instance.ref().child('runs').child(_user!.uid);
    }
  }

  Future<void> _requestLocationPermission() async {
    await Geolocator.requestPermission();
  }

  Future<void> _getCurrentLocationAndSetMap() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _lastPosition = position;
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ));
    }
  }

  void _startStopRun() async {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _timer?.cancel();
      });
      await _saveRun();
    } else {
      setState(() {
        _isRecording = true;
        _isPaused = false;
        _distance = 0.0;
        _pace = 0.0;
        _duration = const Duration();
        _route.clear();
        _startTimer();
      });
      await _initializeGoogleMapsAndStartTracking();
    }
  }

  void _pauseResumeRun() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _timer?.cancel();
      } else {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _duration += const Duration(seconds: 1);
          if (_distance > 0) {
            _pace = _duration.inMinutes / (_distance / 1000); // minutes per km
          }
        });
      }
    });
  }

  Future<void> _initializeGoogleMapsAndStartTracking() async {
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _mapController?.animateCamera(CameraUpdate.newLatLng(
      LatLng(position.latitude, position.longitude),
    ));
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      if (_isRecording && !_isPaused) {
        if (_lastPosition != null) {
          _distance += Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );
        }
        setState(() {
          _lastPosition = position;
          _route.add(LatLng(position.latitude, position.longitude));
        });
      }
    });
  }

  Future<void> _saveRun() async {
    if (_user != null) {
      String? runName = await _showRunNameDialog();
      if (runName != null) {
        final run = {
          'name': runName,
          'distance': _distance,
          'duration': _duration.inSeconds,
          'pace': _pace,
          'route': _route.map((latLng) => {'lat': latLng.latitude, 'lng': latLng.longitude}).toList(),
          'timestamp': DateTime.now().toIso8601String(),
        };
        _runRef?.push().set(run);
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      
    }
  }

  Future<String?> _showRunNameDialog() async {
    String? runName;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Name your run'),
          content: TextField(
            onChanged: (value) {
              runName = value;
            },
            decoration: const InputDecoration(hintText: "Enter run name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(runName);
              },
            ),
          ],
        );
      },
    );
    return runName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Tracker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.light_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      drawer: const NavDrawer(),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              if (_lastPosition != null) {
                _mapController!.animateCamera(CameraUpdate.newLatLng(
                  LatLng(_lastPosition!.latitude, _lastPosition!.longitude),
                ));
              }
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0), // Placeholder, will be updated to user's location
              zoom: 12,
            ),
            myLocationEnabled: true, // Enable the user's location
            myLocationButtonEnabled: true,
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                visible: true,
                points: _route,
                color: Colors.blue,
              ),
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white.withOpacity(0.8),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('Distance', '${_distance.toStringAsFixed(2)} km'),
                      _buildStatCard('Pace', '${_pace.toStringAsFixed(2)} min/km'),
                      _buildStatCard('Duration', _duration.toString().split('.').first),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _startStopRun,
                        child: Text(_isRecording ? 'Stop Run' : 'Start Run'),
                      ),
                      const SizedBox(width: 10),
                      if (_isRecording)
                        ElevatedButton(
                          onPressed: _pauseResumeRun,
                          child: Text(_isPaused ? 'Resume' : 'Pause'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
