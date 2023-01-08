import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/chat_provider.dart';

import '../widgets/chat_widget.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<ChatProvider>().currentChatScope!.name),
      ),
      body: const ChatWidget(),
    );
  }
}
