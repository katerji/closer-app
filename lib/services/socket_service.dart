import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:y/models/enums/message_type_enum.dart';
import 'package:y/providers/chat_provider.dart';

import '../network/request.dart';

class SocketService {
  static final SocketService _messageService = SocketService._internal();
  static const String _socketServerUrl = 'http://10.0.2.2:82/socket';
  bool _didConnect = false;
  factory SocketService() {
    return _messageService;
  }

  SocketService._internal();

  IO.Socket? socket;
  static const String _messageEvent = 'chat-message';
  void connectToSocketServer(ChatProvider chatProvider) {
    if (_didConnect){
      return;
    }
    _didConnect = true;
    Map<String, String> auth = {"token": Request.jwtToken ?? ""};
    socket = IO.io(
      _socketServerUrl,
      OptionBuilder().setAuth(auth).setTransports(['websocket']).build(),
    );
    // socket!.connect();
    socket!.onConnect((_) {
      print('connect');
      // socket!.emit('msg', 'test');
    });
    socket!.on(_messageEvent, (data) {
      if (data['chat_id']  != null && data['message'] != null && data['message_type'] != null){
        chatProvider.receiveNewMessage(data);
      }
    });
    socket!.onDisconnect((_) => print('disconnect'));
  }
  void emitToChat({
    required int chatId,
    required String message,
    required MessageType messageType,
  }) {
    socket!.emit(_messageEvent, {
      "message": message,
      "chat_id": chatId,
      "messageType": messageType.id,
    });
  }
}
