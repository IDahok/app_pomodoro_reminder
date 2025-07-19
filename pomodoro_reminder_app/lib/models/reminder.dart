class Reminder {
  final String id;
  final String title;
  final String description;
  Duration interval;
  bool enabled;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.interval,
    this.enabled = true,
  });
} 