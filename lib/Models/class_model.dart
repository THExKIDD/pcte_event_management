
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
      name: json['name'],
      incharge: json['incharge'],
      type: json['type'],
      isActive: json['is_active'] ?? true, // Default to true if not provided
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }



  // Method to convert ClassModel to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['incharge'] = incharge;
    data['type'] = type;
    data['is_active'] = isActive;
    data['createdAt'] = createdAt!.toIso8601String();
    data['updatedAt'] = updatedAt!.toIso8601String();
    return data;


  }

}