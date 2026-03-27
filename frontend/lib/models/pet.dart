/// Pet model matching API contract
class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String type; // dog, cat, bird, rabbit, hamster, fish, other
  final int? age; // optional
  final String? breed; // optional
  final String? photoUrl;
  final String? birthDate; // optional, ISO 8601 date
  final double? weight; // optional, in kg
  final String? notes; // optional
  final String createdAt;
  final String? updatedAt;

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    this.age,
    this.breed,
    this.photoUrl,
    this.birthDate,
    this.weight,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      age: json['age'] as int?,
      breed: json['breed'] as String?,
      photoUrl: json['photoUrl'] as String?,
      birthDate: json['birthDate'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'type': type,
      if (age != null) 'age': age,
      if (breed != null) 'breed': breed,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (birthDate != null) 'birthDate': birthDate,
      if (weight != null) 'weight': weight,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  Pet copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? type,
    int? age,
    String? breed,
    String? photoUrl,
    String? birthDate,
    double? weight,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Valid pet types
  static const List<String> validTypes = ['dog', 'cat', 'bird', 'rabbit', 'hamster', 'fish', 'other'];
}
