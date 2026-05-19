import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper để lấy mẫu schema từ collection `tasks` và in ra các fields
/// Sử dụng khi chạy app (debug) để biết các trường hiện có trong Firestore.
Future<List<String>> inspectTasksSchema({int limit = 50}) async {
  final firestore = FirebaseFirestore.instance;
  final col = firestore.collection('tasks');

  final snapshot = await col.limit(limit).get();
  if (snapshot.docs.isEmpty) {
    print('inspectTasksSchema: collection "tasks" rỗng.');
    return [];
  }

  final Set<String> keys = {};
  for (final doc in snapshot.docs) {
    final data = doc.data();
    keys.addAll(data.keys);
  }

  final fields = keys.toList()..sort();
  print('inspectTasksSchema: fields seen in ${snapshot.docs.length} docs: $fields');
  // Optional: print samples
  for (final doc in snapshot.docs) {
    print('doc(${doc.id}): ${doc.data()}');
  }

  return fields;
}
