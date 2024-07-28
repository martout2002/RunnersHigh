// ignore_for_file: file_names

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:runners_high/popup/changeProfileImage.dart';
import 'package:runners_high/widgets/achievement.dart';
import 'package:runners_high/widgets/profileRunWidget.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  //final DatabaseReference _userRef = FirebaseDatabase.instance.reference().child('users');

  @override
  // ignore: library_private_types_in_public_api
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  var name = "";
  // ignore: non_constant_identifier_names
  var num_of_runs = 0;
  var age = 0;
  var exp = "err";
  var goal = "err";
  // ignore: non_constant_identifier_names
  var total_km = 0;
  var profileImage = "";
  late var achievementsList;
  late var completedCampaigns;

  // DatabaseReference? ref;

  void _getUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      ref.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          setState(() {
            name = data['name'];
            num_of_runs = data['num_of_runs'];
            age = data['age'];
            exp = data['experience'];
            goal = data['goal'];
            if (data['profile_image'] != null) {
              profileImage = data['profile_image'];
            }
            final userMap = data['achievements'];
            achievementsList = userMap.keys.toList();
            final userMappers = data['completedCampaign'];
            completedCampaigns = userMappers.keys.toList();
            
            total_km = data['total_distance'].toInt();
          });
        } 
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  //testing user git push on mac
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Runner's Profile"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Stack(
            children: [
              //Image(image: AssetImage('assets/images/banner1.jpg')),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const ChangeProfileImage();
                              },
                            );
                          },
                          child: CircleAvatar(
                            foregroundImage: profileImage == ""
                                ? const AssetImage('assets/images/pfp.jpg')
                                : MemoryImage(base64Decode(profileImage)),
                            radius: 50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display Name here
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Display total km ran here
                          Text(
                            "$age years old",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 40, height: 30),
                  Text(
                    "        My Stats",
                    style: GoogleFonts.kanit(
                      textStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 15, 0, 15),
                    child: Row(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 0),
                                  child: ProfileRunWidget(
                                      num_of_runs, 'Activities'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: ProfileRunWidget(total_km, 'KM'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: ProfileRunWidget(20, 'Hours'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "        My Goal",
                    style: GoogleFonts.kanit(
                      textStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 10, 0, 25),
                    child: Card(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 60,
                            width: 350, // Specify the desired width
                            child: Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "  $goal",
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "        Achievements",
                    style: GoogleFonts.kanit(
                      textStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25, 15, 0, 15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const AchievementCard(
                              imagePath: "best.png", text: "Best Run"),
                          AchievementCard(imagePath: achievementsList.contains("1km") ? "1km.png" : 
                          "!1km.png", text: achievementsList.contains("1km") ? "1km" : 
                          "Not Yet"),
                          AchievementCard(imagePath: achievementsList.contains("5km") ? "5km.png" : 
                          "!5km.png", text: achievementsList.contains("5km") ? "5km" : 
                          "Not Yet"),
                          AchievementCard(imagePath: achievementsList.contains("10km") ? "10km.png" : 
                          "!10km.png", text: achievementsList.contains("10km") ? "10km" : 
                          "Not Yet"),
                          AchievementCard(imagePath: achievementsList.contains("21km") ? "21km.png" : 
                          "!21km.png", text: achievementsList.contains("21km") ? "21km" : 
                          "Not Yet"),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Text(
                      "        Campaigns Completed",
                      style: GoogleFonts.kanit(
                        textStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(25, 15, 0, 15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          AchievementCard(imagePath: completedCampaigns.contains("C1") ? "zombie.png" : "!zombie.png", 
                          text: completedCampaigns.contains("C1") ? "Dead Run" : "Not Yet"),
                          AchievementCard(
                              imagePath: completedCampaigns.contains("C2") ? "sci.png" : "!sci.png", text: completedCampaigns.contains("C2") ? "Quantum Escape" : "Not Yet"),
                          AchievementCard(
                              imagePath: completedCampaigns.contains("C3") ? "dragon.png" : "!dragon.png", text: completedCampaigns.contains("C3") ? "Tales of Fantasia" : "Not Yet",
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
