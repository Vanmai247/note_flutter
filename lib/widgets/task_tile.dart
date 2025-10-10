import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../theme.dart';
import '../screens/edit_task_screen.dart'; // màn hình sửa

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<TaskProvider>();
    final time =
        '${DateFormat.Hm().format(task.start)} - ${DateFormat.Hm().format(task.end)}';
    final isHighlight =
        DateFormat.Hm().format(task.start) == '10:00' && task.title.startsWith('Attend'); // ví dụ highlight

    Future<void> _confirmDelete() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Xoá task?'),
          content: const Text('Thao tác này không thể hoàn tác.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xoá')),
          ],
        ),
      );
      if (ok == true) {
        prov.deleteTask(task.id);
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // mở màn hình sửa
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditTaskScreen(taskId: task.id)),
          );
        },
        onLongPress: _confirmDelete, // nhấn giữ để xoá nhanh
        child: Container(
          decoration: neoCard().copyWith(
            color: isHighlight ? AppColors.primary : AppColors.card,
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
                    color: isHighlight ? Colors.white : AppColors.subtle,
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
                      style: TextStyle(
                        color: isHighlight ? Colors.white : AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.description,
                      style: TextStyle(
                        color: isHighlight ? Colors.white.withOpacity(.9) : AppColors.subtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: task.done,
                onChanged: (_) => prov.toggleDone(task.id),
                side: BorderSide(
                  color: isHighlight ? Colors.white : AppColors.primary,
                  width: 2,
                ),
                checkColor: Colors.white,
                activeColor: isHighlight ? Colors.white : AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
