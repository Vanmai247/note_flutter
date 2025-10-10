import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String name;
  final IconData icon;
  final int taskCount;

  const Activity({
    required this.id,
    required this.name,
    required this.icon,
    required this.taskCount,
  });
}
