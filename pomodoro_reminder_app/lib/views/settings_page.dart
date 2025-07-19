import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/reminder_viewmodel.dart';

class SettingsPage extends StatefulWidget {
  final int initialPomodoroMinutes;
  const SettingsPage({super.key, required this.initialPomodoroMinutes});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int pomodoroMinutes;
  late Map<String, int> reminderMinutes;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    pomodoroMinutes = widget.initialPomodoroMinutes;
    final reminders = context.read<ReminderViewModel>().reminders;
    reminderMinutes = {
      for (var r in reminders) r.id: r.interval.inMinutes
    };
  }

  Future<void> saveSettings() async {
    setState(() => saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pomodoroMinutes', pomodoroMinutes);
    for (var entry in reminderMinutes.entries) {
      await prefs.setInt('reminder_${entry.key}_minutes', entry.value);
    }
    // Atualiza ViewModel
    final reminderVM = context.read<ReminderViewModel>();
    for (var r in reminderVM.reminders) {
      reminderVM.updateReminderInterval(r.id, Duration(minutes: reminderMinutes[r.id]!));
    }
    setState(() => saving = false);
    if (mounted) Navigator.pop(context, pomodoroMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final reminderVM = context.watch<ReminderViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Tempo do Pomodoro (minutos):', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: 10,
                    max: 90,
                    divisions: 16,
                    value: pomodoroMinutes.toDouble(),
                    label: pomodoroMinutes.toString(),
                    onChanged: (v) => setState(() => pomodoroMinutes = v.round()),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text('$pomodoroMinutes', textAlign: TextAlign.center),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Intervalos dos lembretes (minutos):', style: TextStyle(fontWeight: FontWeight.bold)),
            ...reminderVM.reminders.map((r) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        min: 5,
                        max: 120,
                        divisions: 23,
                        value: reminderMinutes[r.id]!.toDouble(),
                        label: reminderMinutes[r.id].toString(),
                        onChanged: (v) => setState(() => reminderMinutes[r.id] = v.round()),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text('${reminderMinutes[r.id]}', textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ],
            )),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: saving ? null : saveSettings,
              child: saving ? const CircularProgressIndicator() : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
} 