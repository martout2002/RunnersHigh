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
  List<Map<dynamic, dynamic>> friends = [];

  Future<Map<dynamic, dynamic>>? _getFriendData(String code) async {
    Map<dynamic, dynamic> friendData = {} as Map<dynamic, dynamic>;
    final ref = FirebaseDatabase.instance.ref().child('profiles').child(code);
    final snapshot = await ref.once();
    if (snapshot.snapshot.value != null) {
      final data = Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);
      friendData = data;
    } else {
      print("No user data available");
    }
    print("friends data found: $friendData");
    return friendData;
  }

  void init_data() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      ref.onValue.listen((event) async {
        final eventValue = event.snapshot.value;
        if (eventValue != null) {
          final data = Map<dynamic, dynamic>.from(eventValue as Map);
          final friendsData = data['friends'];
          print(data['friends']);
          if (friendsData != null) {
            print("jode");
            List<Map<dynamic, dynamic>> tempFriends = [];
            for (var g in friendsData.values) {
              print(g);
              //var friendData = await _getFriendData(g);
              // if (friendData != null) {
              //   tempFriends.add({
              //     'key': g,
              //     'value': friendData,
              //   });
              // }
              tempFriends.add({
                'code': g,
              });
            }

            setState(() {
              friends = tempFriends;
            });
          }
          print(friends);
        } else {
          print("No user data available");
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init_data();
  }

  @override
  Widget build(BuildContext context) {
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
          child: friends.isEmpty
              ? const Text('Time to get friends')
              : ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return FutureBuilder<Map<dynamic, dynamic>>(
                      future: _getFriendData(friend['code']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          var friendData = snapshot.data!;
                          print("friends $friendData");

                          return Card(
                              margin: const EdgeInsets.all(10.0),
                              child: ListTile(
                                  leading: const CircleAvatar(
                                      foregroundImage:
                                          AssetImage("assets/images/pfp.jpg"),
                                      radius: 35),
                                  title: Text(friendData['username'],
                                      style: const TextStyle(fontSize: 20)),
                                  subtitle: Text(
                                      '${friendData['num_of_runs']} runs completed \n${friendData['total_distance']} km ran')));
                        }
                      },
                    );
                  },
                  // If the person has no friends, display a text saying "Time to get friends"
                )),
    );
  }
}
