import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/activity.dart';

class TaskProvider extends ChangeNotifier {
  DateTime selectedDay = DateTime.now();

  final activities = <Activity>[
    const Activity(id: 'idea',  name: 'Idea',  icon: Icons.lightbulb_outline, taskCount: 12),
    const Activity(id: 'food',  name: 'Food',  icon: Icons.restaurant_outlined, taskCount: 9),
    const Activity(id: 'work',  name: 'Work',  icon: Icons.assignment_outlined, taskCount: 14),
    const Activity(id: 'sport', name: 'Sport', icon: Icons.fitness_center, taskCount: 5),
    const Activity(id: 'music', name: 'Music', icon: Icons.music_note_outlined, taskCount: 4),
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

  // ----------- các hàm hiện có -----------

  List<Task> tasksFor(DateTime day) => _tasks
      .where((t) =>
  t.date.year == day.year &&
      t.date.month == day.month &&
      t.date.day == day.day)
      .toList();

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

  Activity byActivityId(String id) =>
      activities.firstWhere((a) => a.id == id);

  // ----------- thêm mới để Edit / Delete -----------

  Task getById(String id) =>
      _tasks.firstWhere((t) => t.id == id);

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
}
