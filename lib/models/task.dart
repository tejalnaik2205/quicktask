import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Task {
  final String objectId;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;

  Task({
    required this.objectId,
    required this.title,
    required this.dueDate,
    required this.isCompleted,
  });

  factory Task.fromParseObject(ParseObject object) {
    return Task(
      objectId: object.objectId ?? '',
      title: object.get<String>('title') ?? '',
      dueDate: object.get<DateTime>('dueDate') ?? DateTime.now(),
      isCompleted: object.get<bool>('isCompleted') ?? false,
    );
  }
}
