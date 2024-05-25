// signup_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:async';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                  );
                  Navigator.pushReplacementNamed(context, '/login');
                } on FirebaseAuthException catch (e) {
                  if (e.code == "weak-password") {
                    print('The password provided is too weak.');
                  } else if (e.code == "email-already-in-use") {
                    print('An account already exists for that email.');
                  }
                } catch (e) {
                  print(e);
                }
              },
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
