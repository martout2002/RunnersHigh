import 'package:flutter/material.dart';
import '../running/run_tracking_page.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const CustomFloatingActionButton({Key? key, required this.onToggleTheme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RunTrackingPage(onToggleTheme: onToggleTheme),
          ),
        );
      },
      child: const Icon(Icons.run_circle),
    );
  }
}
