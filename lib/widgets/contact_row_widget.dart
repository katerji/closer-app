import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:y/models/chat.dart';
import 'package:y/providers/chat_provider.dart';
import 'package:y/utility/routes.dart';

import '../models/user.dart';

class ContactRowWidget extends StatelessWidget {
  final User contact;

  const ContactRowWidget({
    required this.contact,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Chat newChat =
            Chat(messages: [], name: contact.name, recipientId: contact.userId,);
        context.read<ChatProvider>().setNewChatScope(newChat);
        context.push(Routes.chat.pageName);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(contact.name), Text(contact.phoneNumber)],
      ),
    );
  }
}
