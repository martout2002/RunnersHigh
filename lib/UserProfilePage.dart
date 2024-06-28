import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
  var total_km = 0.0;

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
            total_km = data['total_distance'];
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Stack(children: [
          //Image(image: AssetImage('assets/images/banner1.jpg')),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                      child: CircleAvatar(
                        foregroundImage: AssetImage('assets/images/pfp.jpg'),
                        radius: 50,
                      )),
                  const SizedBox(width: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$total_km km",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 40, height: 15),
              Row(
                children: [
                  Text(
                    '          $age years old',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 40),
                  Text(
                    'Goal: $goal',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement edit profile functionality
                  },
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '$num_of_runs runs completed',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
