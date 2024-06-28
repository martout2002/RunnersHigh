import 'package:flutter/material.dart';

class AddFriendWidget extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();

// write function to add friends here

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
