import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  Logger log = Logger();
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService();

  static Future<void> initializeLocalNotifications() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Montevideo'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channel_3',
      'Schedule Notification Channel',
      description: 'your channel description',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> initializeFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showLocalNotification(message.notification);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap
    });
  }

  void requestIOSPermissions() {
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    ).then((value) {
    });
  }

  static void showLocalNotification(RemoteNotification? notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_3',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    try{
    await _flutterLocalNotificationsPlugin.show(
      0,
      notification?.title ?? 'POR DEFECTO',
      notification?.body ?? 'POR DEFECTO',
      platformChannelSpecifics,
      payload: 'item x',
    );
    } catch(e){
      Logger().d(e);
    }
  }

  Future<void> sendNotification(String token, String title, String body) async {
    const String apiUrl =
        'https://fcm-server-halhc5ozba-uc.a.run.app/sendNotification';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      log.d('Notification sent successfully');
    } else {
      log.e('Error sending notification: ${response.body}');
    }
  }

  static Future<void> showPeriodicNotifications({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_3', // Ensure this matches the channel ID created above
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      1,
      title,
      body,
      RepeatInterval.everyMinute,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }
  tz.TZDateTime convertTimestampToTZDateTime(Timestamp timestamp,tz.Location timezone){
    DateTime utcDateTime = timestamp.toDate().toUtc();
    Duration toSubstract = const Duration(hours: 1);
    return tz.TZDateTime.from(utcDateTime, timezone).subtract(toSubstract);
  }

  Future<void> scheduleNotification(
      String title, String body, Timestamp inicio) async {
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Montevideo'));
      
      final localTime = tz.local;
      final scheduledTime = convertTimestampToTZDateTime(inicio, localTime);

      log.d('Scheduling notification at $scheduledTime for $scheduledTime');

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'channel_3', // Ensure this matches the channel ID created above
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        2,
        title,
        body,
        scheduledTime,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      log.d('Notification scheduled successfully');
    } catch (e) {
      log.e('Error scheduling notification: $e');
    }
  }

  Future<void> pendingNotifications() async {
    List<PendingNotificationRequest> list =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (var l in list) {
      log.d('Pending notification: ${l.title}');
    }
  }
}
