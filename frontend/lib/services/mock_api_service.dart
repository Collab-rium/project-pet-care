import 'dart:math';
import '../models/models.dart';
import 'api_service.dart';

/// Mock API service for development and testing
/// Returns hardcoded data and simulates network delay
class MockApiService implements ApiService {
  // In-memory state
  final Map<String, User> _users = {};
  final Map<String, Pet> _pets = {};
  final Map<String, Reminder> _reminders = {};
  String? _currentUserId;

  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Generate unique IDs
  String _generateId(String prefix) {
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';
  }

  MockApiService() {
    // Initialize with seed data
    _initSeedData();
  }

  void _initSeedData() {
    // Create demo user
    final demoUser = User(
      id: 'user-demo',
      email: 'demo@example.com',
      name: 'Demo User',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
    _users[demoUser.id] = demoUser;

    // Create demo pets
    final now = DateTime.now();
    final pet1 = Pet(
      id: 'pet-1',
      ownerId: demoUser.id,
      name: 'Buddy',
      type: 'dog',
      age: 3,
      breed: 'Golden Retriever',
      photoUrl: null,
      createdAt: now.subtract(const Duration(days: 20)).toIso8601String(),
    );
    final pet2 = Pet(
      id: 'pet-2',
      ownerId: demoUser.id,
      name: 'Whiskers',
      type: 'cat',
      age: 2,
      breed: 'Tabby',
      photoUrl: null,
      createdAt: now.subtract(const Duration(days: 15)).toIso8601String(),
    );
    _pets[pet1.id] = pet1;
    _pets[pet2.id] = pet2;

    // Create demo reminders
    final reminder1 = Reminder(
      id: 'rem-1',
      petId: pet1.id,
      userId: demoUser.id,
      type: 'feeding',
      message: 'Feed Buddy breakfast',
      scheduledTime: DateTime(now.year, now.month, now.day, 8, 0).toIso8601String(),
      repeat: 'daily',
      status: 'pending',
      createdAt: now.subtract(const Duration(days: 10)).toIso8601String(),
    );
    final reminder2 = Reminder(
      id: 'rem-2',
      petId: pet1.id,
      userId: demoUser.id,
      type: 'exercise',
      message: 'Walk Buddy',
      scheduledTime: DateTime(now.year, now.month, now.day, 17, 0).toIso8601String(),
      repeat: 'daily',
      status: 'pending',
      createdAt: now.subtract(const Duration(days: 10)).toIso8601String(),
    );
    final reminder3 = Reminder(
      id: 'rem-3',
      petId: pet2.id,
      userId: demoUser.id,
      type: 'medication',
      message: 'Give Whiskers vitamins',
      scheduledTime: DateTime(now.year, now.month, now.day - 1, 9, 0).toIso8601String(), // Yesterday - overdue
      repeat: 'daily',
      status: 'pending',
      createdAt: now.subtract(const Duration(days: 5)).toIso8601String(),
    );
    _reminders[reminder1.id] = reminder1;
    _reminders[reminder2.id] = reminder2;
    _reminders[reminder3.id] = reminder3;
  }

  // Authentication
  @override
  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    await _delay();

    // Check if email exists
    final existingUser = _users.values.where((u) => u.email == email).firstOrNull;
    if (existingUser != null) {
      throw Exception('Email already registered');
    }

    // Create new user
    final user = User(
      id: _generateId('user'),
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
    _users[user.id] = user;
    _currentUserId = user.id;

    return {
      'user': user.toJson(),
      'token': 'mock-jwt-token-${user.id}',
    };
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await _delay();

    // Find user by email
    final user = _users.values.where((u) => u.email == email).firstOrNull;
    
    // For mock, accept demo@example.com with any password, or any registered user
    if (user == null) {
      throw Exception('Invalid credentials');
    }

    _currentUserId = user.id;
    return {
      'user': user.toJson(),
      'token': 'mock-jwt-token-${user.id}',
    };
  }

  // Pets
  @override
  Future<List<Pet>> getPets() async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');
    
    return _pets.values
        .where((p) => p.ownerId == _currentUserId)
        .toList();
  }

  @override
  Future<Pet> getPet(String petId) async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');

    final pet = _pets[petId];
    if (pet == null) throw Exception('Pet not found');
    if (pet.ownerId != _currentUserId) throw Exception('Forbidden');
    
