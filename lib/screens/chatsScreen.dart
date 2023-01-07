import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/authProvider.dart';
import 'package:y/providers/chatsProvider.dart';
import 'package:y/utility/routes.dart';

import '../models/chat.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  ChatsScreenState createState() {
    return ChatsScreenState();
  }
}

class ChatsScreenState extends State<ChatsScreen> {
  late final ChatsProvider chatsProvider;

  @override
  void didChangeDependencies() {
    chatsProvider = context.watch<ChatsProvider>();
    chatsProvider.fetchChats();
    super.didChangeDependencies();
  }

  void _logout() {
    context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    // context.read<ChatsProvider>().fetchChats();
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: <Widget>[
          TextButton(
            child: Text("logout"),
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.add),
                Text('Add chat'),
              ],
            ),
            getChats(),
          ],
        ),
      ),
    );
  }

  Widget getChats() {
    List<Chat>? chats = chatsProvider.getChats();
    if (chats == null) {
      return SizedBox.shrink();
    }
    return Column(
        children: chats.map(
      (chat) {
        return Row(
          children: [
            Text(chat.name ?? "No name"),
            Text(
              chat.id.toString(),
            ),
          ],
        );
      },
    ).toList());
  }
}
