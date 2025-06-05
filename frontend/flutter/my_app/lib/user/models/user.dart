import 'package:date_spark_app/timeline/models/timeline.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String iconImage;
  final List<TimelineItem> timelineEntries;
  final int tokenCount;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.iconImage = 'assets/profile_icons/icon_1.png',
    this.timelineEntries = const [],
    this.tokenCount = 0,
  });

  @override
  List<Object> get props =>
      [id, username, email, iconImage, timelineEntries, tokenCount];

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, iconImage: $iconImage, timelineEntries: $timelineEntries, tokens: $tokenCount)';
  }

  static const empty = User(
    id: -1,
    username: '-',
    iconImage: 'assets/profile_icons/icon_1.png',
    email: '_',
    tokenCount: 0,
  );

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? iconImage,
    List<TimelineItem>? timelineEntries,
    int? tokenCount,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      iconImage: iconImage ?? this.iconImage,
      timelineEntries: timelineEntries ?? this.timelineEntries,
      tokenCount: tokenCount ?? this.tokenCount,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      iconImage:
          json['iconImage'] as String? ?? 'assets/profile_icons/icon_1.png',
      timelineEntries: (json['timelineEntries'] as List<dynamic>?)
              ?.map((entry) => TimelineItem.fromJson(entry))
              .toList() ??
          [],
      tokenCount: json['tokenCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'iconImage': iconImage,
      'timelineEntries':
          timelineEntries.map((entry) => entry.toJson()).toList(),
      'tokenCount': tokenCount,
    };
  }
}
