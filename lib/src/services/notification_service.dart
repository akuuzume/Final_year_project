import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Request permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted permission for notifications');
        await _setupLocalNotifications();
        await _setupForegroundNotifications();
        await _getFCMToken();
      } else {
        print('❌ User declined or has not accepted notification permissions');
      }
    } catch (e) {
      print('🔥 Error initializing notifications: $e');
    }
  }

  /// Setup local notifications
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsiOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsiOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        print('🔔 Notification tapped: ${response.payload}');
      },
    );

    // Create notification channel for Android
    if (!kIsWeb && Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'clothesline_status_channel',
        'Clothesline Status Updates',
        description: 'Notifications for clothesline cover status changes',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification'),
      );

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.createNotificationChannel(channel);
    }
  }

  /// Setup foreground message handling
  Future<void> _setupForegroundNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });
  }

  /// Get FCM token and store it
  Future<String?> _getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      print('📱 FCM Token: $token');
      
      if (token != null) {
        await _saveTokenToDatabase(token);
      }
      
      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToDatabase);
      
      return token;
    } catch (e) {
      print('🔥 Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToDatabase(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'fcmToken': token,
          'platform': kIsWeb ? 'web' : Platform.operatingSystem,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        print('✅ FCM token saved to Firestore');
      }
    } catch (e) {
      print('🔥 Error saving FCM token: $e');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'clothesline_status_channel',
      'Clothesline Status Updates',
      channelDescription: 'Notifications for clothesline cover status changes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Clothesline Update',
      message.notification?.body ?? 'Status has changed',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  /// Show status change notification
  Future<void> showStatusChangeNotification(bool isExtended) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'clothesline_status_channel',
      'Clothesline Status Updates',
      channelDescription: 'Notifications for clothesline cover status changes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    const String title = '🏠 Clothesline Update';
    final String body = isExtended 
        ? '☂️ Cover has been extended - Your clothes are protected!'
        : '☀️ Cover has been retracted - Perfect drying conditions!';

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: 'status_change:$isExtended',
    );

    print('🔔 Status change notification shown: $body');
  }

  /// Send notification to all users (for admin/system changes)
  Future<void> sendNotificationToAllUsers(String title, String body, {Map<String, dynamic>? data}) async {
    try {
      // Get all user tokens
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('fcmToken', isNotEqualTo: null)
          .get();

      List<String> tokens = [];
      for (var doc in usersSnapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        if (userData['fcmToken'] != null) {
          tokens.add(userData['fcmToken']);
        }
      }

      if (tokens.isNotEmpty) {
        // Note: This would typically be done via Cloud Functions
        // For now, we'll just show local notification
        await _showDirectNotification(title, body);
        print('📤 Would send notification to ${tokens.length} users');
      }
    } catch (e) {
      print('🔥 Error sending notifications to all users: $e');
    }
  }

  /// Show direct local notification
  Future<void> _showDirectNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'clothesline_status_channel',
      'Clothesline Status Updates',
      channelDescription: 'Notifications for clothesline cover status changes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
