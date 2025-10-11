import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../models/activity.dart';
import '../providers/task_provider.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;
  const EditTaskScreen({super.key, required this.taskId});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late Task original;
  late Activity selectedActivity;
  late DateTime focusedDay;
  late DateTime selectedDay;

  final titleCtrl = TextEditingController();
  final descCtrl  = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    final prov = context.read<TaskProvider>();
    original = prov.getById(widget.taskId);

    // fill state
    focusedDay  = original.date;
    selectedDay = original.date;
    titleCtrl.text = original.title;
    descCtrl.text  = original.description;

    startTime = TimeOfDay(hour: original.start.hour, minute: original.start.minute);
    endTime   = TimeOfDay(hour: original.end.hour,   minute: original.end.minute);

    // map activity id -> Activity object
    selectedActivity = prov.byActivityId(original.activityId);
  }

  String _fmt(TimeOfDay? t) => t == null ? '--:--' : t.format(context);
  DateTime _merge(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

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

  void _save() {
    final prov = context.read<TaskProvider>();
    final st = startTime ?? TimeOfDay(hour: original.start.hour, minute: original.start.minute);
    final et = endTime   ?? TimeOfDay(hour: original.end.hour,   minute: original.end.minute);

    final sDur = Duration(hours: st.hour, minutes: st.minute);
    final eDur = Duration(hours: et.hour, minutes: et.minute);
    if (eDur <= sDur) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End Time must be after Start Time')),
      );
      return;
    }

    final updated = Task(
      id: original.id,
      date: selectedDay,
      title: titleCtrl.text.trim().isEmpty ? selectedActivity.name : titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      start: _merge(selectedDay, st),
      end:   _merge(selectedDay, et),
      activityId: selectedActivity.id,
      done: original.done,
    );

    prov.updateTask(updated);
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true) {
      context.read<TaskProvider>().deleteTask(original.id);
      if (mounted) Navigator.pop(context); // thoát màn sửa
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit Task', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(), // 👈 bọc Future vào lambda sync
            icon: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: 6),
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
                onDaySelected: (sel, foc) => setState(() {
                  selectedDay = sel;
                  focusedDay = foc;
                }),
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  selectedTextStyle: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Activity selector
            Container(
              decoration: neoCard().copyWith(color: AppColors.primarySoft),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(prov.byActivityId(selectedActivity.id).icon, color: AppColors.primary),
                ),
                title: Text(
                  prov.byActivityId(selectedActivity.id).name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(Icons.expand_more),
                onTap: () async {
                  final chosen = await showModalBottomSheet<Activity>(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => ListView(
                      children: prov.activities
                          .map((a) => ListTile(
                        leading: Icon(a.icon, color: AppColors.primary),
                        title: Text(a.name),
                        onTap: () async => Navigator.pop(context, a), // 👈 trả Future
                      ))
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
                  borderSide: BorderSide.none,
                ),
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
                  borderSide: BorderSide.none,
                ),
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
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Start Time', style: TextStyle(color: Colors.black54)),
                          Text(_fmt(startTime), style: const TextStyle(fontWeight: FontWeight.w700)),
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
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('End Time', style: TextStyle(color: Colors.black54)),
                          Text(_fmt(endTime), style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nếu PrimaryButton đã hỗ trợ sync+async như mình hướng dẫn, truyền trực tiếp _save là được.
            PrimaryButton(
              label: 'Save Changes',
              onPressed: () async => _save(), // đảm bảo kiểu FutureOr<void>
            ),
          ],
        ),
      ),
    );
  }
}
