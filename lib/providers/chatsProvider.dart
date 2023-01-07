import 'package:flutter/cupertino.dart';
import 'package:y/models/chat.dart';
import 'package:y/utility/endpoints.dart';
import 'package:y/utility/request.dart';

class ChatsProvider extends ChangeNotifier {
  List<Chat>? _chats;

  void fetchChats() async {
    dynamic response = await Request.getFromApi(Endpoints.getChats);
    if (response is RequestException) {
    } else if (response.body.length == 0) {
    } else {
      print(response);
      _chats = response.map((chatJson) => Chat.fromJson(chatJson));
    }
    print(_chats);
    notifyListeners();
  }

  List<Chat>? getChats() => _chats;
}
