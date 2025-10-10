class Task {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String activityId;
  bool done;

  Task({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.activityId,
    this.done = false,
  });
}
