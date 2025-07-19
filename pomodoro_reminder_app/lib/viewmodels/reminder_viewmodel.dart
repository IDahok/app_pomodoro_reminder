import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

class ReminderViewModel extends ChangeNotifier {
  final List<Reminder> _reminders = [
    Reminder(
      id: 'water',
      title: 'Beber água',
      description: 'Lembre-se de se hidratar!',
      interval: const Duration(minutes: 30),
    ),
    Reminder(
      id: 'posture',
      title: 'Arrumar postura',
      description: 'Ajuste sua postura na cadeira.',
      interval: const Duration(minutes: 45),
    ),
    Reminder(
      id: 'exercise',
      title: 'Exercício laboral',
      description: 'Levante-se para fazer um exercício simples.',
      interval: const Duration(hours: 1),
    ),
  ];

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  void toggleReminder(String id, bool enabled) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].enabled = enabled;
      notifyListeners();
      if (enabled) {
        _scheduleReminder(_reminders[index]);
      }
    }
  }

  void updateReminderInterval(String id, Duration interval) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].interval = interval;
      notifyListeners();
    }
  }

  void _scheduleReminder(Reminder reminder) async {
    await Future.delayed(reminder.interval);
    if (reminder.enabled) {
      NotificationService.showNotification(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.description,
        channelId: reminder.id, // O canal é igual ao id do lembrete
      );
      // Reagendar se ainda estiver ativo
      _scheduleReminder(reminder);
    }
  }
} 