import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  final String? id;
  final String body;
  bool isCompleted;

  Task({
    required this.id,
    required this.body,
    required this.isCompleted,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

// @JsonKey(name: '_id') final String? id;
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:json_annotation/json_annotation.dart';

// part 'task.freezed.dart';
// part 'task.g.dart';

// @freezed
// abstract class Task with _$Task {
//   const factory Task({
//     @JsonKey(name: '_id') required String id,
//     required String body,
//     required bool isCompleted,
//     required bool isDeleted,
//   }) = _Task;

//   factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
// }
