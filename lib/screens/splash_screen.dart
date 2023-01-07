import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

  @override
  void didChangeDependencies() {
    authProvider ??= context.watch<AuthProvider>();
    if (!authProvider!.didAutoLogin()) {
    authProvider?.autoLoginUser();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return authProvider!.isAuthing() ? splashScreen() : App();
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
