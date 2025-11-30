import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/activity.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  // ==== UI state ====
  DateTime selectedDay = DateTime.now();

  // Danh sách activity
  final activities = <Activity>[
    const Activity(id: 'idea',  name: 'Idea',  icon: Icons.lightbulb_outline, taskCount: 0),
    const Activity(id: 'food',  name: 'Food',  icon: Icons.restaurant_outlined, taskCount: 0),
    const Activity(id: 'work',  name: 'Work',  icon: Icons.assignment_outlined, taskCount: 0),
    const Activity(id: 'sport', name: 'Sport', icon: Icons.fitness_center, taskCount: 0),
    const Activity(id: 'music', name: 'Music', icon: Icons.music_note_outlined, taskCount: 0),
  ];

  // ==== Firebase ====
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  List<Task> _tasks = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  StreamSubscription<User?>? _authSub;

  TaskProvider() {
    _authSub = _auth.authStateChanges().listen((_) => _bindUserStream());
    _bindUserStream();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _taskCol {
    final uid = _uid;
    if (uid == null) throw StateError('Chưa đăng nhập');
    return _db.collection('users').doc(uid).collection('tasks');
  }

  void _bindUserStream() {
    _sub?.cancel();
    final uid = _uid;
    if (uid == null) {
      _tasks = [];
      notifyListeners();
      return;
    }
    _sub = _taskCol
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snap) {
      _tasks = snap.docs.map((d) => Task.fromDoc(d)).toList();
      notifyListeners();
    });
  }

  // ===== helper notification id =====
  int _notificationIdFromTaskId(String id) => id.hashCode & 0x7fffffff;

  // ===== query helpers =====
  List<Task> tasksFor(DateTime day) => _tasks.where((t) =>
  t.date.year == day.year &&
      t.date.month == day.month &&
      t.date.day == day.day).toList();

  List<Task> tasksForActivity(String activityId) =>
      _tasks.where((t) => t.activityId == activityId).toList();

  List<Task> tasksForActivityOn(DateTime day, String activityId) =>
      _tasks.where((t) =>
      t.activityId == activityId &&
          t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day).toList();

  int countForActivity(String activityId) =>
      _tasks.where((t) => t.activityId == activityId).length;

  int countForActivityOn(DateTime day, String activityId) =>
      tasksForActivityOn(day, activityId).length;

  // ===== state ops =====
  void setSelectedDay(DateTime d) {
    selectedDay = DateTime(d.year, d.month, d.day);
    notifyListeners();
  }

  /// Thêm task + schedule thông báo
  Future<String> addTask(Task t) async {
    final onlyDateLocal =
    DateTime(t.date.year, t.date.month, t.date.day); // 00:00 local

    final doc = await _taskCol.add({
      'date': Timestamp.fromDate(onlyDateLocal),
      'title': t.title,
      'description': t.description,
      'start': Timestamp.fromDate(t.start.toLocal()),
      'end': Timestamp.fromDate(t.end.toLocal()),
      'activityId': t.activityId,
      'done': t.done,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final id = doc.id;

    // lập lịch thông báo theo giờ start
    final notiId = _notificationIdFromTaskId(id);
    await NotificationService.scheduleTaskNotification(
      id: notiId,
      title: t.title,
      body: t.description.isEmpty
          ? 'Đến giờ làm: ${t.title}'
          : t.description,
      time: t.start,
    );

    return id;
  }

  Task getById(String id) => _tasks.firstWhere((t) => t.id == id);

  Future<void> updateTask(Task t) async {
    final onlyDateLocal =
    DateTime(t.date.year, t.date.month, t.date.day);

    await _taskCol.doc(t.id).update({
      'date': Timestamp.fromDate(onlyDateLocal),
      'title': t.title,
      'description': t.description,
      'start': Timestamp.fromDate(t.start.toLocal()),
      'end': Timestamp.fromDate(t.end.toLocal()),
      'activityId': t.activityId,
      'done': t.done,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // cập nhật lại thông báo nếu đổi giờ / đổi nội dung
    final notiId = _notificationIdFromTaskId(t.id);
    await NotificationService.cancelNotification(notiId);
    await NotificationService.scheduleTaskNotification(
      id: notiId,
      title: t.title,
      body: t.description.isEmpty
          ? 'Đến giờ làm: ${t.title}'
          : t.description,
      time: t.start,
    );
  }

  Future<void> toggleDone(String id, bool done) async {
    await _taskCol.doc(id).update({
      'done': done,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // nếu đã hoàn thành thì huỷ thông báo
    if (done) {
      final notiId = _notificationIdFromTaskId(id);
      await NotificationService.cancelNotification(notiId);
    }
  }

  Future<void> deleteTask(String id) async {
    await _taskCol.doc(id).delete();

    final notiId = _notificationIdFromTaskId(id);
    await NotificationService.cancelNotification(notiId);
  }

  Activity byActivityId(String id) =>
      activities.firstWhere((a) => a.id == id);
}
