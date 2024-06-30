import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CampaignMissionsDisplayPage extends StatefulWidget {
  final String campaignId;

  CampaignMissionsDisplayPage({required this.campaignId});

  @override
  _CampaignMissionsDisplayPageState createState() =>
      _CampaignMissionsDisplayPageState();
}

class _CampaignMissionsDisplayPageState
    extends State<CampaignMissionsDisplayPage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _missionsStream;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaign Missions'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _missionsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No missions found.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final mission = snapshot.data!.docs[index].data();
              final missionId = snapshot.data!.docs[index].id;

              return ListTile(
                title: Text(mission['title']),
                subtitle: Text(mission['description']),
                trailing: missionId == 'currentMissionId'
                    ? Text('Current Mission')
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
