import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/task_provider.dart';

class DatePills extends StatelessWidget {
  final DateTime base; // ngày đang hiển thị dải 4 ngày
  const DatePills({super.key, required this.base});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TaskProvider>();
    final baseStart = base.subtract(const Duration(days: 3));
    final days = List.generate(7, (i) => baseStart.add(Duration(days: i)));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) {
        final selected = d.day == prov.selectedDay.day &&
            d.month == prov.selectedDay.month &&
            d.year == prov.selectedDay.year;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: InkWell(
              onTap: () => prov.setSelectedDay(d),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('dd').format(d),
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.text,
                          fontWeight: FontWeight.w700,
                        )),
                    Text(DateFormat('EEE').format(d),
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.subtle,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
