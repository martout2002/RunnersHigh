
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './firebase_options.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
// import 'customAppBar.dart'; // Import the custom AppBar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signOut(); // Sign out the user
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(onToggleTheme: _toggleTheme),
        '/signup': (context) => SignUpPage(onToggleTheme: _toggleTheme),
        '/home': (context) => HomePage(onToggleTheme: _toggleTheme),
      },
    );
  }
}
