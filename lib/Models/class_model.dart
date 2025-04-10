class ClassModel {
  String? id; // Optional ID field, can be null
  String? name;
  String? email;
  String? username;
  String? password;
  String? incharge;
  String? type;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  ClassModel({
    this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.password,
     this.incharge,
    required this.type,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a ClassModel from JSON
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      incharge: json['incharge'] as String?,
      type: json['type'] as String?,
      isActive: json['is_active'] as bool? ?? true, // Default to true if null
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  // Method to convert ClassModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'incharge': incharge,
      'type': type,
      'is_active': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
