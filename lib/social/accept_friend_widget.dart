import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AcceptFriendWidget extends StatefulWidget {
  const AcceptFriendWidget({Key? key}) : super(key: key);

  @override
  AcceptFriendWidgetState createState() => AcceptFriendWidgetState();
}

class AcceptFriendWidgetState extends State<AcceptFriendWidget> {
  List<Map<dynamic, dynamic>> friend_requests = [];
  // write function to grab friend request list here

  @override
  void initState() {
    super.initState();
    init_data();
  }

  Future<void> _rejectReqeust(dynamic key) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final ref =
            FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
        final snapshot = await ref.get();
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          var friendReqList = data['friend_req'];
          friendReqList.remove(key);
          await ref.update({'friend_req': friendReqList});
        }
      } catch (e) {
        print('Error rejecting friend request: $e');
        // Handle the error appropriately
      }
    }
  }

  Future<void> _acceptRequest(String id, dynamic key) async {
    Map<dynamic, dynamic> friendList = {};
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final ref =
            FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
        final snapshot = await ref.get();
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          var friendReqList = data['friend_req'];
          friendReqList.remove(key);
          if (data['friends'] != null) {
            friendList = data['friends'];
          }
          friendList[id] = id;

          // Use update for partial updates
          await ref.update({
            'friend_req': friendReqList,
            'friends': friendList,
          });
        }
      } catch (e) {
        print('Error accepting friend request: $e');
        // Handle the error appropriately
      }
    }
  }

  Future<Map<dynamic, dynamic>>? _getFriendData(String code) async {
    Map<dynamic, dynamic> friendData = {} as Map<dynamic, dynamic>;
    final ref = FirebaseDatabase.instance.ref().child('profiles').child(code);
    final snapshot = await ref.once();
    if (snapshot.snapshot.value != null && snapshot.snapshot.value is Map) {
      final data = Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);
      friendData = data;
    } else {
      print("No user data available");
    }
    return friendData;
  }

  void init_data() async {
    print("starting init");
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      ref.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final friendsData = data['friend_req'];
          if (friendsData != null && friendsData is Map) {
            print("dog");
            setState(() {
              friend_requests = friendsData.keys
                  .map((key) => {
                        'key': key,
                        // Safely cast each friend data to Map<String, dynamic>, handling potential nulls
                        ...((friendsData[key] is Map)
                            ? Map<String, dynamic>.from(friendsData[key])
                            : {'code': friendsData[key]})
                      })
                  .toList();
            });
          }
        } else {
          print("No user data available");
        }
      });
    }
  }

  // Future<void> _grabRequests() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     final ref =
  //         FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
  //     ref.onValue.listen((event) {
  //       if (event.snapshot.value != null) {
  //         final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
  //         final friendData = data['friend_req'];
  //         print('Friend requests: $friendData');
  //         setState(() {
  //           friendRequests = friendData.keys.map((key) {
  //             final data = friendData[key];
  //             if (data is Map<dynamic, dynamic>) {
  //               return {'key': key, ...Map<dynamic, dynamic>.from(data)};
  //             }
  //             // Return a default structure or handle the case where data is not a map.
  //             return {'key': key};
  //           }).toList();
  //         });
  //         print("joe");
  //       }
  //     });
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Page'),
      ),
      body: Center(
          child: friend_requests.isEmpty
              ? const Text('No one wants to be ur friend yet !!!')
              : ListView.builder(
                  itemCount: friend_requests.length,
                  itemBuilder: (context, index) {
                    final friendReqData = friend_requests[index];
                    return FutureBuilder<Map<dynamic, dynamic>>(
                      future: _getFriendData(friendReqData['code']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          var friendData = snapshot.data!;
                          print(friendData);

                          return ListTile(
                            leading: Icon(Icons.person),
                            title: Text(
                                '${friendData['name']}  (${friendData['username']})'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: () async {
                                    _acceptRequest(friendReqData['code'],
                                        friendReqData['key']);
                                    // var name = friendData['name'];
                                    // showDialog(
                                    //     context: context,
                                    //     builder: (context) {
                                    //       return AlertDialog(
                                    //         title:
                                    //             Text('Accept Friend Request'),
                                    //         content: Text(
                                    //             "Do you want to accept $name as a friend?"),
                                    //         actions: [
                                    //           TextButton(
                                    //             onPressed: () {
                                    //               _acceptRequest(
                                    //                   friendData['code']);
                                    //               Navigator.of(context).pop();
                                    //             },
                                    //             child: Text('Yes'),
                                    //           ),
                                    //           TextButton(
                                    //             onPressed: () {
                                    //               Navigator.of(context).pop();
                                    //             },
                                    //             child: Text('No'),
                                    //           ),
                                    //         ],
                                    //       );
                                    //     });

                                    //_acceptRequest(friendData['code']);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    // Reject friend request logic
                                    _rejectReqeust(friendReqData['key']);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                  // If the person has no friends, display a text saying "Time to get friends"
                )),
    );
  }

// write function to add friend in friends list -> set unique user id
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Friend Requests'),
  //     ),
  //     body: ListView.builder(
  //       itemCount: friend_requests.length,
  //       itemBuilder: (context, index) {
  //         var friendReqData = friend_requests[index] as Map;
  //         return ListTile(
  //           leading: Icon(Icons.person),
  //           title:
  //               Text("$friendReqData['name']  (${friendReqData['username']})"),
  //           trailing: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               IconButton(
  //                 icon: Icon(Icons.check),
  //                 onPressed: () {
  //                   // Accept friend request logic
  //                 },
  //               ),
  //               IconButton(
  //                 icon: Icon(Icons.close),
  //                 onPressed: () {
  //                   // Reject friend request logic
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
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
