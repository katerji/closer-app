import 'package:y/models/chat.dart';

class ChatCreateResponse {
  final Chat? chat;
  final String? error;

  ChatCreateResponse({
    this.chat,
    this.error,
  });
}
