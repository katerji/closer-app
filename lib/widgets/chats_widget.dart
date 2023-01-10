import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/auth_provider.dart';
import 'package:y/providers/chat_provider.dart';
import 'package:y/services/socket_service.dart';
import 'package:y/utility/constants.dart';

import '../models/chat.dart';
import 'chat_row_widget.dart';

class ChatsWidget extends StatefulWidget {
  const ChatsWidget({Key? key}) : super(key: key);

  @override
  State<ChatsWidget> createState() => _ChatsWidgetState();
}

class _ChatsWidgetState extends State<ChatsWidget> {
  ChatProvider? _chatProvider;

  @override
  void didChangeDependencies() {
    _chatProvider ??= context.watch<ChatProvider>();
    _chatProvider!.fetchChats();
    if (context.watch<AuthProvider>().isLoggedIn()) {
      SocketService socketService = SocketService();
      socketService.connectToSocketServer(_chatProvider!);
      _chatProvider!.setSocketService(socketService);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: _chatProvider == null
            ? [const SizedBox.shrink()]
            : _chatProvider!.getChats().entries.map(
                (entry) {
                  if (entry.key > Constants.newChatIdMin) {
                    return SizedBox.shrink();
                  }
                  return ChatRowWidget(
                    chat: entry.value,
                  );
                },
              ).toList());
  }
}
