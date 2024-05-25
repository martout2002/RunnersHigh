import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'customAppBar.dart'; // Import the custom AppBar

class LoginPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LoginPage({super.key, required this.onToggleTheme});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final StreamSubscription<User?> _firebaseStreamEvents;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    _firebaseStreamEvents = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firebaseStreamEvents.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Login', onToggleTheme: widget.onToggleTheme), // Use the custom AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'lib/images/runnerslogo_dark.png'
                  : 'lib/images/runnerslogo_light.png',
              height: 100, // Adjust the height as needed
            ),
            const SizedBox(height: 20), // Add some spacing between the logo and the rest of the content
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                  );
                } on FirebaseAuthException catch (e) {
                  print(e);
                }
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
