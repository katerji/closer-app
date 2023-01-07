import 'package:flutter/cupertino.dart';
import 'package:y/models/chat.dart';
import 'package:y/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  List<Chat>? _chats;
  bool _didFetchChats = false;

  void fetchChats() async {
    ChatService chatService = ChatService();
    _chats = await chatService.getAll();
    _didFetchChats = true;
    print(_chats);
    notifyListeners();
  }

  List<Chat>? getChats() => _chats;

  bool didFetchChats() => _didFetchChats;
}
