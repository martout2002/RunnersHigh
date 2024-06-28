import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:runners_high/social/accept_friend_widget.dart';
import 'package:runners_high/social/add_friend_widget.dart';
import 'package:firebase_database/firebase_database.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({Key? key}) : super(key: key);

  @override
  FriendPageState createState() => FriendPageState();
}

class FriendPageState extends State<FriendPage> {
  var friends;

  void init_data() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      ref.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          setState(() {
            friends = data['friends'];
          });
        } else {
          print("No user data available");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var friends;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Page'),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.assignment_ind_sharp),
              onPressed: () {
                //widget here
                showDialog(
                    context: context,
                    builder: (context) {
                      return AcceptFriendWidget();
                    });
              }),
          IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                // accepting page
                showDialog(
                    context: context,
                    builder: (context) {
                      return AddFriendWidget();
                    });
              }),
        ],
      ),
      body: Center(
          child: friends == null
              ? Text('Time to get friends')
              : ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    // return friend item widget here
                  },
                  // If the person has no friends, display a text saying "Time to get friends"
                )),
    );
  }
}
