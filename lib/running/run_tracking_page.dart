import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:runners_high/appbar/nav_drawer.dart';
import 'package:runners_high/appbar/custom_app_bar.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class RunTrackingPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const RunTrackingPage({super.key, required this.onToggleTheme});

  @override
  RunTrackingPageState createState() => RunTrackingPageState();
}

class RunTrackingPageState extends State<RunTrackingPage> {
  var minLat;
  var maxLat;
  var minLng;
  var maxLng;
  late StreamSubscription userStreamSubscription;
  var num_of_runs = 0;
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
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _lastPosition = position;
      minLat = position.latitude;
      maxLat = position.latitude;
      minLng = position.longitude;
      maxLng = position.longitude;
    });
    if (_mapController != null && _lastPosition != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(
        LatLng(_lastPosition!.latitude, _lastPosition!.longitude),
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
            _pace = _duration.inSeconds / 60 / (_distance); // minutes per km
          }
        });
      }
    });
  }

  Future<void> _initializeGoogleMapsAndStartTracking() async {
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _lastPosition = position;
    });
    if (_mapController != null && _lastPosition != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(
        LatLng(_lastPosition!.latitude, _lastPosition!.longitude),
      ));
    }
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      if (_isRecording && !_isPaused) {
        setState(() {
          if (_lastPosition != null) {
            _distance += Geolocator.distanceBetween(
                  _lastPosition!.latitude,
                  _lastPosition!.longitude,
                  position.latitude,
                  position.longitude,
                ) /
                1000; // Convert meters to kilometers
          }
          if (position.latitude < minLat) minLat = position.latitude;
          if (position.latitude > maxLat) maxLat = position.latitude;
          if (position.longitude < minLng) minLng = position.longitude;
          if (position.longitude > maxLng) maxLng = position.longitude;

          _lastPosition = position;
          _route.add(LatLng(position.latitude, position.longitude));
          if (_distance > 0) {
            _pace = _duration.inSeconds / 60 / (_distance); // minutes per km
          }
        });
      }
    });
  }

  Future<void> updateUserRuns(String dist) async {
    double _distance = double.parse(dist);
    final ref =
        FirebaseDatabase.instance.ref().child('profiles').child(_user!.uid);
    if (ref != null) {
      userStreamSubscription = ref.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final userData =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          //update user profile num of runs
          userStreamSubscription.cancel();
          ref.update({'num_of_runs': userData['num_of_runs'] + 1});
          ref.update(
              {'total_distance': userData['total_distance'] + _distance});
        } else {
          print("No user data available");
        }
      });
    }
  }

  Future<void> _saveRun() async {
    if (_lastPosition != null && _mapController != null) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
      // _mapController!
      //     .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      //   target: LatLng(_lastPosition!.latitude, _lastPosition!.longitude),
      //   zoom: 18.0, // Adjust the zoom level as needed
      // )));
      CameraUpdate update =
          CameraUpdate.newLatLngBounds(bounds, 100); // 50 is the padding
      _mapController!.animateCamera(update);
    }
    if (_user != null) {
      String? runName = await _showRunNameDialog();
      updateUserRuns(_distance.toStringAsFixed(2));
      if (runName != null) {
        String? imageString;
        // Take a snapshot of the map
        final Uint8List? mapSnapshot = await _mapController?.takeSnapshot();
        File? imageFile;
        if (mapSnapshot != null) {
          // Get the path to the app's temporary directory
          final Directory tempDir = await getTemporaryDirectory();
          final String tempPath = tempDir.path;
          // Compress the image
          final Uint8List compressedImage =
              await FlutterImageCompress.compressWithList(
            mapSnapshot,
            minWidth: 600,
            minHeight: 800,
            quality: 88,
          );

          // Write the image to a file
          imageFile = File('$tempPath/map_snapshot.png');
          await imageFile.writeAsBytes(compressedImage, flush: true);

          if (imageFile != null) {
            // Read the image file as a list of bytes
            final bytes = await imageFile.readAsBytes();

            // Encode the bytes in Base64 and create a data URL
            imageString = base64Encode(bytes);
          }

          // TODO: Upload the image file to a server or cloud storage
        }
        final run = {
          'name': runName,
          'distance': _distance.toStringAsFixed(2),
          'duration': (_duration.inSeconds / 60.0 * 100).round() / 100.0,
          'pace': (_pace * 100).round() / 100.0,
          'route': _route
              .map(
                  (latLng) => {'lat': latLng.latitude, 'lng': latLng.longitude})
              .toList(),
          'timestamp': DateTime.now().toIso8601String(),
          'image': imageString,
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
              target: LatLng(
                  0, 0), // Placeholder, will be updated to user's location
              zoom: 20,
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
                      _buildStatCard(
                          'Distance', '${_distance.toStringAsFixed(2)} km'),
                      _buildStatCard(
                          'Pace', '${_pace.toStringAsFixed(2)} min/km'),
                      _buildStatCard(
                          'Duration', _duration.toString().split('.').first),
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
