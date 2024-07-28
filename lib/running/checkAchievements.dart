import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AchievementChecker {
  // ignore: prefer_typing_uninitialized_variables
  late final userAchievements;

  Future<void> _getUserData() async{
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref =
          FirebaseDatabase.instance.ref().child('profiles').child(user.uid);
      ref.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          try {
            userAchievements = data['achievements'];
          } catch (e) {
            userAchievements = <String>[];
          }
        } 
      });
    }
  }

  Future<void> updateAchievements() async {
    await _getUserData();
    if (userAchievements != null) {
      final ref = FirebaseDatabase.instance.ref().child('profiles');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        ref.child(user.uid).update({
          'achievements': userAchievements,
        });
      }
    }
  }

  Future<void> checkCampaigns() async {
  }

  Future<void> checkAchievements(double distance) async {
    await _getUserData();
    if (userAchievements != null) {
      if (distance >= 1000 && !userAchievements.contains('walk_1k')) {
        userAchievements.add('1km');
      }
      if (distance >= 5000 && !userAchievements.contains('walk_5k')) {
        userAchievements.add('5km');
      }
      if (distance >= 10000 && !userAchievements.contains('walk_10k')) {
        userAchievements.add('10km');
      }
      if (distance >= 50000 && !userAchievements.contains('walk_50k')) {
        userAchievements.add('21km');
      }
      print("new achievements meow: $userAchievements");
      await updateAchievements();
    } else {
      print("error");
    }
  }

}
