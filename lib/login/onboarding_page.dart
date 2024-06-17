import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _paceController = TextEditingController();
  final _goalController = TextEditingController();
  String? _selectedGender;
  String? _selectedExperience;
  bool _isLoading = false;

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _paceController.dispose();
    _goalController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _previousPage() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseReference ref = FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
        await ref.set({
          'name': _nameController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'gender': _selectedGender,
          'experience': _selectedExperience,
          'goal': _goalController.text.trim(),
          'pace': _paceController.text.trim(),
        });
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildNamePage(),
                    _buildAgePage(),
                    _buildGenderPage(),
                    _buildExperiencePage(),
                    _buildGoalPage(),
                    _buildPacePage(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 60), // Empty space to align buttons
            ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: _ageController,
          decoration: const InputDecoration(labelText: 'Age'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _previousPage,
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(labelText: 'Gender'),
          items: ['Male', 'Female', 'Other'].map((label) => DropdownMenuItem(
            value: label,
            child: Text(label),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select your gender';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _previousPage,
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExperiencePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedExperience,
          decoration: const InputDecoration(labelText: 'Running Experience'),
          items: ['Beginner', 'Intermediate', 'Advanced'].map((label) => DropdownMenuItem(
            value: label,
            child: Text(label),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _selectedExperience = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select your running experience';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _previousPage,
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: _goalController,
          decoration: const InputDecoration(labelText: 'Goal'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your goal';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _previousPage,
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPacePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: _paceController,
          decoration: const InputDecoration(labelText: 'Comfortable Pace (min/km)'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your comfortable pace';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _previousPage,
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }
}
