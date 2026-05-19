import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/report_viewmodel.dart';

class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  /// Save (create or update) a report document in collection 'report'.
  /// If [docId] is empty, an auto-id document will be created.
  Future<String> saveReport(ReportViewModel report, {String? docId}) async {
    final col = FirebaseFirestore.instance.collection('report');
    if (docId == null || docId.isEmpty) {
      final ref = await col.add(report.toMap());
      // Debug log
      // ignore: avoid_print
      print('ReportService: created report ${ref.id} for uid=${report.uid}');
      return ref.id;
    } else {
      await col.doc(docId).set(report.toMap(), SetOptions(merge: true));
      // ignore: avoid_print
      print('ReportService: updated report $docId for uid=${report.uid}');
      return docId;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserReports(String uid) {
    return FirebaseFirestore.instance.collection('report').where('uid', isEqualTo: uid).orderBy('generatedAt', descending: true).snapshots();
  }

  Future<ReportViewModel?> getReportById(String id) async {
    final snap = await FirebaseFirestore.instance.collection('report').doc(id).get();
    if (!snap.exists) return null;
    return ReportViewModel.fromMap(snap.id, snap.data()!);
  }

  /// Create a lightweight sample report for the given user (for debugging/testing).
  Future<String> createSampleReportForUser(String uid) async {
    final now = DateTime.now();
    final report = ReportViewModel(
      uid: uid,
      periodStart: Timestamp.fromDate(now.subtract(const Duration(days: 7))),
      periodEnd: Timestamp.fromDate(now),
      totalTasks: 8,
      completedTasks: 5,
      overdueTasks: 1,
      onTimeCount: 4,
      lateCount: 1,
      avgDelayMinutes: 20,
      priorityCounts: {'high': 3, 'medium': 3, 'low': 2},
      completedByPriority: {'high': 2, 'medium': 2, 'low': 1},
      categoryCounts: {'Công việc': 5, 'Cá nhân': 2, 'Sức khỏe': 1},
      topCategory: 'Công việc',
      topOverdueTitle: 'Báo cáo mẫu',
      topOverdueMinutes: 120,
      incompleteOverdueCount: 1,
      completedLateCount: 1,
      completedLateTotalMinutes: 120,
      earliestCompletionTitle: 'Hoàn sớm mẫu',
      earliestCompletionMinutes: 30,
      categoryStats: {},
      notes: 'Báo cáo mẫu tự động tạo để kiểm tra collection report.',
      generatedAt: Timestamp.fromDate(now),
    );

    final id = await saveReport(report);
    return id;
  }
}
