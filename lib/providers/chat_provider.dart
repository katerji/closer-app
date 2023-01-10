import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:y/models/chat.dart';
import 'package:y/models/enums/message_type_enum.dart';
import 'package:y/models/message.dart';
import 'package:y/network/api_request_loader.dart';
import 'package:y/network/responses/chats_get_response.dart';
import 'package:y/network/responses/chat_create_response.dart';
import 'package:y/services/chat_service.dart';
import 'package:y/services/socket_service.dart';
import 'package:y/utility/constants.dart';
import 'dart:math';

import '../models/user.dart';
import '../network/responses/chat_get_response.dart';
import '../network/sockets/socket_event_payloads/new_chat_socket_payload.dart';
import '../network/sockets/socket_event_payloads/new_message_socket_payload.dart';

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
    // chatsRequestLoader.setLoading(true);
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
    FlutterSecureStorage storage = const FlutterSecureStorage();
    List<Map<String,dynamic>> chatsMap = response.chats.map((e) => e.toMap()).toList();
    storage.write(
      key: Constants.secureStorageChatsKey,
      value: jsonEncode(chatsMap),
    );
    // chatsRequestLoader.setLoading(false);
    notifyListeners();
  }

  Map<int, Chat> getChats() => _chatsMap;

  bool didFetchChats() => _didFetchChats;

  void setChatScope(int chatId) {
    _currentChatIdScope = chatId;
  }

  void setNewChatScope(Chat chat) {
    int newChatInt = Constants.newChatIdMin +
        Random().nextInt(Constants.newChatIdMax - Constants.newChatIdMin);
    _chatsMap[newChatInt] = chat;
    _currentChatIdScope = newChatInt;
    notifyListeners();
  }

  int? get currentChatIdScope => _currentChatIdScope;

  void receiveNewMessage(NewMessageSocketPayload payload) {
    Message newMessage = Message(
      message: payload.message,
      type: payload.messageType,
      senderId: payload.senderId,
      sentOn: DateTime.now(),
    );
    _chatsMap[payload.chatId]!.messages.add(newMessage);
    notifyListeners();
  }

  void sendNewMessageFromNewChat(String message, User currentUser) async {
    Message newMessage = Message(
      message: message,
      type: MessageType.text,
      senderId: currentUser.userId,
      sentOn: DateTime.now(),
    );
    _chatsMap[_currentChatIdScope]!.messages.add(newMessage);
    notifyListeners();
    int recipientUserId = _chatsMap[_currentChatIdScope]!.recipientId!;
    ChatCreateResponse chatResponse = await chatService
        .createNewChat(_chatsMap[_currentChatIdScope]!.recipientId!);
    if (chatResponse.error != null) {
      return;
    }
    int randomlyGeneratedChatId = _currentChatIdScope!;
    _currentChatIdScope = chatResponse.chat!.id;
    _chatsMap[_currentChatIdScope!] = chatResponse.chat!;
    _chatsMap[_currentChatIdScope!]!.messages.add(newMessage);
    _chatsMap.remove(randomlyGeneratedChatId);
    notifyListeners();
    socketService!.emitToNewChat(
      chatId: _currentChatIdScope!,
      message: message,
      messageType: MessageType.text,
      recipientUserId: recipientUserId,
      chatName: currentUser.name,
    );
  }

  void sendNewMessage(String message, int currentUserId) async {
    Message newMessage = Message(
      message: message,
      type: MessageType.text,
      senderId: currentUserId,
      sentOn: DateTime.now(),
    );
    _chatsMap[_currentChatIdScope]!.messages.add(newMessage);
    notifyListeners();
    socketService!.emitToChat(
      chatId: _currentChatIdScope!,
      message: message,
      messageType: MessageType.text,
    );
  }

  void receiveMessageFromNewChat(NewChatSocketPayload payload) async {
    Message message = Message(
      message: payload.message,
      type: payload.messageType,
      senderId: payload.senderId,
      sentOn: DateTime.now(),
    );
    Chat chat = Chat(
      messages: [message],
      name: payload.chatName,
      id: payload.chatId,
      createdOn: DateTime.now(),
      updatedOn: DateTime.now(),
    );
    print(chat.messages);
    _chatsMap[chat.id!] = chat;
    notifyListeners();
  }

  bool _didFetchFromLocalStorage = false;
  Future<void> setChatsFromLocalStorage() async {
    if(_didFetchFromLocalStorage){
      return;
    }
    FlutterSecureStorage storage = FlutterSecureStorage();
    String? encodedChats = await storage.read(
        key: Constants.secureStorageChatsKey);
    if (encodedChats == null) {
      return;
    }
    List<dynamic> chatsList = jsonDecode(encodedChats);
    for (var chatMap in chatsList) {
      Chat chat = Chat.fromJson(chatMap);
      _chatsMap[chat.id!] = chat;
    }
    _didFetchFromLocalStorage = true;
    notifyListeners();
  }

  bool get didFetchFromLocalStorage => _didFetchFromLocalStorage;
  Chat? getCurrentChatScope() => _chatsMap[_currentChatIdScope];
  int? get currentChatScopeId => _currentChatIdScope;
}
