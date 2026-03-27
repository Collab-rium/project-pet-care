/// Task model for dashboard (derived from Reminder)
class Task {
  final String id;
  final String petId;
  final String? petName;
  final String message;
  final String scheduledTime; // ISO 8601 string
  final String status;
  final bool isOverdue;
  final String type;
  final String repeat;

  Task({
    required this.id,
    required this.petId,
    this.petName,
    required this.message,
    required this.scheduledTime,
    required this.status,
    required this.isOverdue,
    required this.type,
    required this.repeat,
  });

  // Alias for message (UI uses as title)
  String get title => message;

  // Get time portion from scheduledTime
  String? get scheduledTimeOnly {
    try {
      final timePart = scheduledTime.split('T')[1];
      return timePart.substring(0, 5);
    } catch (_) {
      return null;
    }
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      petId: json['petId'] as String,
      petName: json['petName'] as String?,
      message: json['message'] as String,
      scheduledTime: json['scheduledTime'] as String,
      status: json['status'] as String,
      isOverdue: json['isOverdue'] as bool? ?? false,
      type: json['type'] as String? ?? 'other',
      repeat: json['repeat'] as String? ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      if (petName != null) 'petName': petName,
      'message': message,
      'scheduledTime': scheduledTime,
      'status': status,
      'isOverdue': isOverdue,
      'type': type,
      'repeat': repeat,
    };
  }
}

/// Dashboard summary counts
class DashboardSummary {
  final int total;
  final int completed;
  final int pending;
  final int overdue;

  DashboardSummary({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      total: json['total'] as int,
      completed: json['completed'] as int,
      pending: json['pending'] as int,
      overdue: json['overdue'] as int,
    );
  }
}

/// Dashboard data returned by /dashboard/today
class DashboardData {
  final String date;
  final List<Task> tasks;
  final DashboardSummary summary;

  DashboardData({
    required this.date,
    required this.tasks,
    required this.summary,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return DashboardData(
      date: data['date'] as String,
      tasks: (data['tasks'] as List<dynamic>)
          .map((t) => Task.fromJson(t as Map<String, dynamic>))
          .toList(),
      summary: DashboardSummary.fromJson(data['summary'] as Map<String, dynamic>),
    );
  }
}
