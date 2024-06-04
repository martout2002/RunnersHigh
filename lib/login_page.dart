import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:runners_high/main.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LoginPage({super.key, required this.onToggleTheme});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final StreamSubscription<User?> _firebaseStreamEvents;
  bool _rememberMe = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _firebaseStreamEvents = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        var currentUser = user;
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

  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyApp(),
      ),
    );
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sign in: $e')));
      }
    }
  }

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send reset email: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Runners' High",
          style: TextStyle(color: Colors.black), // Ensures the text color does not change
        ),
        backgroundColor: Colors.white, // Fixed color for the AppBar
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.black),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DefaultTextStyle(
          style: GoogleFonts.readexPro(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                isDarkMode ? 'lib/images/logo2dark.png' : 'lib/images/logo2.png',
                height: 200,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color(0xFFD3D3D3), // Light grey color
                  labelStyle: const TextStyle(color: Colors.black), // Ensures label text is always black
                ),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black), // Ensures text is always black
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color(0xFFD3D3D3), // Light grey color
                  labelStyle: const TextStyle(color: Colors.black), // Ensures label text is always black
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.black), // Ensures icon is always black
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
                style: const TextStyle(color: Colors.black), // Ensures text is always black
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                      ),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black, // Black in light mode, white in dark mode
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgotPassword');
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.lightBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Match the width of the email and password fields
                height: 38,
                child: ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BB2FF), // Light blue color
                    padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Log in',
                    style: GoogleFonts.readexPro(
                      color: Colors.white,
                      fontWeight: FontWeight.bold, // Make the text bold
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account?",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.grey, // Grey in light mode, white in dark mode
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
