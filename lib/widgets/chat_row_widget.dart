import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/auth_provider.dart';
import 'package:y/providers/chat_provider.dart';
import 'package:y/utility/routes.dart';

import '../models/chat.dart';

class ChatRowWidget extends StatelessWidget {
  final Chat chat;

  const ChatRowWidget({required this.chat, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<ChatProvider>().setChatScope(chat);
        context.push(Routes.chat.pageName);
      },
      child: Row(
        children: [
          Column(
            children: [
              Text(chat.name),
              Row(
                children: [
                  chat.isLatestMessageSentByUser(
                          context.read<AuthProvider>().loggedInUserId)
                      ? const Text("You: ")
                      : const SizedBox.shrink(),
                  Text(
                    chat.getLatestMessage(),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(chat.updatedOn.toString())
        ],
      ),
    );
  }
}
