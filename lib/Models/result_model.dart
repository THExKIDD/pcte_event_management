class ResultModel {
  final String? id;
  final int? year;
  final String? eventId;
  final List<String> classIds;

  ResultModel({
    this.id,
    this.year,
    this.eventId,
    required this.classIds,
  });

  Map<String, dynamic> toJson() => {
    'year': year,
    'eventId': eventId,
    'classIds': classIds,
  };
}


