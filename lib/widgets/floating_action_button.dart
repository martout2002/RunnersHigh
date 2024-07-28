import 'package:flutter/material.dart';
import '../running/run_tracking_page.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final WidgetBuilder pageBuilder;

  const CustomFloatingActionButton({
    Key? key,
    required this.onToggleTheme,
    required this.pageBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: pageBuilder,
          ),
        );
      },
      child: const Icon(Icons.run_circle),
    );
  }
}