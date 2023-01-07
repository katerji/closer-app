import 'package:flutter/cupertino.dart';
import 'package:y/models/chat.dart';
import 'package:y/network/api_request_loader.dart';
import 'package:y/network/responses/chats_get_response.dart';
import 'package:y/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  List<Chat>? _chats;
  bool _didFetchChats = false;
  ApiRequestLoader chatsRequestLoader = ApiRequestLoader();


  void fetchChats() async {
    chatsRequestLoader.setLoading(true);
    ChatService chatService = ChatService();
    ChatsGetResponse response = await chatService.getAll();
    _didFetchChats = true;
    if (response.error != null) {
      return;
    }
    _chats = response.chats;
    print(_chats);
    chatsRequestLoader.setLoading(false);
    notifyListeners();
  }

  List<Chat>? getChats() => _chats;

  bool didFetchChats() => _didFetchChats;
}
