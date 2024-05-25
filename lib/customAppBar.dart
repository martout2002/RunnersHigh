import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onToggleTheme;

  const CustomAppBar({Key? key, required this.title, required this.onToggleTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black, // Change text color based on theme
        ),
      ),
      centerTitle: true,
      backgroundColor: isDarkMode ? Colors.lightBlue : Colors.blue, // Change background color based on theme
      actions: [
        IconButton(
          icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: onToggleTheme,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}