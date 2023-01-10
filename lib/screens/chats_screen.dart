import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/auth_provider.dart';
import 'package:y/utility/routes.dart';
import '../widgets/chats_widget.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

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
          backgroundColor: Colors.blue,
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
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
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
