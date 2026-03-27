import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import 'api_provider.dart';

/// Authentication service for managing user session
/// Uses secure storage for JWT token and provides auth state management
class AuthService extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  final FlutterSecureStorage _secureStorage;
  
  // Cached values for quick access
  String? _cachedToken;
  User? _currentUser;
  bool _isInitialized = false;

  AuthService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Whether the auth service has been initialized
  bool get isInitialized => _isInitialized;

  /// Whether the user is currently logged in
  bool get isLoggedIn => _cachedToken != null && _currentUser != null;

  /// Get the current user (null if not logged in)
  User? get currentUser => _currentUser;

  /// Initialize auth service - call this on app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _cachedToken = await _secureStorage.read(key: _tokenKey);
      final userJson = await _secureStorage.read(key: _userKey);
      if (userJson != null) {
        _currentUser = User.fromJson(_parseJson(userJson));
      }
    } catch (e) {
      // Clear corrupted data
      await _secureStorage.deleteAll();
      _cachedToken = null;
      _currentUser = null;
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Get the current auth token
  Future<String?> getToken() async {
    if (!_isInitialized) await initialize();
    return _cachedToken;
  }

  /// Register a new user
  Future<User> register(String email, String password, String name) async {
    final api = ApiProvider.getApiService(authService: this);
    final response = await api.register(email, password, name);

    final user = User.fromJson(response['user'] as Map<String, dynamic>);
    final token = response['token'] as String;

    await _saveSession(user, token);
    return user;
  }

  /// Log in an existing user
  Future<User> login(String email, String password) async {
    final api = ApiProvider.getApiService(authService: this);
    final response = await api.login(email, password);

    final user = User.fromJson(response['user'] as Map<String, dynamic>);
    final token = response['token'] as String;

    await _saveSession(user, token);
    return user;
  }

  /// Log out the current user
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
    _cachedToken = null;
    _currentUser = null;
    notifyListeners();
  }

  /// Save session data
  Future<void> _saveSession(User user, String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _userKey, value: _toJson(user.toJson()));
    _cachedToken = token;
    _currentUser = user;
    notifyListeners();
  }

  /// Check if token is expired (basic check - JWT decode would be better)
  bool isTokenExpired() {
    // For MVP, we don't decode the JWT
    // In production, you'd decode and check the exp claim
    return _cachedToken == null;
  }

  /// Handle 401 errors - clear session and notify
  Future<void> handleUnauthorized() async {
    await logout();
  }

  // JSON helpers for secure storage
  String _toJson(Map<String, dynamic> map) {
    return map.entries.map((e) => '${e.key}=${e.value}').join('|');
  }

  Map<String, dynamic> _parseJson(String str) {
    final map = <String, dynamic>{};
    for (final pair in str.split('|')) {
      final idx = pair.indexOf('=');
      if (idx > 0) {
        map[pair.substring(0, idx)] = pair.substring(idx + 1);
      }
    }
    return map;
  }
}
