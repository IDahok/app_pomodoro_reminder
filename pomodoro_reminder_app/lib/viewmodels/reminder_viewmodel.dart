import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

class ReminderViewModel extends ChangeNotifier {
  final List<Reminder> _reminders = [
    Reminder(
      id: 'beber_agua',
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

  Timer? _checkTimer;
  final Map<String, DateTime> _lastTriggered = {};

  ReminderViewModel() {
    _loadLastTriggeredTimes();
    _startPeriodicCheck();
  }

  List<Reminder> get reminders => List.unmodifiable(_reminders);

  Future<void> _loadLastTriggeredTimes() async {
    final prefs = await SharedPreferences.getInstance();
    for (var reminder in _reminders) {
      final timestamp = prefs.getInt('last_triggered_${reminder.id}');
      if (timestamp != null) {
        _lastTriggered[reminder.id] = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    }
  }

  Future<void> _saveLastTriggeredTime(String reminderId) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt('last_triggered_$reminderId', now.millisecondsSinceEpoch);
    _lastTriggered[reminderId] = now;
  }

  void toggleReminder(String id, bool enabled) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].enabled = enabled;
      notifyListeners();
      
      if (enabled) {
        // Só reseta o horário se nunca foi disparado antes
        if (!_lastTriggered.containsKey(id)) {
          _saveLastTriggeredTime(id);
        }
        print('Lembrete ativado:  [${_reminders[index].title} - Intervalo: ${_reminders[index].interval.inMinutes} minutos');
      } else {
        print('Lembrete desativado: ${_reminders[index].title}');
      }
    }
  }

  void updateReminderInterval(String id, Duration interval) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].interval = interval;
      notifyListeners();
      
      // Reseta o horário se estiver ativo
      if (_reminders[index].enabled) {
        _lastTriggered.remove(id);
        _saveLastTriggeredTime(id);
        print('Intervalo atualizado para ${_reminders[index].title}: ${interval.inMinutes} minutos');
      }
    }
  }

  void _startPeriodicCheck() {
    // Verifica a cada 1 segundo para maior precisão
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkAllReminders();
    });
  }

  void _checkAllReminders() {
    final now = DateTime.now();
    
    for (var reminder in _reminders) {
      if (!reminder.enabled) continue;
      
      final lastTriggered = _lastTriggered[reminder.id];
      if (lastTriggered == null) {
        // Primeira vez, salva o horário atual
        _saveLastTriggeredTime(reminder.id);
        continue;
      }
      
      final timeSinceLastTrigger = now.difference(lastTriggered);
      
      if (timeSinceLastTrigger >= reminder.interval) {
        print('Disparando lembrete: ${reminder.title} (passaram ${timeSinceLastTrigger.inMinutes} minutos)');
        _triggerReminder(reminder);
        _saveLastTriggeredTime(reminder.id);
      }
    }
  }

  void _triggerReminder(Reminder reminder) {
    NotificationService.showNotification(
      id: reminder.id.hashCode,
      title: reminder.title,
      body: reminder.description,
      channelId: reminder.id,
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
} 