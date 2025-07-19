import 'package:flutter/material.dart';
import '../models/reminder.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final ValueChanged<bool> onToggle;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.alarm, color: reminder.enabled ? Colors.green : Colors.grey),
        title: Text(reminder.title),
        subtitle: Text(reminder.description),
        trailing: Switch(
          value: reminder.enabled,
          onChanged: onToggle,
        ),
      ),
    );
  }
} 