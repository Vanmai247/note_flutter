import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String activityId;
  bool done;

  Task({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.activityId,
    this.done = false,
  });

  /// Map để ghi lên Firestore
  Map<String, dynamic> toMap() => {
    'date': Timestamp.fromDate(date),
    'title': title,
    'description': description,
    'start': Timestamp.fromDate(start),
    'end': Timestamp.fromDate(end),
    'activityId': activityId,
    'done': done,
    // chỉ set khi tạo mới; với update hãy set trong provider
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// Parse từ document Firestore
  factory Task.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Task(
      id: doc.id,
      date: (d['date'] as Timestamp).toDate().toLocal(),
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      start: (d['start'] as Timestamp).toDate().toLocal(),
      end:(d['end']   as Timestamp).toDate().toLocal(),
      activityId: d['activityId'] ?? '',
      done: d['done'] ?? false,
    );
  }
}
