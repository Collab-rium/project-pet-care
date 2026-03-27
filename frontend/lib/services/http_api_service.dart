import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// HTTP API service for real backend communication
class HttpApiService implements ApiService {
  final AuthService _authService;
  final String _baseUrl;

  HttpApiService({AuthService? authService, String? baseUrl})
      : _authService = authService ?? AuthService(),
        _baseUrl = baseUrl ?? getApiBaseUrl();

  /// Get authorization headers
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final token = await _authService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Handle HTTP response errors
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? body['error'] ?? 'Unknown error';
      throw Exception(message);
    }
  }

  // Authentication
  @override
  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: await _getHeaders(withAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );
    _handleError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: await _getHeaders(withAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    _handleError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Pets
  @override
  Future<List<Pet>> getPets() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pets'),
      headers: await _getHeaders(),
    );
    _handleError(response);
    final body = jsonDecode(response.body);
    final List data = body['data'] ?? body;
    return data.map((p) => Pet.fromJson(p as Map<String, dynamic>)).toList();
  }

  @override
  Future<Pet> getPet(String petId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pets/$petId'),
      headers: await _getHeaders(),
    );
    _handleError(response);
    final body = jsonDecode(response.body);
    final data = body['data'] ?? body;
    return Pet.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Pet> createPet(Map<String, dynamic> petData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/pets'),
      headers: await _getHeaders(),
      body: jsonEncode(petData),
    );
    _handleError(response);
    final body = jsonDecode(response.body);
    final data = body['data'] ?? body;
    return Pet.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Pet> updatePet(String petId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/pets/$petId'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    _handleError(response);
    final body = jsonDecode(response.body);
    final responseData = body['data'] ?? body;
    return Pet.fromJson(responseData as Map<String, dynamic>);
  }

  @override
  Future<void> deletePet(String petId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/pets/$petId'),
      headers: await _getHeaders(),
    );
    _handleError(response);
  }

  @override
  Future<Pet> uploadPetPhoto(String petId, String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/pets/$petId/photo'),
    );
    
    final token = await _authService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.files.add(await http.MultipartFile.fromPath('photo', filePath));
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    _handleError(response);
    
    final body = jsonDecode(response.body);
    final data = body['data'] ?? body;
    return Pet.fromJson(data as Map<String, dynamic>);
  }

  // Reminders
  @override
  Future<List<Reminder>> getReminders({String? petId}) async {
    var url = '$_baseUrl/reminders';
    if (petId != null) {
      url += '?petId=$petId';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );
    _handleError(response);
    final body = jsonDecode(response.body);
    final List data = body['data'] ?? body;
    return data.map((r) => Reminder.fromJson(r as Map<String, dynamic>)).toList();
  }

  @override
  Future<Reminder> getReminder(String reminderId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/reminders/$reminderId'),
      headers: await _getHeaders(),
    );
    _handleError(response);
    final body = jsonDecode(response.body);
    final data = body['data'] ?? body;
    return Reminder.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Reminder> createReminder(Map<String, dynamic> reminderData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reminders'),
      headers: await _getHeaders(),
      body: jsonEncode(reminderData),
    );
    _handleError(response);
    final body = jsonDecode(response.body);
    final data = body['data'] ?? body;
    return Reminder.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Reminder> updateReminder(String reminderId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/reminders/$reminderId'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    _handleError(response);
    final body = jsonDecode(response.body);
    final responseData = body['data'] ?? body;
    return Reminder.fromJson(responseData as Map<String, dynamic>);
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/reminders/$reminderId'),
      headers: await _getHeaders(),
    );
    _handleError(response);
  }

  // Dashboard
  @override
  Future<DashboardData> getDashboard() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/dashboard/today'),
      headers: await _getHeaders(),
    );
    _handleError(response);
    return DashboardData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Health
  @override
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/health'),
      headers: await _getHeaders(withAuth: false),
    );
    _handleError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
