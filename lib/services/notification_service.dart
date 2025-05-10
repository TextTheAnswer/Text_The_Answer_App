// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz_init;
// import '../utils/quiz/time_utility.dart';

// class NotificationService {
//   // Singleton pattern
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // Initialize notification settings
//   Future<void> init() async {
//     // Initialize timezone data
//     tz_init.initializeTimeZones();

//     // Android initialization settings
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     // iOS initialization settings
//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     // Initialization settings
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     // Initialize notifications
//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {
//         debugPrint('Notification received: ${details.payload}');
//       },
//     );
//   }

//   // Request notification permissions
//   Future<bool> requestPermission() async {
//     final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
//         _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     final bool? granted = await androidPlugin?.requestPermission();
//     return granted ?? false;
//   }

//   // Schedule notifications for all daily quiz events
//   Future<void> scheduleAllDailyQuizNotifications() async {
//     // Cancel any existing notifications first
//     await cancelAllNotifications();
    
//     // Get all of today's events
//     final events = QuizTimeUtility.getTodayEvents();
//     int id = 1;
    
//     for (var eventTime in events) {
//       // Only schedule if event is in the future
//       if (eventTime.isAfter(DateTime.now())) {
//         // Schedule a notification 15 minutes before the event
//         final reminderTime = eventTime.subtract(const Duration(minutes: 15));
        
//         // If reminder time is still in the future, schedule it
//         if (reminderTime.isAfter(DateTime.now())) {
//           await scheduleNotification(
//             id: id++,
//             title: 'Daily Quiz Reminder',
//             body: 'Quiz event starting in 15 minutes! Get ready to play.',
//             scheduledTime: reminderTime,
//             payload: 'daily_quiz_reminder',
//           );
          
//           debugPrint('Scheduled notification for ${reminderTime.toString()}');
//         }
        
//         // Also schedule a notification at the exact event time
//         await scheduleNotification(
//           id: id++,
//           title: 'Daily Quiz Starting Now',
//           body: 'The daily quiz event is starting now! Join to compete.',
//           scheduledTime: eventTime,
//           payload: 'daily_quiz_start',
//         );
        
//         debugPrint('Scheduled notification for ${eventTime.toString()}');
//       }
//     }
//   }

//   // Schedule a single notification
//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledTime,
//     String? payload,
//   }) async {
//     await _flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(scheduledTime, tz.local),
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_quiz_channel',
//           'Daily Quiz Notifications',
//           channelDescription: 'Notifications for daily quiz events',
//           importance: Importance.high,
//           priority: Priority.high,
//           showWhen: true,
//         ),
//         iOS: const DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       payload: payload,
//     );
//   }

//   // Cancel all notifications
//   Future<void> cancelAllNotifications() async {
//     await _flutterLocalNotificationsPlugin.cancelAll();
//   }

//   // Cancel a specific notification
//   Future<void> cancelNotification(int id) async {
//     await _flutterLocalNotificationsPlugin.cancel(id);
//   }
// } 