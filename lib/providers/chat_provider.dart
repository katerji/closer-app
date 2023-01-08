import 'package:flutter/cupertino.dart';
import 'package:y/models/chat.dart';
import 'package:y/network/api_request_loader.dart';
import 'package:y/network/responses/chats_get_response.dart';
import 'package:y/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  List<Chat> _chats = [];
  Chat? _currentChatScope;
  bool _didFetchChats = false;
  ApiRequestLoader chatsRequestLoader = ApiRequestLoader();


  void fetchChats({bool forceFetch = false}) async {
    if (_didFetchChats && !forceFetch) {
      return;
    }
    chatsRequestLoader.setLoading(true);
    _didFetchChats = true;
    ChatService chatService = ChatService();
    ChatsGetResponse response = await chatService.getAll();
    if (response.error != null) {
      return;
    }
    _chats = response.chats;
    chatsRequestLoader.setLoading(false);
    notifyListeners();
  }

  List<Chat> getChats() => _chats;

  bool didFetchChats() => _didFetchChats;

  void setChatScope(Chat chat) {
    _currentChatScope = chat;
    notifyListeners();
  }

  Chat? get currentChatScope => _currentChatScope;
}
