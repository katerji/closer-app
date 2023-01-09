import 'package:provider/provider.dart';
import 'package:y/network/responses/chat_get_response.dart';
import 'package:y/network/responses/chats_get_response.dart';

import '../models/chat.dart';
import '../network/endpoints.dart';
import '../network/request.dart';
import '../network/responses/create_chat_response.dart';

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
    return ChatsGetResponse(
        chats: response.map<Chat>((chat) => Chat.fromJson(chat)).toList());
  }

  Future<CreateChatResponse> createNewChat(int recipientId) async {
    Map<String, int> body = {'recipient_id': recipientId};
    dynamic response =
        await Request.post(endpoint: Endpoints.createChat, body: body);
    if (response is RequestException) {
      return CreateChatResponse(error: response.errorMessage);
    }
    return CreateChatResponse(
      chat: Chat.fromJson(response['chat']),
    );
  }

  Future<ChatGetResponse> fetchChat(int chatId) async {
    dynamic response = await Request.get(endpoint: Endpoints.getFetchChatEndpoint(chatId));
    if (response is RequestException) {
      return ChatGetResponse(error: response.errorMessage);
    }
    return ChatGetResponse(chat: Chat.fromJson(response['chat']));

  }
}
