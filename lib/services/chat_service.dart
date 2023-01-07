import '../models/chat.dart';
import '../network/endpoints.dart';
import '../network/request.dart';

class ChatService {
  static final ChatService _chatService = ChatService._internal();

  factory ChatService() {
    return _chatService;
  }

  ChatService._internal();
  Future<List<Chat>> getAll() async {
    dynamic chats = await Request.get(endpoint: Endpoints.getChats);
    if (chats is RequestException) {
      return [];
    } else if (chats.length == 0) {
      return [];
    } else {
      return chats.map((chatJson) => Chat.fromJson(chatJson));
    }
  }
}