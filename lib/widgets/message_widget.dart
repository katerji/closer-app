import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/auth_provider.dart';

import '../models/message.dart';

class MessageWidget extends StatelessWidget {
  final Message message;

  const MessageWidget({
    required this.message,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMessageSentByUser =
        message.senderId == context.read<AuthProvider>().loggedInUserId;
    return Container(
      width: 10,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: isMessageSentByUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(message.message),
          Text(
            message.sentOn.toLocal().toString(),
          ),
        ],
      ),
    );
  }
}
