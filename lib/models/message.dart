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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'message_type': type == MessageType.text ? 1 : 2,
      'created_at': sentOn.toString(),
      'sender_user_id': senderId
    };
  }

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
