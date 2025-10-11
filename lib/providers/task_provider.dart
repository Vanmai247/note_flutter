import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/activity.dart';

class TaskProvider extends ChangeNotifier {
  DateTime selectedDay = DateTime.now();

  // Danh sách activity (taskCount ở đây chỉ là số mặc định – không dùng để hiển thị)
  final activities = <Activity>[
    const Activity(id: 'idea',  name: 'Idea',  icon: Icons.lightbulb_outline, taskCount: 0),
    const Activity(id: 'food',  name: 'Food',  icon: Icons.restaurant_outlined, taskCount: 0),
    const Activity(id: 'work',  name: 'Work',  icon: Icons.assignment_outlined, taskCount: 0),
    const Activity(id: 'sport', name: 'Sport', icon: Icons.fitness_center, taskCount: 0),
    const Activity(id: 'music', name: 'Music', icon: Icons.music_note_outlined, taskCount: 0),
  ];

  final List<Task> _tasks = [
    Task(
      id: 't1',
      date: DateTime.now(),
      title: 'Fitness',
      description: 'Exercise and gym',
      start: DateTime.now().copyWith(hour: 6, minute: 0),
      end:   DateTime.now().copyWith(hour: 7, minute: 30),
      activityId: 'sport',
      done: true,
    ),
    Task(
      id: 't2',
      date: DateTime.now(),
      title: 'Check Emails and SMS',
      description: 'Review and respond to emails and SMS',
      start: DateTime.now().copyWith(hour: 7, minute: 30),
      end:   DateTime.now().copyWith(hour: 8, minute: 0),
      activityId: 'work',
    ),
    Task(
      id: 't3',
      date: DateTime.now(),
      title: 'Work on Projects',
      description: 'Focus on tasks related to Project',
      start: DateTime.now().copyWith(hour: 8, minute: 0),
      end:   DateTime.now().copyWith(hour: 10, minute: 0),
      activityId: 'work',
    ),
    Task(
      id: 't4',
      date: DateTime.now(),
      title: 'Attend Meeting',
      description: 'Team meeting with client ABC',
      start: DateTime.now().copyWith(hour: 10, minute: 0),
      end:   DateTime.now().copyWith(hour: 11, minute: 0),
      activityId: 'work',
    ),
  ];

  // ===================== QUERY HELPERS =====================

  // Tất cả task trong một ngày
  List<Task> tasksFor(DateTime day) => _tasks.where((t) =>
  t.date.year == day.year &&
      t.date.month == day.month &&
      t.date.day == day.day).toList();

  // Tất cả task theo activity (mọi ngày)
  List<Task> tasksForActivity(String activityId) =>
      _tasks.where((t) => t.activityId == activityId).toList();

  // Task theo activity trong một ngày cụ thể
  List<Task> tasksForActivityOn(DateTime day, String activityId) =>
      _tasks.where((t) =>
      t.activityId == activityId &&
          t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day).toList();

  // Chỉ lấy số lượng (tiện hiển thị)
  int countForActivity(String activityId) =>
      _tasks.where((t) => t.activityId == activityId).length;

  int countForActivityOn(DateTime day, String activityId) =>
      tasksForActivityOn(day, activityId).length;

  // ===================== STATE OPS =====================

  void toggleDone(String id) {
    final t = _tasks.firstWhere((e) => e.id == id);
    t.done = !t.done;
    notifyListeners();
  }

  void setSelectedDay(DateTime d) {
    selectedDay = d;
    notifyListeners();
  }

  void addTask(Task t) {
    _tasks.add(t);
    notifyListeners();
  }

  Task getById(String id) => _tasks.firstWhere((t) => t.id == id);

  void updateTask(Task updated) {
    final i = _tasks.indexWhere((t) => t.id == updated.id);
    if (i != -1) {
      _tasks[i] = updated;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Activity byActivityId(String id) =>
      activities.firstWhere((a) => a.id == id);
}
