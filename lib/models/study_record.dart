class StudyRecord {
  final int herbId;
  DateTime lastStudied;
  int reviewCount;
  bool mastered;

  StudyRecord({
    required this.herbId,
    required this.lastStudied,
    this.reviewCount = 0,
    this.mastered = false,
  });

  factory StudyRecord.fromJson(Map<String, dynamic> json) => StudyRecord(
    herbId: json['herbId'],
    lastStudied: DateTime.parse(json['lastStudied']),
    reviewCount: json['reviewCount'] ?? 0,
    mastered: json['mastered'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'herbId': herbId,
    'lastStudied': lastStudied.toIso8601String(),
    'reviewCount': reviewCount,
    'mastered': mastered,
  };
}
