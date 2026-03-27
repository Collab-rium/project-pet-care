import '../models/models.dart';

/// Abstract API service interface
/// Implemented by MockApiService (for development) and HttpApiService (for real backend)
abstract class ApiService {
  // Authentication
  Future<Map<String, dynamic>> register(String email, String password, String name);
  Future<Map<String, dynamic>> login(String email, String password);

  // Pets
  Future<List<Pet>> getPets();
  Future<Pet> getPet(String petId);
  Future<Pet> createPet(Map<String, dynamic> petData);
  Future<Pet> updatePet(String petId, Map<String, dynamic> data);
  Future<void> deletePet(String petId);
  Future<Pet> uploadPetPhoto(String petId, String filePath);

  // Reminders
  Future<List<Reminder>> getReminders({String? petId});
  Future<Reminder> getReminder(String reminderId);
  Future<Reminder> createReminder(Map<String, dynamic> reminderData);
  Future<Reminder> updateReminder(String reminderId, Map<String, dynamic> data);
  Future<void> deleteReminder(String reminderId);

  // Dashboard
  Future<DashboardData> getDashboard();

  // Health
  Future<Map<String, dynamic>> healthCheck();
}
