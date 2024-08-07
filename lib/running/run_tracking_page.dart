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
import 'package:runners_high/running/checkAchievements.dart';

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
  bool _completedMission = false;
  var kmRequired = 0.0;
  String campaignId = "";
  var mission = "";
  var campaignLength = 0;
  var userAchievements = <String>[];
  var userCompletedCampaigns;

  late StreamSubscription _missionSubscription;
  late StreamSubscription _campaignSubscription;
  late StreamSubscription kmListener;

  AchievementChecker achievementChecker = AchievementChecker();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _requestLocationPermission();
    _getCurrentLocationAndSetMap();
    _accessCurrentMissionData();
    
    
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    _missionSubscription.cancel();
    kmListener.cancel();
    _campaignSubscription.cancel();
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
      final user = FirebaseDatabase.instance.ref().child('profile').child(_user!.uid);
      user.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final userData = Map<String, dynamic>.from(event.snapshot.value as Map);
          if (userData['achievements'] != null) {
            userAchievements = userData['achievements'];
          } else {
            print("obv it dont exists dog");
            userAchievements ??= <String>[];
          }
        } else {
          userAchievements ??= <String>[];
        }
      });
    }

    print("users achievements: $userAchievements");
  
  }

  void _accessCurrentMissionData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      _missionSubscription = ref.onValue.listen((event) {
        final eventValue = event.snapshot.value;
        if (eventValue != null) {
          final data = Map<String, dynamic>.from(eventValue as Map);
          if (data['currentCampaign'] != null) {
            if (mounted) {
              setState(() {
                campaignId = data['currentCampaign'];
                
              });
            }
            if (data['currentMission'] != null) {
              if (mounted) {
                setState(() {
                  mission = data['currentMission'];
                });
              }
              
            }
          }
        }
        print("Setting some shit now");
        if (mission != 'null' || mission != null) {
          _getKmRequired(campaignId, mission);
        }
        
      }, onError: (error) {
        // Log any errors
      });
    }
  }

  void _reSelectCurrentMission(String campaignId, String missionId) {
    var length = 0;
    final campaignRef =
        FirebaseDatabase.instance.ref().child('Campaign').child(campaignId);
    campaignRef.onValue.listen((event) {
      final eventValue = event.snapshot.value;
      if (eventValue != null) {
        final data = Map<String, dynamic>.from(eventValue as Map);
        setState(() {
          length = data['num_of_runs'];
        });

        if (mounted) {
          int mission_as_int = int.parse(missionId.substring(1));
          if (mission_as_int < data['num_of_runs']) {
            _setCurrentMission("m${mission_as_int + 1}");
          } else {
            _setCurrentMission('null');
          }
        }
        
      }
    }, onError: (error) {
      // Log any errors
    });
    
  }

  void _setCurrentMission(String id) {
    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final ref =
            FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
        if (id == 'null') {
          ref.child('currentMission').set('null');
        } else {
          ref.child('currentMission').set(id);
        }
      }
    }
  }

  void _checkCompletedMission() {
    if (_distance >= kmRequired) {
      print("mission completed!");
      if (mission != null || mission != 'null') {
        _reSelectCurrentMission(campaignId, mission);
        _updateUserCompletedMissions(mission);
      }
      
    }
  }

  void _updateUserCompletedMissions(String mission) {
    var completedList = [];
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      _campaignSubscription = ref.onValue.listen((event) {
        final eventValue = event.snapshot.value;
        if (eventValue != null) {
          final data = Map<String, dynamic>.from(eventValue as Map);
          // print("data inside updating completed missions here: $data");
          // print("data inside updating completed missions for thing: ${data['completedMissions']}");
          if (data['completedMissions'] != null) {
            // print("campaign id is like this: $campaignId");
            // print("looking at CID inside update back: ${data["completedMissions"]["C1"]}");
            if (data['completedMissions'][campaignId] != null) {
              // we found our campaign missions here now we need to add it to the map
              var x = data['completedMissions'][campaignId];
              // print("x is here: $x");
              final outgoing_list = x..addAll({mission: " "});
              ref.child('completedMissions').child(campaignId).set(outgoing_list);
            } else {
              if (campaignId != "null") {
                final missionsList = data['completedMissions'];
                final outgoing_list = {...missionsList, campaignId: {mission: " "}};
                ref.child('completedMissions').set(outgoing_list);
              }
              
            }
          } else {
            final outgoing_list = {campaignId: {mission: " "}};
            ref.child('completedMissions').set(outgoing_list);
          }
        }
      }, onError: (error) {
        // Log any errors
      });
    }
  }

  void _getKmRequired(campaign, mission) {
    print("campaign: $campaign");
    print("missions: $mission");
    final ref = FirebaseDatabase.instance
        .ref()
        .child('Campaign')
        .child(campaign)
        .child('missions')
        .child(mission);
    kmListener = ref.onValue.listen((event) {
      final eventValue = event.snapshot.value;
      if (eventValue != null) {
        final data = Map<dynamic, dynamic>.from(eventValue as Map);
        //print("km is here: ${data['km']}");
        if (data['km'] != null) {
          if (mounted) {
            setState(() {
              kmRequired = data['km'].toDouble();
            });
          }
        }
      }
    }, onError: (error) {
      // Log any errors
    });
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
  Future<void> updateAchievements() async {
    if (userAchievements != null) {
      final ref = FirebaseDatabase.instance.ref().child('profiles');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        ref.child(user.uid).update({
            'achievements': Map.fromIterable(userAchievements, key: (item) => item, value: (_) => true),
        });
      }
    } 
  }

  Future<void> completedCampaign(String cName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      ref.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final completedData = data['completedCampaigns'];
          if (completedData == null) {
            // just upload 
            ref.child(user.uid).update({
              'completedCampaigns': {cName : cName},
            });

          } else {
            // parse data
            userCompletedCampaigns = completedData.keys.toList();
            userCompletedCampaigns.add(cName);
            ref.child(user.uid).update({
              'completedCampaigns': Map.fromIterable(userCompletedCampaigns, key: (item) => item, value: (_) => cName),
            });
          }
          
        }
      });
    }
  }

  Future<void> checkCampaigns() async {



    if (campaignId == 'C1' && mission == 'm5') {
      completedCampaign('C1');
    } else if (campaignId == 'C2' && mission == 'm8') { 
      completedCampaign('C2');
    } else if (campaignId == 'C3' && mission == 'm15'){
      completedCampaign('C3');

    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      ref.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          if (data['completedMissions'] != null) {
            if (data['completedMissions'][campaignId] != null) {
              setState(() {
                _completedMission = true;
              });
            }
          }
        }
      });
    }
  }

  Future<void> checkAchievements(double distance) async {
    if (userAchievements != null) {
      if (distance >= 1 && !userAchievements.contains('1km')) {
        print('it hit 1km');
        userAchievements.add('1km');
      }
      if (distance >= 5 && !userAchievements.contains('5km')) {
        userAchievements.add('5km');
      }
      if (distance >= 10 && !userAchievements.contains('10km')) {
        userAchievements.add('10km');
      }
      if (distance >= 21 && !userAchievements.contains('21km')) {
        userAchievements.add('21km');
      }
      print("new achievements meow: $userAchievements");
      await updateAchievements();
    } else {
      print("accc error");
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
        _checkCompletedMission();
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
        checkAchievements(_distance);
        //achievementChecker.checkAchievements(_distance);
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
              zoom: 14,
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
