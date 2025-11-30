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

    // trạng thái
    final now = DateTime.now();
    final isOngoing = now.isAfter(task.start) && now.isBefore(task.end);
    final isOverdue = now.isAfter(task.end) && !task.done;
    final Color? accent =
    isOngoing ? AppColors.primary : (isOverdue ? Colors.redAccent : null);

    // style khi đã hoàn thành
    final bool done = task.done;
    final titleStyle = TextStyle(
      color: done ? AppColors.subtle : AppColors.text,
      fontWeight: FontWeight.w700,
      decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
      decorationThickness: 2,
      decorationColor: AppColors.subtle,
    );
    final descStyle = TextStyle(
      color: done ? AppColors.subtle.withOpacity(.9) : AppColors.subtle,
      fontSize: 12,
      decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
      decorationThickness: 1.5,
      decorationColor: AppColors.subtle,
    );

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
      if (ok == true) {
        try {
          await prov.deleteTask(task.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã xoá')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Xoá thất bại: $e')),
            );
          }
        }
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditTaskScreen(taskId: task.id)),
          );
        },
        onLongPress: _confirmDelete,
        child: Container(
          decoration: neoCard().copyWith(
            color: AppColors.card,
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
                    decoration:
                    done ? TextDecoration.lineThrough : TextDecoration.none,
                    decorationColor: AppColors.subtle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: titleStyle,
                      child: Text(task.title),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: descStyle,
                      child: Text(task.description),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: task.done,
                // TaskProvider.toggleDone cần (id, done)
                onChanged: (v) async {
                  try {
                    await prov.toggleDone(task.id, v ?? !task.done);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cập nhật trạng thái lỗi: $e')),
                      );
                    }
                  }
                },
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
