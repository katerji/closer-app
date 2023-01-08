import 'package:y/services/socket_service.dart';

import '../models/chat.dart';
import '../models/message.dart';

class MessageService {
  static final MessageService _messageService = MessageService._internal();

  factory MessageService() {
    return _messageService;
  }

  MessageService._internal();

  SocketService socketService = SocketService();

  void sendMessage(Chat chat, Message message) {
    socketService.emitToChat(
      chatId: chat.id,
      message: message.message,
      messageType: message.type,
    );
  }
}
