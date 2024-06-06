import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserProfilePage extends StatefulWidget {
  UserProfilePage({Key? key}) : super(key: key);

  //final DatabaseReference _userRef = FirebaseDatabase.instance.reference().child('users');

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  var name = 'no_name_error';
  var num_of_runs = 0;
  var age = 0;
  var exp = 'no_exp_error';
  var goal = 'no_goal_error';

  DatabaseReference? ref;


  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref().child('profiles').child(user!.uid);
    var ref_runs = FirebaseDatabase.instance.ref().child('runs').child(user!.uid);
    // grabbing realtime database details for profile
    // name
    ref?.child('name').get().then((DataSnapshot? snapshot) {
      if (snapshot != null) {
        setState(() {
          name = snapshot.value.toString();
        });
      } 
    });
    // number of runs
    ref_runs?.child('num_of_runs').get().then((DataSnapshot? snapshot) {
      if (snapshot != null) {
        setState(() {
          num_of_runs = snapshot.children.length as int;
        });
      } 
    });
    // age
    ref?.child('age').get().then((DataSnapshot? snapshot) {
      if (snapshot != null) {
        setState(() {
          age = snapshot.value as int;
        });
      } 
    });
    // experience
    ref?.child('experience').get().then((DataSnapshot? snapshot) {
      if (snapshot != null) {
        setState(() {
          exp = snapshot.value.toString();
        });
      } 
    });
    // goal
    ref?.child('goal').get().then((DataSnapshot? snapshot) {
      if (snapshot != null) {
        setState(() {
          goal = snapshot.value.toString();
        });
      } 
    });
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Runner's Profile"),
    ),
    body: Padding(
      padding: const EdgeInsets.fromLTRB(40, 10, 0 ,0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 50,
              ),
              SizedBox(width: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    exp,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 40, height: 15),
          Row(
            children: [
              Text(
                '          ' + age.toString() + ' years old',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 40),
              Text(
                'Goal: ' + goal,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement edit profile functionality
              },
              child: Text('Edit Profile', style: TextStyle(fontSize: 12),),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              num_of_runs.toString() + ' runs completed',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}