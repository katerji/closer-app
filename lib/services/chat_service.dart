import 'package:y/network/responses/chats_get_response.dart';

import '../models/chat.dart';
import '../network/endpoints.dart';
import '../network/request.dart';

class ChatService {
  static final ChatService _chatService = ChatService._internal();

  factory ChatService() {
    return _chatService;
  }

  ChatService._internal();

  Future<ChatsGetResponse> getAll() async {
    dynamic response = await Request.get(endpoint: Endpoints.getChats);
    if (response is RequestException) {
      return ChatsGetResponse(chats: [], error: response.errorMessage);
    }
    return ChatsGetResponse(chats: response.map<Chat>((chat) => Chat.fromJson(chat)).toList());
  }
}
