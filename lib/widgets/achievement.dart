import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final String imagePath;
  final String text;

  const AchievementCard(
      {Key? key, required this.imagePath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              "assets/badges/$imagePath",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
