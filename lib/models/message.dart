import 'package:y/models/enums/message_type_enum.dart';

class Message {
  final int? id;
  final String message;
  final MessageType type;
  final int senderId;
  final DateTime sentOn;
  Message({
    this.id,
    required this.message,
    required this.type,
    required this.senderId,
    required this.sentOn,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      message: json['message'],
      type: json['message_type'] == 1 ? MessageType.text : MessageType.image,
      senderId: json['sender_user_id'],
      sentOn: DateTime.parse(json['created_at'],),
    );
  }
}
