import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/chat_provider.dart';
import '../models/message.dart';
import 'message_widget.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  ChatProvider? chatProvider;

  @override
  void didChangeDependencies() {
    chatProvider ??= context.watch<ChatProvider>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * (8/10),
          child: ListView(
            children: chatProvider!.currentChatScope!.messages
                .map(
                  (Message message) => MessageWidget(message: message),
                )
                .toList(),
          ),
        ),
        TextField(),
      ],
    );
  }
}
