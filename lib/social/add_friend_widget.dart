import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddFriendWidget extends StatefulWidget {
  const AddFriendWidget({Key? key}) : super(key: key);

  @override
  AddFriendWidgetState createState() => AddFriendWidgetState();
}

class AddFriendWidgetState extends State<AddFriendWidget> {
  bool sentAlready = false;
  final TextEditingController _usernameController = TextEditingController();

// write function to add friends here

  // if friend already inside ur friend req list, dont add again
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pendingFriendReq(String? sender, String reciever) async {
    Map<String, dynamic> pendingFriendReq = {};
    final ref =
        FirebaseDatabase.instance.ref().child('profiles').child(reciever);
    final snapshot = await ref.once();
    if (snapshot.snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      print("data real: $data");
      if (data['friend_req'] != null) {
        if (mounted) {
          setState(() {
            pendingFriendReq = Map<String, dynamic>.from(data['friend_req']);
          });
        }
      }

      if (data['friends'] != null) {
        final friends = Map<String, dynamic>.from(data['friends']);
        if (friends.containsValue(sender)) {
          print("dog");
          if (mounted) {
            setState(() {
              sentAlready = true;
            });
            _showDialog(
                "Already Friends", "You are already friends with this user.");
          }
          return;
        }
      }

      if (pendingFriendReq.containsValue(sender)) {
        print("meow");
        if (mounted) {
          setState(() {
            sentAlready = true;
          });
          _showDialog("You have already sent a friend request.",
              "stop being so impatient woof");
        }
      } else {
        var length = pendingFriendReq.length + 1;
        final outgoing_list = pendingFriendReq..addAll({"req$length": sender});

        final updatedPendingFriendReq = {...pendingFriendReq, reciever: sender};

        await ref.child('friend_req').set(outgoing_list);
        //_showDialog("Sent successfully", "meow");
      }
    }
  }

  Future<void> _addFriend() async {
    // Add friend logic here
    final user = FirebaseAuth.instance.currentUser;
    String username = _usernameController.text;
    // finding user's code
    final ref = FirebaseDatabase.instance.ref().child('profiles');
    final snapshot = await ref.once();
    if (snapshot.snapshot.value != null) {
      final data = Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);
      data.forEach((key, value) {
        if (value['username'] == username) {
          // Add friend logic here
          print('Adding friend with code: $key');
          _pendingFriendReq(user?.uid, key);
        }
      });
      // Perform the necessary actions to add the friend
    }
  }

  void _setSetBool() {
    setState(() {
      sentAlready = false;
    });
  }

// write a function to send friend request here ( send user unique id)

  @override
  Widget build(BuildContext context) {
    return sentAlready
        ? AlertDialog(
            title: Text('Friend Request Already Sent'),
            content: Text(
                'You have already sent a friend request to this user. Please wait for them to accept.'),
            actions: [
              TextButton(
                onPressed: () {
                  _setSetBool();
                  Navigator.of(context).pop();
                },
                child: Text('Ok'),
              ),
            ],
          )
        : AlertDialog(
            title: Text('Add Friend'),
            content: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Add friend logic here
                  String username = _usernameController.text;
                  print('Adding friend with username: $username');
                  if (sentAlready) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Friend Request Already Sent'),
                            content: Text(
                                'You have already sent a friend request to this user'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _setSetBool();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Ok'),
                              ),
                            ],
                          );
                        });
                  } else {
                    _addFriend();
                    // Perform the necessary actions to add the friend
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Add'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
  }
}
