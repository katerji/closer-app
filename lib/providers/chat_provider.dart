import 'package:flutter/cupertino.dart';
import 'package:y/models/chat.dart';
import 'package:y/models/enums/message_type_enum.dart';
import 'package:y/models/message.dart';
import 'package:y/network/api_request_loader.dart';
import 'package:y/network/responses/chats_get_response.dart';
import 'package:y/services/chat_service.dart';
import 'package:y/services/socket_service.dart';

class ChatProvider extends ChangeNotifier {
  List<Chat> _chats = [];
  Chat? _currentChatScope;
  bool _didFetchChats = false;
  ApiRequestLoader chatsRequestLoader = ApiRequestLoader();
  SocketService? socketService;
  void setSocketService(SocketService service) => socketService = service;
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
    print("setting" );
    _currentChatScope = chat;
    notifyListeners();
  }

  Chat? get currentChatScope => _currentChatScope;

  void receiveNewMessage(dynamic data) {
    data['created_at'] = DateTime.now().toString();
    Message newMessage = Message.fromJson(data);
    _currentChatScope!.messages.add(newMessage);
    notifyListeners();
  }
  void sendNewMessage(String message, int currentUserId) {
    Message newMessage = Message(message: message, type: MessageType.text, senderId: currentUserId, sentOn: DateTime.now());
    _currentChatScope!.messages.add(newMessage);
    notifyListeners();
    socketService!.emitToChat(chatId: _currentChatScope!.id, message: message, messageType: MessageType.text);
  }
}
