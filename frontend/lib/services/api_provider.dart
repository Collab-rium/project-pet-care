import '../config/api_config.dart';
import 'api_service.dart';
import 'mock_api_service.dart';
import 'http_api_service.dart';
import 'auth_service.dart';

/// Factory to get the appropriate API service based on configuration
class ApiProvider {
  static ApiService? _instance;

  /// Get singleton API service instance
  static ApiService getApiService({AuthService? authService}) {
    _instance ??= useMockApi
        ? MockApiService()
        : HttpApiService(authService: authService);
    return _instance!;
  }

  /// Reset the singleton (useful for testing)
  static void reset() {
    _instance = null;
  }
}
