import 'package:y/models/chat.dart';

class CreateChatResponse {
  final Chat? chat;
  final String? error;
  CreateChatResponse({this.chat, this.error});
}