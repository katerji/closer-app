import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/auth_provider.dart';
import 'package:y/providers/chat_provider.dart';
import 'package:y/utility/routes.dart';

import '../models/chat.dart';
import '../widgets/chats_widget.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: () {
          context.push(Routes.contacts.pageName);
        },
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
            child: Text("Invitations"),
            onPressed: () {
              context.push(Routes.invitations.pageName);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
          TextButton(
            child: Text("logout"),
            onPressed: _logout,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: const ChatsWidget(),
    );
  }
}
