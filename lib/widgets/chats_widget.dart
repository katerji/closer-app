import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/chat_provider.dart';

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
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _chatProvider == null
          ? [const SizedBox.shrink()]
          : _chatProvider!
              .getChats()
              .map(
                (Chat chat) => ChatRowWidget(
                  chat: chat,
                ),
              )
              .toList(),
    );
  }
}
