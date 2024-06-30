import 'dart:convert';
//import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:runners_high/appbar/custom_app_bar.dart';
import '../appbar/nav_drawer.dart';
import 'dart:developer';

class RunHistoryPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const RunHistoryPage({super.key, required this.onToggleTheme});

  @override
  _RunHistoryPageState createState() => _RunHistoryPageState();
}

class _RunHistoryPageState extends State<RunHistoryPage> {
  List<Map<String, dynamic>> _pastRuns = [];
  var run;
  var duration;
  var distance;

  @override
  void initState() {
    super.initState();
    _initializeRunData();
  }

  void _initializeRunData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final runRef =
          FirebaseDatabase.instance.ref().child('runs').child(user.uid);
      runRef.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          setState(() {
            _pastRuns = data.keys
                .map((key) =>
                    {'key': key, ...Map<String, dynamic>.from(data[key])})
                .toList();
          });
        } else {
          // Log when there's no data
          log("No run data available");
        }
      }, onError: (error) {
        // Log any errors
        log("Error fetching run data: $error");
      });
    } else {
      // Log when the user is null
      log("User is null");
    }
  }

  void _setVars(run) {
    setState(() {
      //distance = double.tryParse(run['distance']);
      duration = run['duration'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Run History', onToggleTheme: widget.onToggleTheme),
      drawer: const NavDrawer(),
      body: _pastRuns.isEmpty
          ? const Center(child: Text('No runs available'))
          : ListView.builder(
              itemCount: _pastRuns.length,
              itemBuilder: (context, index) {
                final run = _pastRuns[index];
                //_setVars(run);
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: run['image'] != null
                        ? Image.memory(base64Decode(run['image']))
                        : null,
                    title: Text('${run['name'] ?? 'Unnamed Run'}'),
                    subtitle: Text(
                      'Distance: ${run['distance']} km\nTime: ${run['duration'].floor()}m : ${((run['duration'] % 1) * 60).round().toString().padLeft(2, '0')}s \nPace: ${run['pace'].floor()}:${((run['pace'] % 1) * 60).round().toString().padLeft(2, '0')}  min/km',
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RunDetailsPage(
                            run: run, onToggleTheme: widget.onToggleTheme),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

//TODO: Change the rundetailspage into a stateful widget
class RunDetailsPage extends StatefulWidget {
  final Map<String, dynamic> run;
  final VoidCallback onToggleTheme;

  const RunDetailsPage(
      {super.key, required this.run, required this.onToggleTheme});

  @override
  _RunDetailsPageState createState() => _RunDetailsPageState();
}

class _RunDetailsPageState extends State<RunDetailsPage> {
  late List<LatLng> route;

  @override
  void initState() {
    super.initState();
    route = (widget.run['route'] as List<dynamic>)
        .map((point) => LatLng(point['lat'], point['lng']))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Align(
            alignment: Alignment.topRight,
            child: Text(
              widget.run['name'] ?? 'Run Details',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          )),
      // appBar: CustomAppBar(
      //     title: widget.run['name'] ?? 'Run Details', onToggleTheme: widget.onToggleTheme),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: route.isNotEmpty ? route.first : const LatLng(0, 0),
                zoom: 15,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: route,
                  color: Colors.blue,
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Distanced: ${widget.run['distance']} km',
                    style: const TextStyle(fontSize: 18)),
                Text('Duration: ${widget.run['duration']} minutes',
                    style: const TextStyle(fontSize: 18)),
                Text('Pace: ${widget.run['pace']} min/km',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