    return pet;
  }

  @override
  Future<Pet> createPet(Map<String, dynamic> petData) async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');

    final pet = Pet(
      id: _generateId('pet'),
      ownerId: _currentUserId!,
      name: petData['name'] as String,
      type: petData['type'] as String,
      age: petData['age'] as int?,
      breed: petData['breed'] as String?,
      photoUrl: null,
      createdAt: DateTime.now().toIso8601String(),
    );
    _pets[pet.id] = pet;
    return pet;
  }

  @override
  Future<Pet> updatePet(String petId, Map<String, dynamic> data) async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');

    final pet = _pets[petId];
    if (pet == null) throw Exception('Pet not found');
    if (pet.ownerId != _currentUserId) throw Exception('Forbidden');

    final updated = pet.copyWith(
      name: data['name'] as String? ?? pet.name,
      type: data['type'] as String? ?? pet.type,
      age: data['age'] as int? ?? pet.age,
      breed: data['breed'] as String? ?? pet.breed,
      updatedAt: DateTime.now().toIso8601String(),
    );
    _pets[petId] = updated;
    return updated;
  }

  @override
  Future<void> deletePet(String petId) async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');

    final pet = _pets[petId];
    if (pet == null) throw Exception('Pet not found');
    if (pet.ownerId != _currentUserId) throw Exception('Forbidden');

    _pets.remove(petId);
    // Also delete related reminders
    _reminders.removeWhere((_, r) => r.petId == petId);
  }

  @override
  Future<Pet> uploadPetPhoto(String petId, String filePath) async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');

    final pet = _pets[petId];
    if (pet == null) throw Exception('Pet not found');
    if (pet.ownerId != _currentUserId) throw Exception('Forbidden');

    // Mock: just set a placeholder URL
    final updated = pet.copyWith(
      photoUrl: 'https://placekitten.com/200/200?pet=$petId',
      updatedAt: DateTime.now().toIso8601String(),
    );
    _pets[petId] = updated;
    return updated;
  }

  // Reminders
  @override
  Future<List<Reminder>> getReminders({String? petId}) async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');

    var reminders = _reminders.values.where((r) => r.userId == _currentUserId);
    if (petId != null) {
      reminders = reminders.where((r) => r.petId == petId);
    }
    return reminders.toList();
  }

  @override
  Future<Reminder> getReminder(String reminderId) async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');

    final reminder = _reminders[reminderId];
    if (reminder == null) throw Exception('Reminder not found');
    if (reminder.userId != _currentUserId) throw Exception('Forbidden');
    
    return reminder;
  }

  @override
  Future<Reminder> createReminder(Map<String, dynamic> reminderData) async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');

    // Verify pet exists and belongs to user
    final petId = reminderData['petId'] as String;
    final pet = _pets[petId];
    if (pet == null) throw Exception('Pet not found');
    if (pet.ownerId != _currentUserId) throw Exception('Forbidden');

    final reminder = Reminder(
      id: _generateId('rem'),
      petId: petId,
      userId: _currentUserId!,
      type: reminderData['type'] as String,
      message: reminderData['message'] as String,
      scheduledTime: reminderData['scheduledTime'] as String,
      repeat: reminderData['repeat'] as String? ?? 'none',
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
    );
    _reminders[reminder.id] = reminder;
    return reminder;
  }

  @override
  Future<Reminder> updateReminder(String reminderId, Map<String, dynamic> data) async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');

    final reminder = _reminders[reminderId];
    if (reminder == null) throw Exception('Reminder not found');
    if (reminder.userId != _currentUserId) throw Exception('Forbidden');

    final updated = reminder.copyWith(
      type: data['type'] as String? ?? reminder.type,
      message: data['message'] as String? ?? reminder.message,
      scheduledTime: data['scheduledTime'] as String? ?? reminder.scheduledTime,
      repeat: data['repeat'] as String? ?? reminder.repeat,
      status: data['status'] as String? ?? reminder.status,
      updatedAt: DateTime.now().toIso8601String(),
    );
    _reminders[reminderId] = updated;
    return updated;
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');

    final reminder = _reminders[reminderId];
    if (reminder == null) throw Exception('Reminder not found');
    if (reminder.userId != _currentUserId) throw Exception('Forbidden');

    _reminders.remove(reminderId);
  }

  // Dashboard
  @override
  Future<DashboardData> getDashboard() async {
    await _delay();
    if (_currentUserId == null) throw Exception('Not authenticated');

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // Get user's reminders for today + overdue
    final userReminders = _reminders.values
        .where((r) => r.userId == _currentUserId)
        .toList();

    final tasks = <Task>[];
    for (final reminder in userReminders) {
      final scheduledTime = DateTime.parse(reminder.scheduledTime);
      final isToday = scheduledTime.isAfter(todayStart) &&
          scheduledTime.isBefore(todayEnd);
      final isOverdue = scheduledTime.isBefore(now) &&
          reminder.status == 'pending';

      if (isToday || isOverdue) {
        final pet = _pets[reminder.petId];
        tasks.add(Task(
          id: reminder.id,
          petId: reminder.petId,
          petName: pet?.name,
          message: reminder.message,
          scheduledTime: reminder.scheduledTime,
          status: reminder.status,
          isOverdue: isOverdue,
          type: reminder.type,
          repeat: reminder.repeat,
        ));
      }
    }

    // Calculate summary
    final total = tasks.length;
    final completed = tasks.where((t) => t.status == 'completed').length;
    final overdue = tasks.where((t) => t.isOverdue && t.status != 'completed').length;
    final pending = total - completed;

    return DashboardData(
      date: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      tasks: tasks,
      summary: DashboardSummary(
        total: total,
        completed: completed,
        pending: pending,
        overdue: overdue,
      ),
    );
  }

  // Health
  @override
  Future<Map<String, dynamic>> healthCheck() async {
    await _delay();
    return {
      'ok': true,
      'uptime': 12345.67,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Helper to set current user (for testing)
  void setCurrentUser(String? userId) {
    _currentUserId = userId;
  }
}
