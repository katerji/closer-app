import '../../models/chat.dart';

class ChatsGetResponse {
  final List<Chat> chats;
  final String? error;
  ChatsGetResponse({required this.chats, this.error});
}