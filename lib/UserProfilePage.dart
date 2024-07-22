import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:runners_high/popup/changeProfileImage.dart';
import 'package:runners_high/widgets/achievement.dart';
import 'package:runners_high/widgets/profileRunWidget.dart';
import 'package:runners_high/widgets/achievement.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  //final DatabaseReference _userRef = FirebaseDatabase.instance.reference().child('users');

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  var name = "";
  var num_of_runs = 0;
  var age = 0;
  var exp = "err";
  var goal = "err";
  var total_km = 0;
  var profileImage = "";

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
            total_km = data['total_distance'].toInt();
          });
        } else {
          print("No user data available");
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
                        padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
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
                    padding: EdgeInsets.fromLTRB(25, 15, 0, 15),
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
                    padding: EdgeInsets.fromLTRB(25, 10, 0, 25),
                    child: Card(
                      child: Column(
                        children: [
                          Container(
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(25, 15, 0, 15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          AchievementCard(
                              imagePath: "best.png", text: "Best Run"),
                          AchievementCard(imagePath: "1km.png", text: "1 KM"),
                          AchievementCard(imagePath: "5km.png", text: "5 KM"),
                          AchievementCard(imagePath: "10km.png", text: "10 KM"),
                          AchievementCard(imagePath: "21km.png", text: "21 KM"),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(25, 15, 0, 15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          AchievementCard(
                              imagePath: "zombie.png", text: "Dead Run"),
                          AchievementCard(
                              imagePath: "sci.png", text: "Quantum Escape"),
                          AchievementCard(
                              imagePath: "dragon.png",
                              text: "Tales of Fantasia"),
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
