import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/activity.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

class CreateTaskDetailScreen extends StatefulWidget {
  final Activity defaultActivity;
  const CreateTaskDetailScreen({super.key, required this.defaultActivity});

  @override
  State<CreateTaskDetailScreen> createState() => _CreateTaskDetailScreenState();
}

class _CreateTaskDetailScreenState extends State<CreateTaskDetailScreen> {
  late Activity selectedActivity;

  late DateTime focusedDay;
  late DateTime selectedDay;

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  TimeOfDay? startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? endTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    selectedActivity = widget.defaultActivity;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final d = context.read<TaskProvider>().selectedDay;
    focusedDay = DateTime(d.year, d.month, d.day);
    selectedDay = focusedDay;
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay? t) => t == null ? '--:--' : t.format(context);

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => startTime = picked);
      if (endTime != null) {
        final st = Duration(hours: picked.hour, minutes: picked.minute);
        final et = Duration(hours: endTime!.hour, minutes: endTime!.minute);
        if (et <= st) {
          final newEt = st + const Duration(minutes: 30);
          setState(() => endTime = TimeOfDay(
            hour: newEt.inHours % 24,
            minute: newEt.inMinutes % 60,
          ));
        }
      }
    }
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime ?? (startTime ?? TimeOfDay.now()),
    );
    if (!mounted) return;
    if (picked != null) setState(() => endTime = picked);
  }

  DateTime _merge(DateTime day, TimeOfDay t) =>
      DateTime(day.year, day.month, day.day, t.hour, t.minute);

  Future<void> _createTask() async {
    final prov = context.read<TaskProvider>();

    final st = startTime ?? const TimeOfDay(hour: 8, minute: 0);
    final et = endTime ?? TimeOfDay(hour: (st.hour + 1) % 24, minute: st.minute);

    final sDur = Duration(hours: st.hour, minutes: st.minute);
    final eDur = Duration(hours: et.hour, minutes: et.minute);

    if (eDur <= sDur) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End Time must be after Start Time')),
      );
      return;
    }

    final startDt = _merge(selectedDay, st);
    final endDt = _merge(selectedDay, et);

    await prov.addTask(Task(
      id: 'auto', // Firestore sẽ tạo auto-id, giá trị này không dùng
      date: DateTime(selectedDay.year, selectedDay.month, selectedDay.day),
      title: titleCtrl.text.trim().isEmpty ? selectedActivity.name : titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      start: startDt,
      end: endDt,
      activityId: selectedActivity.id,
    ));

    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.read<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Create Task',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.timer_outlined),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
          children: [
            // Calendar
            Container(
              decoration: neoCard(),
              padding: const EdgeInsets.all(8),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: focusedDay,
                selectedDayPredicate: (d) =>
                d.year == selectedDay.year &&
                    d.month == selectedDay.month &&
                    d.day == selectedDay.day,
                onDaySelected: (sel, foc) =>
                    setState(() => {selectedDay = sel, focusedDay = foc}),
                headerStyle: const HeaderStyle(
                    formatButtonVisible: false, titleCentered: true),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                      color: AppColors.primarySoft, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  selectedTextStyle: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Activity dropdown
            Container(
              decoration: neoCard().copyWith(color: AppColors.primarySoft),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(selectedActivity.icon, color: AppColors.primary),
                ),
                title: Text(
                  selectedActivity.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(Icons.expand_more),
                onTap: () async {
                  final chosen = await showModalBottomSheet<Activity>(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => ListView(
                      children: prov.activities
                          .map(
                            (a) => ListTile(
                          leading:
                          Icon(a.icon, color: AppColors.primary),
                          title: Text(a.name),
                          onTap: () async => Navigator.pop(context, a),
                        ),
                      )
                          .toList(),
                    ),
                  );
                  if (!mounted) return;
                  if (chosen != null) setState(() => selectedActivity = chosen);
                },
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                hintText: 'Name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Task Description...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),

            // Time pickers
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _pickStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Start Time',
                              style: TextStyle(color: Colors.black54)),
                          Text(_fmt(startTime),
                              style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _pickEnd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('End Time',
                              style: TextStyle(color: Colors.black54)),
                          Text(_fmt(endTime),
                              style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nút tạo task
            PrimaryButton(
              label: 'Create Task',
              onPressed: () async => _createTask(),
            ),
          ],
        ),
      ),
    );
  }
}
