import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:y/models/enums/message_type_enum.dart';
import 'package:y/network/sockets/socket_events.dart';
import 'package:y/providers/chat_provider.dart';

import '../network/request.dart';
import '../network/sockets/socket_event_payloads/new_chat_socket_payload.dart';
import '../network/sockets/socket_event_payloads/new_message_socket_payload.dart';

class SocketService {
  static final SocketService _messageService = SocketService._internal();
  static const String _socketServerUrl = 'http://10.0.2.2:82/socket';
  bool _didConnect = false;

  factory SocketService() {
    return _messageService;
  }

  SocketService._internal();

  IO.Socket? socket;

  void connectToSocketServer(ChatProvider chatProvider) {
    if (_didConnect) {
      return;
    }
    _didConnect = true;
    Map<String, String> auth = {"token": Request.jwtToken ?? ""};
    socket = IO.io(
      _socketServerUrl,
      OptionBuilder().setAuth(auth).setTransports(['websocket']).build(),
    );
    socket!.onConnect((_) {
      print('connect');
    });
    socket!.on(SocketEvents.socketEventNewChat, (data) {
      if (data['chat_id'] != null &&
          data['chat_name'] != null &&
          data['message'] != null &&
          data['sender_user_id'] != null &&
          data['message_type'] != null) {
        print("received");
        print(data);
        chatProvider.receiveMessageFromNewChat(
          NewChatSocketPayload.fromJson(data),
        );
      }
    });
    socket!.on(SocketEvents.socketEventNewMessage, (data) {
      if (data['chat_id'] != null &&
          data['message'] != null &&
          data['message_type'] != null) {
        chatProvider.receiveNewMessage(NewMessageSocketPayload.fromJson(data),);
      }
    },);
    socket!.onDisconnect((_) => print('disconnect'));
  }

  void emitToChat({
    required int chatId,
    required String message,
    required MessageType messageType,
  }) {
    Map<String, dynamic> socketMessage = {
      "message": message,
      "chat_id": chatId,
      "message_type": messageType.id,
    };
    socket!.emit(SocketEvents.socketEventNewMessage, socketMessage);
  }
  void emitToNewChat({
    required int chatId,
    required String message,
    required MessageType messageType,
    required int recipientUserId,
    required String chatName,
  }) {
    Map<String, dynamic> socketMessage = {
      "message": message,
      "chat_id": chatId,
      "message_type": messageType.id,
      "recipient_user_id": recipientUserId,
      "chat_name": chatName,
    };
    print(socketMessage);
    print(SocketEvents.socketEventNewChat);
    socket!.emit(SocketEvents.socketEventNewChat, socketMessage);
  }
}
