import '../../models/chat.dart';

class ChatGetResponse {
  Chat? chat;
  String? error;
  ChatGetResponse({this.chat, this.error});
}