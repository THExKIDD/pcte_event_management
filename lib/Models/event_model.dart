class EventModel {
  String? id;
  String? name;
  String? type;
  String? partType;
  String? description;
  List<String>? rules;
  int? maxStudents;
  int? minStudents;
  String? location;
  String? convenor;
  List<int>? points; // Keeping points as a list of integers
  bool? isActive;

  EventModel({
    this.id,
    required this.name,
    required this.type,
    required this.partType,
    required this.description,
    required this.rules,
    required this.maxStudents,
    required this.minStudents,
    required this.location,
    this.convenor,
    this.points,
    this.isActive = true, // Default to true if not provided
  });

  // Factory method to create an EventModel from JSON
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      partType: json['part_type'],
      description: json['description'],
      rules: List<String>.from(json['rules']),
      maxStudents: json['maxStudents'],
      minStudents: json['minStudents'],
      location: json['location'],
      convenor: json['convenor'],
      points: json['points'] != null ? List<int>.from(json['points']) : null,
      isActive: json['is_active'] ?? true, // Default to true if not provided
    );
  }

  // Method to convert EventModel to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['_id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['part_type'] = partType;
    data['description'] = description;
    data['rules'] = rules;
    data['maxStudents'] = maxStudents;
    data['minStudents'] = minStudents;
    data['location'] = location;
    data['convenor'] = convenor;
    data['points'] = points;
    data['is_active'] = isActive;
    return data;
  }
}