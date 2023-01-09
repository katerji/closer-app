import 'package:y/models/enums/message_type_enum.dart';

class NewMessageSocketPayload {
  final int chatId;
  final int senderId;
  final String message;
  final MessageType messageType;

  const NewMessageSocketPayload({
    required this.chatId,
    required this.senderId,
    required this.messageType,
    required this.message,
  });

  factory NewMessageSocketPayload.fromJson(json) {
    return NewMessageSocketPayload(
      chatId: json['chat_id'],
      senderId: json['sender_user_id'],
      messageType:
          json['message_type'] == 1 ? MessageType.text : MessageType.image,
      message: json['message'],
    );
  }
}