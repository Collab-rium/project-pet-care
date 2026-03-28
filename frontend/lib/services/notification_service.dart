import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/api_config.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  /// Initialize Firebase Messaging and request permissions
  static Future<void> initialize() async {
    try {
      // Request permission for iOS
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carryForward: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('🔔 Permission status: ${settings.authorizationStatus}');

      // Get device token
      final token = await _messaging.getToken();
      print('📱 Device Token: $token');

      // Save token to backend
      if (token != null) {
        await saveTokenToBackend(token);
      }

      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📨 Foreground message received:');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        // You can display a local notification or update UI here
      });

      // Handle messages when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📬 App opened from notification:');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        // Navigate to relevant screen
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      print('✅ Notification service initialized');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  /// Save device token to backend
  static Future<void> saveTokenToBackend(String token) async {
    try {
      // Get stored JWT token
      // Note: You'll need to pass the JWT token from your auth service
      // This is a simplified version - adjust based on your auth implementation
      
      final response = await http.post(
        Uri.parse('$API_BASE_URL/device-token'),
        headers: {
          'Content-Type': 'application/json',
          // Add Authorization header with JWT token
          // 'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        print('✅ Device token saved to backend');
      } else {
        print('❌ Failed to save device token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error saving token to backend: $e');
    }
  }

  /// Handle background messages
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('🔔 Background message received:');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    // Handle background message
  }

  /// Refresh device token (call this periodically or when token changes)
  static Future<void> refreshToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await saveTokenToBackend(token);
      }
    } catch (e) {
      print('❌ Error refreshing token: $e');
    }
  }
}
