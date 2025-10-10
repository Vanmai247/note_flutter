import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../theme.dart';
import '../screens/edit_task_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<TaskProvider>();
    final time =
        '${DateFormat.Hm().format(task.start)} - ${DateFormat.Hm().format(task.end)}';

    // Trạng thái thời gian
    final now = DateTime.now();
    final isOngoing = now.isAfter(task.start) && now.isBefore(task.end);
    final isOverdue = now.isAfter(task.end) && !task.done;

    final Color? accent =
    isOngoing ? AppColors.primary : (isOverdue ? Colors.redAccent : null);

    Future<void> _confirmDelete() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Xoá task?'),
          content: const Text('Thao tác này không thể hoàn tác.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Huỷ')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xoá')),
          ],
        ),
      );
      if (ok == true) prov.deleteTask(task.id);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditTaskScreen(taskId: task.id),
            ),
          );
        },
        onLongPress: _confirmDelete,
        child: Container(
          decoration: neoCard().copyWith(
            color: AppColors.card, // bỏ highlight nền
            border: accent != null
                ? Border(left: BorderSide(color: accent, width: 6))
                : null,
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(
                width: 76,
                child: Text(
                  time,
                  style: TextStyle(
                    color: isOverdue ? Colors.redAccent : AppColors.subtle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.description,
                      style: const TextStyle(
                        color: AppColors.subtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: task.done,
                onChanged: (_) => prov.toggleDone(task.id),
                side: const BorderSide(color: AppColors.primary, width: 2),
                checkColor: Colors.white,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
