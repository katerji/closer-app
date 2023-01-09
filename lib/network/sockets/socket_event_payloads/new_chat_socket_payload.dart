import 'package:y/models/enums/message_type_enum.dart';

class NewChatSocketPayload {
  final int chatId;
  final String chatName;
  final String message;
  final MessageType messageType;
  final int senderId;

  const NewChatSocketPayload({
    required this.chatId,
    required this.chatName,
    required this.message,
    required this.messageType,
    required this.senderId,
  });

  factory NewChatSocketPayload.fromJson(dynamic json) {
    return NewChatSocketPayload(
      chatId: json['chat_id'],
      chatName: json['chat_name'],
      message: json['message'],
      senderId: json['sender_user_id'],
      messageType:
          json['message_type'] == 1 ? MessageType.text : MessageType.image,
    );
  }
}