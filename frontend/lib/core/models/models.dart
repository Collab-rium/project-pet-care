class User {
  final String id;
  final String username;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      passwordHash: map['password_hash'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Pet {
  final String id;
  final String userId;
  final String name;
  final String species;
  final String? breed;
  final DateTime? birthDate;
  final double? weight;
  final String? gender;
  final String? photoUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pet({
    required this.id,
    required this.userId,
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.weight,
    this.gender,
    this.photoUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      species: map['species'],
      breed: map['breed'],
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date']) : null,
      weight: map['weight']?.toDouble(),
      gender: map['gender'],
      photoUrl: map['photo_url'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'species': species,
      'breed': breed,
      'birth_date': birthDate?.toIso8601String(),
      'weight': weight,
      'gender': gender,
      'photo_url': photoUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Pet copyWith({
    String? name,
    String? species,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? gender,
    String? photoUrl,
    String? notes,
  }) {
    return Pet(
      id: id,
      userId: userId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  String get ageText {
    if (birthDate == null) return 'Unknown age';
    
    final now = DateTime.now();
    final difference = now.difference(birthDate!);
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return months > 0 ? '$years years, $months months' : '$years years';
    } else if (months > 0) {
      return '$months months';
    } else {
      final days = difference.inDays;
      return '$days days';
    }
  }
}

class Reminder {
  final String id;
  final String userId;
  final String petId;
  final String title;
  final String? description;
  final String reminderType;
  final DateTime reminderDate;
  final bool isCompleted;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.petId,
    required this.title,
    this.description,
    required this.reminderType,
    required this.reminderDate,
    required this.isCompleted,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      userId: map['user_id'],
      petId: map['pet_id'],
      title: map['title'],
      description: map['description'],
      reminderType: map['reminder_type'],
      reminderDate: DateTime.parse(map['reminder_date']),
      isCompleted: map['is_completed'] == 1,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'title': title,
      'description': description,
      'reminder_type': reminderType,
      'reminder_date': reminderDate.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isOverdue {
    return !isCompleted && reminderDate.isBefore(DateTime.now());
  }

  bool get isToday {
    final now = DateTime.now();
    final reminderDay = DateTime(reminderDate.year, reminderDate.month, reminderDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return reminderDay.isAtSameMomentAs(today);
  }
}

class WeightRecord {
  final String id;
  final String userId;
  final String petId;
  final double weight;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeightRecord({
    required this.id,
    required this.userId,
    required this.petId,
    required this.weight,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'],
      userId: map['user_id'],
      petId: map['pet_id'],
      weight: map['weight'].toDouble(),
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'weight': weight,
      'date': date.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Expense {
  final String id;
  final String userId;
  final String petId;
  final double amount;
  final String category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.userId,
    required this.petId,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      userId: map['user_id'],
      petId: map['pet_id'],
      amount: map['amount'].toDouble(),
      category: map['category'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Budget {
  final String id;
  final String userId;
  final String petId;
  final double monthlyLimit;
  final double currentSpent;
  final String month;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.userId,
    required this.petId,
    required this.monthlyLimit,
    required this.currentSpent,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      userId: map['user_id'],
      petId: map['pet_id'],
      monthlyLimit: map['monthly_limit'].toDouble(),
      currentSpent: map['current_spent'].toDouble(),
      month: map['month'],
      year: map['year'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'monthly_limit': monthlyLimit,
      'current_spent': currentSpent,
      'month': month,
      'year': year,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get percentageUsed => currentSpent / monthlyLimit * 100;
  
  double get remainingAmount => monthlyLimit - currentSpent;
  
  bool get isOverBudget => currentSpent > monthlyLimit;
}

class Photo {
  final String id;
  final String userId;
  final String petId;
  final String filePath;
  final String? thumbnailPath;
  final String? caption;
  final DateTime createdAt;
  final DateTime updatedAt;

  Photo({
    required this.id,
    required this.userId,
    required this.petId,
    required this.filePath,
    this.thumbnailPath,
    this.caption,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      userId: map['user_id'],
      petId: map['pet_id'],
      filePath: map['file_path'],
      thumbnailPath: map['thumbnail_path'],
      caption: map['caption'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AppSettings {
  final String id;
  final String userId;
  final String key;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppSettings({
    required this.id,
    required this.userId,
    required this.key,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'],
      userId: map['user_id'],
      key: map['key'],
      value: map['value'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'key': key,
      'value': value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}