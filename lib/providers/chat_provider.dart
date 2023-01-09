import 'package:flutter/cupertino.dart';
import 'package:y/models/chat.dart';
import 'package:y/models/enums/message_type_enum.dart';
import 'package:y/models/message.dart';
import 'package:y/network/api_request_loader.dart';
import 'package:y/network/responses/chats_get_response.dart';
import 'package:y/network/responses/create_chat_response.dart';
import 'package:y/services/chat_service.dart';
import 'package:y/services/socket_service.dart';
import 'package:y/utility/constants.dart';
import 'dart:math';

import '../network/responses/chat_get_response.dart';

class ChatProvider extends ChangeNotifier {
  Map<int, Chat> _chatsMap = {};
  int? _currentChatIdScope;
  bool _didFetchChats = false;
  ApiRequestLoader chatsRequestLoader = ApiRequestLoader();
  SocketService? socketService;
  ChatService chatService = ChatService();

  void setSocketService(SocketService service) => socketService = service;

  void fetchChats({bool forceFetch = false}) async {
    if (_didFetchChats && !forceFetch) {
      return;
    }
    chatsRequestLoader.setLoading(true);
    _didFetchChats = true;
    ChatsGetResponse response = await chatService.getAll();
    if (response.error != null) {
      return;
    }
    for (var chat in response.chats) {
      {
      _chatsMap[chat.id!] = chat;
    }
    }
    chatsRequestLoader.setLoading(false);
    notifyListeners();
  }

  Map<int, Chat> getChats() => _chatsMap;

  bool didFetchChats() => _didFetchChats;

  void setChatScope(int chatId) {
    _currentChatIdScope = chatId;

  }

  void setNewChatScope(Chat chat) {
    int newChatInt = Constants.newChatIdMin + Random().nextInt(Constants.newChatIdMax - Constants.newChatIdMin);
    _chatsMap[newChatInt] = chat;
    _currentChatIdScope = newChatInt;
    notifyListeners();
  }

  int? get currentChatIdScope => _currentChatIdScope;

  void receiveNewMessage(dynamic data) {
    data['created_at'] = DateTime.now().toString();
    Message newMessage = Message.fromJson(data);
    int chatId = data['chat_id'];
    if (_chatsMap[chatId] == null) {
      return receiveMessageFromNewChat(newMessage, chatId);
    }
    _chatsMap[chatId]!.messages.add(newMessage);
    notifyListeners();
  }

  void sendNewMessage(String message, int currentUserId) async {
    bool isNewChat = _currentChatIdScope! > Constants.newChatIdMin;
    int? recipientUserId;
    Message newMessage = Message(
      message: message,
      type: MessageType.text,
      senderId: currentUserId,
      sentOn: DateTime.now(),
    );
    _chatsMap[_currentChatIdScope]!.messages.add(newMessage);
    notifyListeners();
    if (isNewChat) {
      recipientUserId = _chatsMap[_currentChatIdScope]!.recipientId;
      CreateChatResponse chatResponse =
          await chatService.createNewChat(_chatsMap[_currentChatIdScope]!.recipientId!);
      if (chatResponse.error != null) {
        return;
      }
      int randomlyGeneratedChatId = _currentChatIdScope!;
      _currentChatIdScope = chatResponse.chat!.id;
      _chatsMap[_currentChatIdScope!] = chatResponse.chat!;
      _chatsMap[_currentChatIdScope!]!.messages.add(newMessage);
      _chatsMap.remove(randomlyGeneratedChatId);
      notifyListeners();
    }
    socketService!.emitToChat(
      chatId: _currentChatIdScope!,
      message: message,
      messageType: MessageType.text,
      isNewChat: isNewChat,
      recipientUserId: recipientUserId,
    );
  }

  void receiveMessageFromNewChat(Message newMessage, int chatId) async {
    ChatGetResponse response = await chatService.fetchChat(chatId);
    if (response.error != null) {
      return;
    }
    Chat newChat = response.chat!;
    _chatsMap[newChat.id!] = newChat;
    notifyListeners();
  }

  Chat? getCurrentChatScope() => _chatsMap[_currentChatIdScope];
}
