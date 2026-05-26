import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../data/network/base_api_service.dart';
import '../utils/constants.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends GetxController {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  String? _currentToken;

  Future<void> init() async {
    print("🚀 NotificationService INIT STARTED");
    tz.initializeTimeZones();

    // Initialize Firebase if not already initialized
    await Firebase.initializeApp();

    /// 🔐 Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("🔔 Permission Status: ${settings.authorizationStatus}");

    // Get FCM Token
    _currentToken = await _firebaseMessaging.getToken();
    print("FCM Token: $_currentToken");

    if (_currentToken != null) {
      uploadToken(); // Use the standardized upload method
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _currentToken = newToken;
      uploadToken();
    });

    /// 🔔 Initialize Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click here
        print("Notification clicked: ${response.payload}");
      },
    );

    /// 📩 Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground Message Received: ${message.notification?.title}");
      _handleMessage(message);
      _showLocalNotification(message);
    });

    /// 📲 Notification Click (App in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 Notification Clicked (Background): ${message.notification?.title}");
      _handleMessage(message);
    });

    _loadNotifications();
    fetchNotifications(); // Initial fetch from server
    print("🚀 NotificationService INIT COMPLETED");
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // If the date is in the past, don't schedule
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mirchi_reminders',
          'Mirchi OTT Reminders',
          channelDescription: 'Reminders for upcoming movies and series',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _localNotificationsPlugin.cancel(id);
  }

  // Future<void> cancelNotification(int id) async {
  //   await _localNotificationsPlugin.cancel(id);
  // }

  /// 📡 Standardized method to send token to backend
  Future<void> uploadToken() async {
    try {
      // 🔄 If token is not yet available, try to fetch it
      if (_currentToken == null) {
        print("🔍 Attempting to fetch FCM Token...");
        _currentToken = await _firebaseMessaging.getToken();
      }

      if (_currentToken == null) {
        print("⚠️ FCM Token is still NULL. Cannot upload.");
        return;
      }

      print("📡 Uploading FCM Token to Backend: $_currentToken");
      final BaseApiService apiService = Get.find<BaseApiService>();
      final response = await apiService.postApi(
        AppConstants.updateFcmToken,
        {'token': _currentToken},
      );
      print("✅ FCM Token Synced Successfully: $response");
    } catch (e) {
      print("⚠️ FCM Token Sync Failed: $e");
    }
  }

  /// 📥 Fetch Notifications from Backend
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final BaseApiService apiService = Get.find<BaseApiService>();
      final response = await apiService.getApi(AppConstants.getNotifications);
      
      if (response != null && response['success'] == true) {
        final List fetchedList = response['notifications'] ?? [];
        notifications.assignAll(fetchedList.map((e) {
          return {
            'id': e['_id'],
            'title': e['title'],
            'body': e['message'],
            'time': e['sentAt'] ?? e['createdAt'] ?? DateTime.now().toString(),
            'isRead': e['isRead'] ?? false,
            'type': e['type'],
          };
        }).toList());
        _saveNotifications();
        print("✅ Fetched ${notifications.length} notifications from server");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Mark Single Notification as Read
  Future<void> markAsRead(int index) async {
    if (index >= notifications.length) return;
    if (notifications[index]['isRead'] == true) return;

    final String? id = notifications[index]['id'];
    if (id == null) {
      notifications[index]['isRead'] = true;
      notifications.refresh();
      _saveNotifications();
      return;
    }

    try {
      final BaseApiService apiService = Get.find<BaseApiService>();
      final response = await apiService.pacthApi(AppConstants.markNotificationRead(id), {});
      
      if (response != null && response['success'] == true) {
        notifications[index]['isRead'] = true;
        notifications.refresh();
        _saveNotifications();
      }
    } catch (e) {
      print("Error marking notification read: $e");
    }
  }

  /// ✅ Mark All Notifications as Read
  Future<void> markAllAsRead() async {
    try {
      final BaseApiService apiService = Get.find<BaseApiService>();
      final response = await apiService.pacthApi(AppConstants.markAllNotificationsRead, {});
      
      if (response != null && response['success'] == true) {
        for (var n in notifications) {
          n['isRead'] = true;
        }
        notifications.refresh();
        _saveNotifications();
      }
    } catch (e) {
      print("Error marking all read: $e");
    }
  }

  /// ❌ Delete Single Notification
  Future<void> deleteSingleNotification(int index) async {
    if (index >= notifications.length) return;
    
    final String? id = notifications[index]['id'];
    if (id == null) {
      notifications.removeAt(index);
      _saveNotifications();
      return;
    }

    try {
      final BaseApiService apiService = Get.find<BaseApiService>();
      final response = await apiService.deleteApi(AppConstants.deleteNotification(id), {});
      
      if (response != null && response['success'] == true) {
        notifications.removeAt(index);
        _saveNotifications();
      }
    } catch (e) {
      print("Error deleting notification: $e");
      // Fallback: Remove locally if API fails
      notifications.removeAt(index);
      _saveNotifications();
    }
  }

  /// 🧹 Clear All Notifications (Local)
  void clearNotifications() {
    notifications.clear();
    _saveNotifications();
  }

  void _handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      print("📩 Processing Message: ${message.notification?.title}");
      fetchNotifications(); // Refresh list from server
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (message.notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'mirchi_ott_channel', // Channel ID
      'Mirchi OTT Notifications', // Channel Name
      channelDescription: 'Important notifications from Mirchi OTT',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: message.data.toString(),
    );
  }

  void _loadNotifications() {
    try {
      var box = Hive.box('appBox');
      List? saved = box.get('notifications');
      if (saved != null) {
        // ✅ Robust conversion from Map<dynamic, dynamic> to Map<String, dynamic>
        final List<Map<String, dynamic>> convertedList = saved.map((item) {
          return Map<String, dynamic>.from(item as Map);
        }).toList();
        
        notifications.assignAll(convertedList);
        print("✅ Loaded ${notifications.length} saved notifications");
      }
    } catch (e) {
      print("❌ Error loading notifications from Hive: $e");
    }
  }

  void _saveNotifications() {
    try {
      var box = Hive.box('appBox');
      box.put('notifications', notifications.toList());
    } catch (e) {
      print("❌ Error saving notifications to Hive: $e");
    }
  }
}
