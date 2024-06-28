import 'package:flutter/material.dart';

class AcceptFriendWidget extends StatelessWidget {
  // write function to grab friend request list here

  // write function to add friend in friends list -> set unique user id
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
      ),
      body: ListView.builder(
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          final friendRequest = friendRequests[index];
          return ListTile(
            leading: Icon(friendRequest.icon),
            title: Text(friendRequest.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    // Accept friend request logic
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    // Reject friend request logic
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FriendRequest {
  final String name;
  final IconData icon;

  FriendRequest({required this.name, required this.icon});
}

final List<FriendRequest> friendRequests = [
  FriendRequest(name: 'John Doe', icon: Icons.person),
  FriendRequest(name: 'Jane Smith', icon: Icons.person),
  // Add more friend requests here
];
