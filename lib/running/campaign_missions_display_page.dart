import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CampaignMissionsDisplayPage extends StatefulWidget {
  final String campaignId;
  final bool currentCampaign;

  CampaignMissionsDisplayPage(
      {required this.campaignId, Key? key, required this.currentCampaign});

  @override
  _CampaignMissionsDisplayPageState createState() =>
      _CampaignMissionsDisplayPageState();
}

class _CampaignMissionsDisplayPageState
    extends State<CampaignMissionsDisplayPage> {
  List<Map<dynamic, dynamic>> _campaignData = [];
  List<Map<dynamic, dynamic>> _campaignMissions = [];
  List<dynamic> _userCompletedMissions = [];
  var campaignName = 'Campaign';
  late bool currentCampaignAccurate;

  @override
  void initState() {
    super.initState();
    _initCampaignData();
    _setBoolean();
    _checkCompletedMissions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setBoolean() {
    if (mounted) {
      setState(() {
        currentCampaignAccurate = widget.currentCampaign;
      });
    }
  }

  void _initCampaignData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final campaignRef = FirebaseDatabase.instance
          .ref()
          .child('Campaign')
          .child(widget.campaignId);
      campaignRef.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
          print("data : $data");

          setState(() {
            _campaignData = data.keys.map((key) {
              // Check if the value is a map and handle accordingly
              if (data[key] is Map) {
                return {'id': key, ...Map<dynamic, dynamic>.from(data[key])};
              } else {
                // For non-map values, just return a simple map with 'id' and 'value'
                return {'id': key, 'value': data[key]};
              }
            }).toList();

            campaignName = data['name'] ?? 'Campaign';

            // Assuming _campaignMissions needs to be populated from the 'missions' map
            if (data.containsKey('missions') && data['missions'] is Map) {
              var missionsData = Map<dynamic, dynamic>.from(data['missions']);
              _campaignMissions = missionsData.keys.map((key) {
                return {
                  'id': key,
                  ...Map<dynamic, dynamic>.from(missionsData[key])
                };
              }).toList();
            } else {
              _campaignMissions = [];
            }

            _campaignMissions = data['missions']
                .keys
                .map((key) {
                  var missionData = data['missions'][key];
                  if (missionData is Map) {
                    // This ensures that each element in the list is a Map<dynamic, dynamic>
                    return {
                      'id': key,
                      ...Map<dynamic, dynamic>.from(missionData)
                    };
                  } else {
                    // If the missionData is not a map, we need to handle this case.
                    // For example, you might want to skip this element or handle it differently.
                    // Here, we'll return null for non-map values, and then filter them out.
                    return null;
                  }
                })
                .where((element) => element != null)
                .cast<Map<dynamic, dynamic>>()
                .toList();
          });
        }
      });
    }
  }

  void _setCurrentCampaign() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      ref.child('currentCampaign').set(widget.campaignId);
    }
    if (mounted) {
      setState(() {
        currentCampaignAccurate = true;
      });
    }
  }

  void _unsetCurrentCampaign() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      ref.child('currentCampaign').set('null');
    }
    if (mounted) {
      setState(() {
        currentCampaignAccurate = false;
      });
    }
  }

  void _checkCompletedMissions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);

      ref.onValue.listen((event) {
        final eventValue = event.snapshot.value;
        if (eventValue != null) {
          final data = Map<String, dynamic>.from(eventValue as Map);
          print(data['completedMissions']);
          print(data['completedMissions']['C1']);
          if (data['completedMissions'] != null) {
            if (data['completedMissions'][widget.campaignId] != null) {
              setState(() {
                _userCompletedMissions =
                    data['completedMissions'][widget.campaignId].keys.toList();
              });
              print(_userCompletedMissions);
            }
          }
        }
      }, onError: (error) {
        // Log any errors
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$campaignName Missions',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 60, 60, 60),
        actions: [
          IconButton(
            icon: currentCampaignAccurate
                ? Image.asset('assets/images/MinusMap.png')
                : Image.asset('assets/images/PlusMap.png'),
            onPressed: () {
              currentCampaignAccurate
                  ? _unsetCurrentCampaign()
                  : _setCurrentCampaign();
            },
          ),
        ],
      ), // Example indices of completed missions

      body: Container(
        color: const Color.fromARGB(255, 20, 20, 20),
        child: GridView.count(
          crossAxisCount: 2,
          children: _campaignMissions.asMap().entries.map((entry) {
            int index = entry.key;
            int indexMinus = index + 1;
            var mission = entry.value;
            bool isCompleted = _userCompletedMissions
                .contains("M$indexMinus"); // Check if mission is completed
            return Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Color.fromARGB(255, 47, 77, 48)
                    : const Color.fromARGB(
                        255, 40, 40, 40), // Green if completed
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${mission['name']}', // Prepend the mission name with its index
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${mission['km']} km',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 119, 189, 253),
                    ),
                  ),
                  Text('${mission['flavor']}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
