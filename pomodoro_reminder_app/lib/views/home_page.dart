import 'package:flutter/material.dart';
import '../widgets/pomodoro_timer.dart';
import 'package:provider/provider.dart';
import '../viewmodels/reminder_viewmodel.dart';
import '../widgets/reminder_card.dart';
import 'settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pomodoroMinutes = 25;

  @override
  void initState() {
    super.initState();
    _loadPomodoroMinutes();
    _checkNotificationPermissions();
  }

  Future<void> _loadPomodoroMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pomodoroMinutes = prefs.getInt('pomodoroMinutes') ?? 25;
    });
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(initialPomodoroMinutes: pomodoroMinutes),
      ),
    );
    if (result != null && result is int) {
      setState(() {
        pomodoroMinutes = result;
      });
    }
  }

  Future<void> _checkNotificationPermissions() async {
    final enabled = await NotificationService.areNotificationsEnabled();
    if (!enabled) {
      // Aguarda um pouco para o app carregar completamente
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _showPermissionDialog();
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissões de Notificação'),
          content: const Text(
            'Para que os lembretes funcionem corretamente, o app precisa de permissão para enviar notificações. '
            'Isso permite que você receba alertas para beber água, arrumar a postura e fazer exercícios.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Agora não'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final granted = await NotificationService.requestNotificationPermissions();
                if (granted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Permissões concedidas! Os lembretes agora funcionarão corretamente.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Permissões negadas. Você pode ativá-las manualmente nas configurações do app.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Permitir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Lembretes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo ao Pomodoro Reminder!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            PomodoroTimer(initialMinutes: pomodoroMinutes),
            const SizedBox(height: 32),
            Text('Lembretes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Consumer<ReminderViewModel>(
              builder: (context, reminderVM, _) {
                return Column(
                  children: [
                    ...reminderVM.reminders.map((reminder) =>
                      ReminderCard(
                        reminder: reminder,
                        onToggle: (value) => reminderVM.toggleReminder(reminder.id, value),
                      )
                    ).toList(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final enabled = await NotificationService.areNotificationsEnabled();
                        if (enabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notificações já estão ativadas!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          _showPermissionDialog();
                        }
                      },
                      child: const Text('Verificar Permissões'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 