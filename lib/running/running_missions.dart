import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:runners_high/running/campaign_missions_display_page.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({Key? key}) : super(key: key);

  @override
  CampaignPageState createState() => CampaignPageState();
}

class CampaignPageState extends State<CampaignPage> {
  List<Map<String, dynamic>> _campaigns = [];
  var _userCurrentCampaign = "null";

  @override
  void initState() {
    super.initState();
    _initCampaignData();
    _checkCurrentCampaign();
  }

  void _checkCurrentCampaign() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      ref.onValue.listen((event) {
        final eventValue = event.snapshot.value;
        if (eventValue != null) {
          final data = Map<String, dynamic>.from(eventValue as Map);
          if (data['currentCampaign'] != null) {
            setState(() {
              _userCurrentCampaign = data['currentCampaign'];
            });
          }
        }
      }, onError: (error) {
        // Log any errors
      });
    }
  }

  void _initCampaignData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final campaignRef = FirebaseDatabase.instance.ref().child('Campaign');
      campaignRef.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          print(data);
          setState(() {
            _campaigns = data.keys
                .map((key) =>
                    {'id': key, ...Map<String, dynamic>.from(data[key])})
                .toList();
          });
          _campaigns.sort((a, b) => a['id'].compareTo(b['id']));
        } else {}
      }, onError: (error) {});
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Campaign',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold)),
            backgroundColor: const Color.fromARGB(255, 60, 60, 60)),
        body: Container(
          color: const Color.fromARGB(255, 20, 20, 20),
          child: ListView.builder(
            itemCount: _campaigns.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final campaign = _campaigns[index];
              final campaignId = campaign['id'];
              final km = campaign['km'];
              final num_of_runs = campaign['num_of_runs'];

              return CampaignBanner(
                image: AssetImage("assets/images/$campaignId.png"),
                text: "$num_of_runs Missions | $km km",
                subtitle: campaign['subText'],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CampaignMissionsDisplayPage(
                              campaignId: campaignId,
                              currentCampaign:
                                  _userCurrentCampaign == campaignId,
                            )),
                  );
                },
                currentCampaign: _userCurrentCampaign == campaignId,
              );
            },
          ),
        ));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //         title: const Text('Campaign',
  //             style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 24.0,
  //                 fontWeight: FontWeight.bold)),
  //         backgroundColor: Color.fromARGB(255, 60, 60, 60)),
  //     body: Container(
  //       color: const Color.fromARGB(255, 20, 20, 20),
  //       child: ListView(
  //         padding: EdgeInsets.all(16.0),
  //         children: [
  //           CampaignBanner(
  //             image: AssetImage('assets/images/C1.png'),
  //             text: '5 Missions | 25 km',
  //             subtitle:
  //                 'Hurry we need your insane running and parkour skills to save the last of humanity!',
  //             onPressed: () {},
  //           ),
  //           CampaignBanner(
  //             image: AssetImage('assets/images/C2.png'),
  //             text: '8 Missions | 42 Km',
  //             subtitle:
  //                 'Stranded. You must journey through the barren rocky wastelands of Jupiter to find your way home!',
  //             onPressed: () {},
  //           ),
  //           CampaignBanner(
  //             image: AssetImage('assets/images/C3.png'),
  //             text: '14 Missions | 132 Km',
  //             subtitle:
  //                 'Are you up to the challenge? Journey accross the kingdom and slay the red dragon smog!',
  //             onPressed: () {},
  //           ),
  //           // Add more CampaignBanners as needed
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class CampaignBanner extends StatefulWidget {
  final ImageProvider image;
  final String text;
  final String subtitle;
  final VoidCallback onPressed;
  final bool currentCampaign;

  const CampaignBanner(
      {super.key,
      required this.image,
      required this.text,
      required this.subtitle,
      required this.onPressed,
      required this.currentCampaign});

  @override
  CampaignBannerState createState() => CampaignBannerState();
}

class CampaignBannerState extends State<CampaignBanner> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Card(
        color: const Color.fromARGB(
            255, 40, 40, 40), // Set the background color of the Card
        child: Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment
                    .topRight, // Position the tick on the top right of the image
                children: [
                  Image(image: widget.image),
                  if (widget
                      .currentCampaign) // Only show if currentCampaign is true
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      decoration: const BoxDecoration(
                        color: Colors.green, // Background color of the tick
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Current Campaign',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8.0),
              Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 119, 189, 253),
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  widget.subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
