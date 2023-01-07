import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/auth_provider.dart';
import 'package:y/providers/chats_provider.dart';
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
  late final ChatsProvider? chatsProvider;

  @override
  void didChangeDependencies() {
    chatsProvider = context.watch<ChatsProvider>();
    // chatsProvider.fetchChats();
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
