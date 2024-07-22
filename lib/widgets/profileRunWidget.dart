import 'package:flutter/material.dart';
class ProfileRunWidget extends StatelessWidget {
  final int display;
  final String bot;

  ProfileRunWidget(this.display, this.bot);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 252, 247, 247),
      child: SizedBox(
        height: 100,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$display',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.indigo[900],
                ),
              ),
            ),
            Text(
              bot,
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 110, 110, 110),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

