import 'package:flutter/material.dart';

import '../models/chat.dart';

class ChatRowWidget extends StatelessWidget {
  final Chat chat;

  const ChatRowWidget({required this.chat, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
