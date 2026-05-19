import 'package:cloud_firestore/cloud_firestore.dart';

import '../views/stats_viewmodel.dart';

class StatsService {
  StatsService._();

  static final StatsService instance = StatsService._();

  Future<void> saveUserStats(StatsViewModel stats) async {
    if (stats.uid.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('stat')
        .doc(stats.uid)
        .set(stats.toFirestoreMap(), SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserStats(String uid) {
    return FirebaseFirestore.instance.collection('stat').doc(uid).snapshots();
  }
}
