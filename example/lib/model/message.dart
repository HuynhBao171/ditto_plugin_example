import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String content;
  final String createdAt;
  final String senderName;

  Message({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.senderName,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
