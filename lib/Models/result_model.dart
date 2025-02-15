class ResultModel {
  String? id;
  String eventId;
  List<ResultEntry> result;
  bool isActive;

  ResultModel({
    this.id,
    required this.eventId,
    required this.result,
    this.isActive = true,
  });

  // Factory method to create a ResultModel from JSON
  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json['_id'],
      eventId: json['eventId'],
      result: (json['result'] as List)
          .map((e) => ResultEntry.fromJson(e))
          .toList(),
      isActive: json['is_active'] ?? true,
    );
  }

  // Method to convert ResultModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'eventId': eventId,
      'result': result.map((e) => e.toJson()).toList(),
      'is_active': isActive,
    };
  }
}

class ResultEntry {
  String classId;
  String studentName;
  int position;

  ResultEntry({
    required this.classId,
    required this.studentName,
    required this.position,
  });

  // Factory method to create a ResultEntry from JSON
  factory ResultEntry.fromJson(Map<String, dynamic> json) {
    return ResultEntry(
      classId: json['classId'],
      studentName: json['studentName'],
      position: json['position'],
    );
  }

  // Method to convert ResultEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'studentName': studentName,
      'position': position,
    };
  }
}
