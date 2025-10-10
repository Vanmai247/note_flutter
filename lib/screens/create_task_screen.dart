import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/activity_tile.dart';
import '../theme.dart';
import 'create_task_detail_screen.dart';
import '../widgets/day_pill.dart'; // đường dẫn đúng theo dự án của bạn

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TaskProvider>();
    final start = prov.selectedDay.subtract(const Duration(days: 3));
    final days  = List.generate(7, (i) => start.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.timer_outlined))],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // date pills nhỏ
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemCount: days.length,
                itemBuilder: (_, i) {
                  final d = days[i];
                  final selected = d.day == prov.selectedDay.day &&
                      d.month == prov.selectedDay.month &&
                      d.year == prov.selectedDay.year;

                  return DayPill(
                    line1: DateFormat('dd').format(d),
                    line2: DateFormat('EEE').format(d),
                    selected: selected,
                    onTap: () => prov.setSelectedDay(d),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            const Text('Choose Activity', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),

            Expanded(
              child: ListView(
                children: prov.activities
                    .map((a) => ActivityTile(
                  activity: a,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateTaskDetailScreen(defaultActivity: a),
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
