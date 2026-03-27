/// Reminder model matching API contract
class Reminder {
  final String id;
  final String petId;
  final String userId;
  final String type; // feeding, medication, grooming, exercise, vet_appointment, other
  final String message; // title/message of the reminder
  final String scheduledTime; // ISO 8601 date string
  final String repeat; // none, daily, weekly, monthly
  final String status; // pending, completed, skipped
  final String createdAt;
  final String? updatedAt;

  Reminder({
    required this.id,
    required this.petId,
    required this.userId,
    required this.type,
    required this.message,
    required this.scheduledTime,
    required this.repeat,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  // Alias for message (used by UI as title)
  String get title => message;

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      petId: json['petId'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      scheduledTime: json['scheduledTime'] as String,
      repeat: json['repeat'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'userId': userId,
      'type': type,
      'message': message,
      'scheduledTime': scheduledTime,
      'repeat': repeat,
      'status': status,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  Reminder copyWith({
    String? id,
    String? petId,
    String? userId,
    String? type,
    String? message,
    String? scheduledTime,
    String? repeat,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      message: message ?? this.message,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      repeat: repeat ?? this.repeat,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper to extract date from scheduledTime
  String? get scheduledDate {
    try {
      return scheduledTime.split('T')[0];
    } catch (_) {
      return null;
    }
  }

  // Helper to extract time (HH:MM) from scheduledTime
  String? get scheduledTimeOnly {
    try {
      final timePart = scheduledTime.split('T')[1];
      return timePart.substring(0, 5);
    } catch (_) {
      return null;
    }
  }

  /// Valid reminder types
  static const List<String> validTypes = [
    'feeding',
    'medication',
    'grooming',
    'exercise',
    'vet_appointment',
    'other'
  ];

  /// Valid repeat options
  static const List<String> validRepeats = ['none', 'daily', 'weekly', 'monthly'];

  /// Valid status options
  static const List<String> validStatuses = ['pending', 'completed', 'skipped'];
}
