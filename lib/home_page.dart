import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'customAppBar.dart'; // Import the custom AppBar

class HomePage extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Home', onToggleTheme: onToggleTheme), // Use the custom AppBar
      body: const Center(
        child: Text('Successful!'),
      ),
    );
  }
}
