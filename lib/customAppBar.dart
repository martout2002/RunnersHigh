import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white), // Text color
      ),
      centerTitle: true,
      backgroundColor: Colors.blue, // Set the background color to blue
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}