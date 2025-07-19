import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> createChannelWithSound(String channelId, String channelName, String sound) async {
    final androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Canal para $channelName',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound(sound),
      playSound: true,
    );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<bool> requestNotificationPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      print('Permissões de notificação solicitadas: $granted');
      return granted ?? false;
    }
    return false;
  }

  static Future<bool> areNotificationsEnabled() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final enabled = await androidImplementation.areNotificationsEnabled();
      print('Notificações estão habilitadas: $enabled');
      return enabled ?? false;
    }
    return false;
  }

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(initializationSettings);
    
    // Cria canais personalizados para cada lembrete
    await createChannelWithSound('beber_agua', 'Beber Água', 'beber_agua');
    await createChannelWithSound('posture', 'Arrumar Postura', 'posture');
    await createChannelWithSound('exercise', 'Exercício Laboral', 'exercise');
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelId,
        channelDescription: 'Canal para $channelId',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        // O som já está definido no canal
      );
      final platformChannelSpecifics = NotificationDetails(android: androidDetails);
      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
      );
      print('Notificação enviada com sucesso: $title');
    } catch (e) {
      print('Erro ao enviar notificação: $e');
    }
  }
} 