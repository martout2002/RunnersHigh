import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:runners_high/UserProfilePage.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'run_tracking_page.dart';
import 'onboarding_page.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Gemini API with your API key
  Gemini.init(apiKey: 'AIzaSyDbeiFsxNqRQQhmVpUWgYFU0AosmzAUHL0', enableDebugging: true);

  await FirebaseAuth.instance.signOut(); // Ensure user is logged out on app start
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, User? currentUser});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Run Tracker',
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        textTheme: GoogleFonts.readexProTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.readexProTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(onToggleTheme: _toggleTheme),
        '/signup': (context) => SignUpPage(onToggleTheme: _toggleTheme),
        '/home': (context) => HomePage(onToggleTheme: _toggleTheme),
        '/run_tracking': (context) => RunTrackingPage(onToggleTheme: _toggleTheme),
        '/onboarding': (context) => const OnboardingPage(),
        '/profile': (context) => UserProfilePage(),
        '/forgotPassword': (context) => forgotPasswordPage(onToggleTheme: _toggleTheme),
      },
    );
  }
}
