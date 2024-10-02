import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Noti {
  static Future initialise(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialise = AndroidInitializationSettings('@mipmap/crimelogo'); // Ensure the correct path
    var iosInitialise = DarwinInitializationSettings();
    var initialise = InitializationSettings(android: androidInitialise, iOS: iosInitialise);
    
    await flutterLocalNotificationsPlugin.initialize(initialise,
        onDidReceiveNotificationResponse: (response) {
          // Handle the response when a notification is tapped
         // onDidReceiveLocalNotification(response.notificationId, response.payload);
        });
  }

  static Future showNoti({required FlutterLocalNotificationsPlugin fln}) async {
    AndroidNotificationDetails andPlat = AndroidNotificationDetails(
      'whatever_name_1234', // Channel ID
      'channel_name',       // Channel Name
      playSound: true,
      importance: Importance.high,
      priority: Priority.high,
      //sound: RawResourceAndroidNotificationSound();
    );
    var not = NotificationDetails(
      android: andPlat,
      iOS: DarwinNotificationDetails(),
    );
    await fln.show(0, 'SHAKE DETECTED', 'Was that ACCIDENTAL?', not);
  }

  // Handle local notifications
  static void onDidReceiveLocalNotification(int id, String? payload) {
    // You can handle the payload or do something when the notification is tapped
    // Pass the context when showing the dialog
    // NOTE: You'll need to ensure this is called with a valid context.
  }
}
