import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
class FirebaseMsgServices {
  
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize Firebase messaging and request permissions
  Future<void> initializeMessaging() async {
    // Request notification permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveBackgroundNotificationResponse: (payload)
    {

    }
    );

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotification(
          message.notification!.title,
          message.notification!.body,
        );
      }
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get the device's FCM token
    String? token = await messaging.getToken();
    print("Device FCM Token: $token");
    // Save the token to Firestore or send it to your backend for further use
  }

  // Background message handler (for handling notifications when app is in background/terminated)

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}'); 
  }

  // Display the notification as a local notification
Future<void> _showNotification(String? title, String? body) async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'blood_request_channel', // ID
    'Blood Request Notifications', // Name
    description: 'Notifications for blood requests', // Description
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // Create the channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    channel.id,
    channel.name,
    channelDescription: channel.description,
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'tricker'
  );

  NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title,
    body,
    notificationDetails,
  );
 }

  // Fetch FCM tokens for a list of userIds from Firestore
  Future<List<String>> _getFcmTokensForDonors(List<String> userIds) async {
    try {
      List<String> tokens = [];
      for (String userId in userIds) {
        DocumentSnapshot snapshot =
            await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (snapshot.exists) {
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          String? token = userData['fcmToken'];
          if (token != null) {
            tokens.add(token);
          }
        }
      } 
      return tokens;
    } catch (e) {
      print('Error fetching tokens: $e');
      return [];
    }
  }

  // Send notifications to donors
  Future<void> sendNotificationsToDonors(
    List<String> userIds,
    String requestDetails,
  ) async {
    try {

      List<String> tokens = await _getFcmTokensForDonors(userIds);
  Get.snackbar(
          'notification sent',
          'U  have  succssfully sent notification to  ${tokens.length} donors .',
          backgroundColor: Colors.white,
          colorText: Colors.green,
          );
      if (tokens.isNotEmpty) {
        for (String token in tokens) {
          await _sendNotification(token, requestDetails);
        }
         Get.snackbar(
          'notification sent',
          'U  have  succssfully sent notification to  ${tokens.length} donors .',
          backgroundColor: Colors.white,
          colorText: Colors.green,
          );

        print('Notifications sent to ${tokens.length} donors');
      } else {
        print('No valid tokens found for the donors.');
      }
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  // Send notification via Firebase Cloud Messaging (Server-Side Required)
  Future<void> _sendNotification(String token, String requestDetails) async {
    // Firebase Cloud Messaging requires server-side integration
    print('Prepare server-side implementation for sending notification to token: $token');

    // Example payload
    print('Notification payload: Title: Urgent Blood Request, Body: $requestDetails');
  }
}  