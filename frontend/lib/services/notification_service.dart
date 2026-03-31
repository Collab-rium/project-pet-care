import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/api_config.dart';

/// NotificationService is a minimal local stub for notification functionality.
/// In local-based mode we disable Firebase messaging but keep the API shape
/// so other code can call `initialize()` and `saveTokenToBackend()` safely.
class NotificationService {
  /// Initialize notifications (no-op in local mode)
  static Future<void> initialize() async {
    print('🔕 Notification service disabled (local mode)');
  }

  /// Save device token to backend (keeps original backend call)
  static Future<void> saveTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/device-token'),
        headers: {
          'Content-Type': 'application/json',
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

  /// Refresh device token (no-op in local mode)
  static Future<void> refreshToken() async {
    print('🔕 Notification.refreshToken no-op in local mode');
  }
}
