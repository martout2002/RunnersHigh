import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserProfilePage extends StatefulWidget {
  UserProfilePage({super.key});

  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users');

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
            ),
            const SizedBox(height: 20),
            const Text(
              'John',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Runner',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement edit profile functionality
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}