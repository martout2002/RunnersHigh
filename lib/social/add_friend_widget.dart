import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddFriendWidget extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();

// write function to add friends here

  Future<void> _pendingFriendReq(String? sender, String reciever) async {
    final ref =
        FirebaseDatabase.instance.ref().child('profiles').child(reciever);
    final snapshot = await ref.once();
    if (snapshot.snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      print("data real: $data");
      final pendingFriendReq = data['friend_req'];
      // Perform the necessary actions to add the friend
      print('Pending friend requests: $pendingFriendReq');

      print('current list');
      var length = pendingFriendReq.length + 1;
      final outgoing_list = pendingFriendReq..addAll({"req$length": sender});

      final updatedPendingFriendReq = {...pendingFriendReq, reciever: sender};

      await ref.child('friend_req').set(outgoing_list);
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

// write a function to send friend request here ( send user unique id)

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            _addFriend();
            // Perform the necessary actions to add the friend
            Navigator.of(context).pop();
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
