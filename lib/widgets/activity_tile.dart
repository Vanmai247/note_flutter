import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../theme.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;


  final VoidCallback onTap;
  const ActivityTile({super.key, required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: neoCard().copyWith(color: AppColors.primarySoft),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(activity.icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${activity.taskCount} Tasks',
                      style: const TextStyle(fontSize: 12, color: AppColors.subtle)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.subtle),
          ],
        ),
      ),
    );
  }
}
