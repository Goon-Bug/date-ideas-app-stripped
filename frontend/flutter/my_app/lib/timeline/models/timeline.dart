import 'dart:convert';

class TimelineItem {
  final String id;
  final String dateId;
  final String date;
  final String imagePath;
  final String userId;
  final String? description;
  final String dateTitle;

  TimelineItem({
    required this.id,
    required this.dateId,
    required this.date,
    required this.imagePath,
    required this.userId,
    required this.dateTitle,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateId': dateId,
        'date': date,
        'dateTitle': dateTitle,
        'imagePath': imagePath,
        'description': description,
        'userId': userId,
      };

  factory TimelineItem.fromJson(Map<String, dynamic> json) => TimelineItem(
        id: json['id'],
        dateId: json['dateId'],
        date: json['date'],
        dateTitle: json['dateTitle'],
        imagePath: json['imagePath'],
        description: json['description'],
        userId: json['userId'],
      );

  static List<TimelineItem> decodeList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => TimelineItem.fromJson(item)).toList();
  }

  static String encodeList(List<TimelineItem> items) {
    final List<Map<String, dynamic>> jsonList =
        items.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }

  TimelineItem copyWith({
    String? id,
    String? dateId,
    String? date,
    String? imagePath,
    String? userId,
    String? description,
    String? dateTitle,
  }) {
    return TimelineItem(
      id: id ?? this.id,
      dateId: dateId ?? this.dateId,
      date: date ?? this.date,
      dateTitle: dateTitle ?? this.dateTitle,
      imagePath: imagePath ?? this.imagePath,
      userId: userId ?? this.userId,
      description: description ?? this.description,
    );
  }
}
