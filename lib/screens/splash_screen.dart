import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:y/providers/chat_provider.dart';
import 'package:y/providers/contact_provider.dart';
import 'package:y/screens/chats_screen.dart';
import 'package:y/screens/login_screen.dart';
import 'package:y/utility/routes.dart';

import '../app.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthProvider? authProvider;
  bool didAppLoad = false;

  @override
  void didChangeDependencies() async {
    authProvider ??= context.watch<AuthProvider>();
    if (authProvider!.didAutoLogin) {
      if (authProvider?.loggedInUser != null) {
        await context.read<ChatProvider>().fetchChats();
        context.read<ContactProvider>().setContactsFromStorage();
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            didAppLoad = true;
          });
        });
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            didAppLoad = true;
          });
        });
      }
    } else {
      authProvider?.autoLoginUser();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return didAppLoad ? App() : splashScreen();
  }

  Widget splashScreen() {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            "Closer",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
