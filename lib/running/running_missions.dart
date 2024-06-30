import 'package:flutter/material.dart';

class CampaignPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Campaign',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Color.fromARGB(255, 60, 60, 60)),
      body: Container(
        color: const Color.fromARGB(255, 20, 20, 20),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            CampaignBanner(
              image: AssetImage('assets/images/c1.png'),
              text: '5 Missions | 25 km',
              subtitle:
                  'Hurry we need your insane running and parkour skills to save the last of humanity!',
              onPressed: () {},
            ),
            CampaignBanner(
              image: AssetImage('assets/images/c2.png'),
              text: '8 Missions | 42 Km',
              subtitle:
                  'Stranded. You must journey through the barren rocky wastelands of Jupiter to find your way home!',
              onPressed: () {},
            ),
            CampaignBanner(
              image: AssetImage('assets/images/c3.png'),
              text: '14 Missions | 132 Km',
              subtitle:
                  'Are you up to the challenge? Journey accross the kingdom and slay the red dragon smog!',
              onPressed: () {},
            ),
            // Add more CampaignBanners as needed
          ],
        ),
      ),
    );
  }
}

class CampaignBanner extends StatelessWidget {
  final ImageProvider image;
  final String text;
  final String subtitle;
  final VoidCallback onPressed;

  const CampaignBanner({
    required this.image,
    required this.text,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: const Color.fromARGB(
            255, 40, 40, 40), // Set the background color of the Card
        child: Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image(image: image),
              const SizedBox(height: 8.0),
              Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 119, 189, 253),
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
