import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/auth_provider.dart';
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
  TextEditingController _messageController = TextEditingController();

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
          height: MediaQuery.of(context).size.height * (8 / 10),
          child: ListView(
            children: chatProvider!.getCurrentChatScope()!.messages
                .map(
                  (Message message) => MessageWidget(message: message),
                )
                .toList(),
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * (8 / 10),
              child: TextField(
                controller: _messageController,
              ),
            ),
            ElevatedButton(
              onPressed: _sendNewMessage,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.blue,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  void _sendNewMessage() {
    chatProvider!.sendNewMessage(
        _messageController.text, context.read<AuthProvider>().loggedInUserId, );
    _messageController.text = "";
  }
}
