import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/auth_provider.dart';
import 'package:y/providers/chat_provider.dart';
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
  ChatProvider? chatsProvider;

  @override
  void didChangeDependencies() {
    chatsProvider ??= context.watch<ChatProvider>();
    if(!chatsProvider!.didFetchChats()) {
      chatsProvider!.fetchChats();
    }
    super.didChangeDependencies();
  }

  void _logout() async {
    context.read<AuthProvider>().logout();
    // if (!mounted) return;
    // context.go(Routes.login.pageName);
  }

  @override
  Widget build(BuildContext context) {
    // context.read<ChatsProvider>().fetchChats();
    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: () {},
        child: Icon(Icons.add, color: Colors.white),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
          backgroundColor: Colors.blue, // <-- Button color
          // foregroundColor: Colors.red, // <-- Splash color
        ),
      ),
      appBar: AppBar(
        title: Text("Chats"),
        actions: <Widget>[
          TextButton(
            child: Text("logout"),
            onPressed: _logout,
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
    List<Chat>? chats = chatsProvider!.getChats();
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
