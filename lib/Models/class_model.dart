class ClassModel {
  String? name;
  String? incharge;
  String? type;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  ClassModel({
    required this.name,
    required this.incharge,
    required this.type,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a ClassModel from JSON
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      name: json['name'] as String?,
      incharge: json['incharge'] as String?,
      type: json['type'] as String?,
      isActive: json['is_active'] as bool? ?? true, // Default to true if null
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  // Method to convert ClassModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'incharge': incharge,
      'type': type,
      'is_active': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
